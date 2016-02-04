import Foundation

@objc public class AuthService: NSObject {

  public let name: String
  public let tokenProvider: TokenProvider
  public let codeProvider: CodePrivider
  public let config: AuthConfig
  public var locker: Lockable

  // MARK: - Initialization

  public init(name: String, config: AuthConfig) {
    self.name = name
    self.config = config
    self.config.name = name
    locker = Locker(name: name)
    tokenProvider = TokenProvider(config: config, locker: locker)
    codeProvider = CodePrivider(config: config, locker: locker, tokenProvider: tokenProvider)
  }
}
