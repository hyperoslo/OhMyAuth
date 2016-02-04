import Foundation
import Sugar
import JWTDecode

struct TokenNetworkTask: NetworkTaskable, NetworkQueueable {

  let locker: Lockable

  // MARK: - Initialization

  init(locker: Lockable) {
    self.locker = locker
  }

  // MARK: - Processing

  func process(data: JSONDictionary) throws -> String {
    guard data["error"] == nil else {
      throw Error.TokenRequestFailed.toNSError(data["error_description"] as? String)
    }

    guard let accessToken = data["access_token"] as? String else {
      locker.clear()
      throw Error.NoAccessTokenFound.toNSError()
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      locker.clear()
      throw Error.NoAccessTokenFound.toNSError()
    }

    locker.accessToken = accessToken
    locker.refreshToken = refreshToken

    if let expiresOn = data["expires_on"] {
      locker.expiryDate = NSDate(timeIntervalSince1970: expiresOn.doubleValue)
    } else {
      locker.expiryDate = nil
    }

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
