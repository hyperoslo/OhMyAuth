import Foundation

@objc public class Authenticator: NSObject {

  public static var errorDomain = "AzureOAuth"
  public static var minimumValidity: NSTimeInterval = 5 * 60
  public static var loginConfig: LoginConfig?
  public static var tokenConfig: TokenConfig?
  public static var locker: Lockable = Locker()
  public static var authorizer: Authorizer = Authorizer()

  static func config() throws -> (login: LoginConfig, token: TokenConfig) {
    guard let tokenConfig = tokenConfig,
      loginConfig = loginConfig
      else {
        throw NSError(
          domain: Authenticator.errorDomain,
          code: Error.NoConfigFound.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No token or login config provided"])
    }

    return (login: loginConfig, token: tokenConfig)
  }

  public static func accessToken(completion: (String?, NSError?) -> Void) {
    guard let expiryDate = locker.expiryDate else {
      let error = NSError(domain: errorDomain,
        code: Error.ExpirationDateNotFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Expiration date not found"])

      completion(nil, error)
      return
    }

    guard expiryDate.timeIntervalSinceNow < minimumValidity else {
      completion(locker.accessToken, nil)
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

  public static func logout() {
    Authenticator.locker.clear()
  }
}
