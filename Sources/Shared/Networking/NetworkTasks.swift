import Foundation
import Sugar
import JWTDecode

struct TokenNetworkTask: NetworkTaskable, NetworkQueueable {

  let locker: Lockable
  let config: AuthConfig

  // MARK: - Initialization

  init(locker: Lockable, config: AuthConfig) {
    self.locker = locker
    self.config = config
  }

  // MARK: - Processing

  func process(data: JSONDictionary) throws -> String {
    if let error = data["error"] as? JSONDictionary {
      throw Error.TokenRequestFailed.toNSError(data["error_description"] as? String, userInfo: error)
    }

    guard let accessToken = data["access_token"] as? String else {
      locker.clear()
      NSLog("\(data)")
      throw Error.NoAccessTokenInResponse.toNSError()
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      locker.clear()
      NSLog("\(data)")
      throw Error.NoRefreshTokenInResponse.toNSError()
    }

    guard let expiryDate = config.expiryDate(data: data) else {
      locker.clear()
      NSLog("\(data)")
      throw Error.NoExpiryDateInResponse.toNSError()
    }

    locker.accessToken = accessToken
    locker.refreshToken = refreshToken
    locker.expiryDate = expiryDate
    locker.tokenType = data["token_type"] as? String

    if let jwtString = data["id_token"] as? String {
      do {
        let payload = try decode(jwtString)

        if let name = payload.body["name"] as? String {
          locker.userName = name
        }

        if let upn = payload.body["upn"] as? String {
          locker.userUPN = upn
        }
      } catch {}
    }

    return accessToken
  }
}
