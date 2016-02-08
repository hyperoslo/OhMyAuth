import Foundation

@objc public class AuthService: NSObject {

  public typealias Completion = (String?, NSError?) -> Void

  public let name: String
  public let config: AuthConfig
  public var locker: Lockable
  private var pendingTokenCompletions = [Completion]()
  private var pendingToken = false

  public var tokenIsExpired: Bool {
    return locker.expiryDate?.timeIntervalSinceNow < config.minimumValidity
  }

  // MARK: - Initialization

  public init(name: String, config: AuthConfig) {
    self.name = name
    self.config = config
    self.config.name = name
    locker = Locker(name: name)
  }

  // MARK: - Authorization

  public func authorize() -> Bool {
    guard let URL = config.authorizeURL else { return false }

    locker.clear()
    config.webView.open(URL)

    return true
  }

  public func changeUser() -> Bool {
    guard let URL = config.changeUserURL else { return false }

    locker.clear()
    config.webView.open(URL)

    return true
  }

  // MARK: - Tokens

  public func accessToken(completion: Completion) {
    guard locker.expiryDate != nil else {
      completion(nil, Error.ExpirationDateNotFound.toNSError())
      return
    }

    guard tokenIsExpired else {
      completion(locker.accessToken, nil)
      return
    }

    pendingTokenCompletions.append(completion)

    guard !pendingToken else { return }

    pendingToken = true

    refreshToken() { [weak self] accessToken, error in
      guard let weakSelf = self else { return }

      weakSelf.pendingTokenCompletions.forEach { completion in
        completion(accessToken, error)
      }

      weakSelf.pendingTokenCompletions = []
      weakSelf.pendingToken = false
    }
  }

  public func accessToken(URL URL: NSURL, completion: Completion) -> Bool {
    guard let redirectURI = config.redirectURI,
      URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false),
      code = URLComponents.queryItems?.filter({ $0.name == "code" }).first?.value
      where URL.absoluteString.hasPrefix(redirectURI)
      else {
        completion(nil, Error.CodeParameterNotFound.toNSError())
        return false
    }

    accessToken(parameters: ["code" : code]) { [weak self] accessToken, error in
      completion(accessToken, error)
      self?.config.webView.close?()
    }

    return true
  }

  public func accessToken(parameters parameters: [String: AnyObject], completion: Completion) {
    let request = AccessTokenRequest(config: config, parameters: parameters)
    executeRequest(request, completion: completion)
  }

  public func refreshToken(completion: Completion) {
    guard let token = locker.refreshToken else {
      completion(nil, Error.NoRefreshTokenFound.toNSError())
      return
    }

    let request = RefreshTokenRequest(config: config, refreshToken: token)
    executeRequest(request, completion: completion)
  }

  // MARK: - Helpers

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
