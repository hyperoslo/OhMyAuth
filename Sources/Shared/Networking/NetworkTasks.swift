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

  func process(_ data: JSONDictionary) throws -> String {
    guard let accessToken = data["access_token"] as? String else {
      locker.clear()
      NSLog("\(data)")
      throw OhMyAuthError.tokenRequestFailed.toNSError(userInfo: data)
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      locker.clear()
      NSLog("\(data)")
      throw OhMyAuthError.tokenRequestFailed.toNSError(userInfo: data)
    }

    guard let expiryDate = config.expiryDate(data) else {
      locker.clear()
      NSLog("\(data)")
      throw OhMyAuthError.tokenRequestFailed.toNSError()
    }

    locker.accessToken = accessToken
    locker.refreshToken = refreshToken
    locker.expiryDate = expiryDate
    locker.tokenType = data["token_type"] as? String

    if let jwtString = data["id_token"] as? String {
      do {
        let payload = try decode(jwt: jwtString)

        if let name = payload.body["name"] as? String {
          locker.userName = name
        }

        if let upn = payload.body["upn"] as? String {
          locker.userUPN = upn
        }
      } catch {}
    }

    locker.synchronize()

    return accessToken
  }
}
