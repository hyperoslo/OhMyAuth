import Foundation
import Sugar
import JWTDecode
import Alamofire



struct TokenProvider {

  static func accessToken(completion: (String?, NSError?) -> Void) {
    guard let expiryDate = AuthContainer.locker.expiryDate else {
      completion(nil, Error.ExpirationDateNotFound.toNSError())
      return
    }

    guard expiryDate.timeIntervalSinceNow < AuthConfig.minimumValidity else {
      completion(AuthContainer.locker.accessToken, nil)
      return
    }

    do {
      let request = try RefreshTokenRequest()

      TokenNetworkTask().execute(request) { result in
        switch result {
        case .Failure(let error):
          completion(nil, error as? NSError)
        case .Success(let accessToken):
          completion(accessToken, nil)
        }
      }
    } catch {
      completion(nil, error as NSError)
    }
  }
}
