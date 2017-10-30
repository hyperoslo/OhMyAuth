import Foundation

@objc open class AuthService: NSObject {

  public typealias Completion = (String?, Error?) -> Void

  open let name: String
  open let config: AuthConfig
  open var locker: Lockable

  fileprivate var pendingTokenCompletions = [Completion]()
  fileprivate var executing = false
  fileprivate let tokenQueue = DispatchQueue(label: "OhMyAuth.AuthService.TokenQueue", attributes: DispatchQueue.Attributes.concurrent)

  open var tokenIsExpired: Bool {
    guard let expiryDate = locker.expiryDate else {
      return true
    }

    let expiredTime = expiryDate.timeIntervalSince1970
    let timeNow = Date().timeIntervalSince1970 + config.minimumValidity
    let expired = timeNow >= expiredTime

    return expired
  }

  // MARK: - Initialization

  public init(name: String, config: AuthConfig, locker: Lockable? = nil) {
    self.name = name
    self.config = config
    self.config.name = name

    if let locker = locker {
      self.locker = locker
    } else {
      self.locker = KeychainLocker(name: name)
    }
  }

  // MARK: - Authorization

  open func authorize() -> Bool {
    guard let URL = config.authorizeURL else { return false }

    locker.clear()
    config.webView.open(URL)

    return true
  }

  open func changeUser() -> Bool {
    guard let URL = config.changeUserURL else { return false }

    locker.clear()
    config.webView.open(URL)

    return true
  }

  open func deauthorize(_ completion: () -> ()) -> Bool {
    guard let URL = config.deauthorizeURL else { return false }

    locker.clear()
    config.webView.open(URL)
    completion()

    return true
  }

  // MARK: - Tokens

  open func accessToken(_ force: Bool = false, completion: @escaping Completion) {
    tokenQueue.async(flags: .barrier, execute: { [weak self] in
      guard let weakSelf = self else {
        completion(nil, OhMyAuthError.authServiceDeallocated.toNSError())
        return
      }

      guard force || (weakSelf.tokenIsExpired && weakSelf.config.checkExpiry) else {
        completion(weakSelf.locker.accessToken, nil)
        return
      }

      weakSelf.pendingTokenCompletions.append(completion)

      guard !weakSelf.executing else { return }

      weakSelf.refreshToken() { [weak self] accessToken, error in
        guard let weakSelf = self else {
          completion(nil, OhMyAuthError.authServiceDeallocated.toNSError())
          return
        }

        weakSelf.tokenQueue.async(flags: .barrier, execute: { [weak self] in
          guard let weakSelf = self else {
            completion(nil, OhMyAuthError.authServiceDeallocated.toNSError())
            return
          }

          weakSelf.pendingTokenCompletions.forEach { completion in
            completion(accessToken, error)
          }

          weakSelf.pendingTokenCompletions = []
        }) 
      }
    }) 
  }

  open func accessToken(URL: Foundation.URL, completion: @escaping Completion) -> Bool {
    guard let redirectURI = config.redirectURI,
      let URLComponents = URLComponents(url: URL, resolvingAgainstBaseURL: false),
      let code = URLComponents.queryItems?.filter({ $0.name == "code" }).first?.value
      , URL.absoluteString.hasPrefix(redirectURI)
      else {
        completion(nil, OhMyAuthError.codeParameterNotFound.toNSError())
        return false
    }

    accessToken(parameters: ["code" : code as AnyObject]) { [weak self] accessToken, error in
      completion(accessToken, error)
      self?.config.webView.close?()
    }

    return true
  }

  open func accessToken(parameters: [String: Any], completion: @escaping Completion) {
    let request = AccessTokenRequest(config: config, parameters: parameters)
    executeRequest(request, completion: completion)
  }

  open func refreshToken(_ completion: @escaping Completion) {
    guard let token = locker.refreshToken else {
      completion(nil, OhMyAuthError.noRefreshTokenFound.toNSError())
      return
    }

    let request = RefreshTokenRequest(config: config, refreshToken: token)
    executeRequest(request, completion: completion)
  }

  open func cancel() {
    AuthConfig.networking.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
      dataTasks.forEach { $0.cancel() }
      uploadTasks.forEach { $0.cancel() }
      downloadTasks.forEach { $0.cancel() }
    }
  }

  // MARK: - Helpers

  func executeRequest(_ request: NetworkRequestable, completion: @escaping Completion) {
    guard !executing else {
      completion(nil, OhMyAuthError.tokenRequestAlreadyStarted.toNSError())
      return
    }

    executing = true

    TokenNetworkTask(locker: locker, config: config).execute(request) { [weak self] result in
      guard let weakSelf = self else {
        completion(nil, OhMyAuthError.authServiceDeallocated.toNSError())
        return
      }

      weakSelf.executing = false

      switch result {
      case .failure(let error):
        completion(nil, error)
      case .success(let accessToken):
        completion(accessToken, nil)
      }
    }
  }
}
