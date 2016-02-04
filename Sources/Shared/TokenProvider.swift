import Foundation

@objc public class TokenProvider: NSObject {

  let config: AuthConfig
  let locker: Lockable

  public var tokenIsExpired: Bool {
    return locker.expiryDate?.timeIntervalSinceNow < config.minimumValidity
  }

  public typealias Completion = (String?, NSError?) -> Void

  // MARK: - Initialization

  public init(config: AuthConfig, locker: Lockable) {
    self.config = config
    self.locker = locker
  }

  // MARK: - Access token

  public func accessToken(completion: (String?, NSError?) -> Void) {
    guard locker.expiryDate != nil else {
      completion(nil, Error.ExpirationDateNotFound.toNSError())
      return
    }

    guard tokenIsExpired else {
      completion(locker.accessToken, nil)
      return
    }

    refreshToken(completion)
  }

  // MARK: - Networking

  public func accessToken(URL URL: NSURL, completion: Completion) -> Bool {
    guard let redirectURI = config.redirectURI,
      URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false),
      code = URLComponents.queryItems?.filter({ $0.name == "code" }).first?.value
      where URL.absoluteString.hasPrefix(redirectURI)
      else {
        completion(nil, Error.CodeParameterNotFound.toNSError())
        return false
    }

    accessToken(parameters: ["code" : code]) { accessToken, error in
      completion(accessToken, error)
    }

    return true
  }

  public func accessToken(parameters parameters: [String: AnyObject], completion: Completion) {
    let request = AccessTokenRequest(config: config, parameters: parameters)
    executeRequest(request, completion: completion)
  }

  public func refreshToken(completion: Completion) {
    let request = RefreshTokenRequest(config: config)
    executeRequest(request, completion: completion)
  }

  func executeRequest(request: NetworkRequestable, completion: Completion) {
    TokenNetworkTask(locker: locker).execute(request) { result in
      switch result {
      case .Failure(let error):
        completion(nil, error as? NSError)
      case .Success(let accessToken):
        completion(accessToken, nil)
      }
    }
  }
}
