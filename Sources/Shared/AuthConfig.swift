import Foundation

@objc public class AuthConfig: NSObject {

  public static var errorDomain = "AzureOAuth"
  public static var minimumValidity: NSTimeInterval = 5 * 60
  public static var loginConfig: LoginConfig?
  public static var tokenConfig: TokenConfig?

  static func config() throws -> (login: LoginConfig, token: TokenConfig) {
    guard let tokenConfig = tokenConfig, loginConfig = loginConfig
      else { throw Error.NoConfigFound.toNSError() }

    return (login: loginConfig, token: tokenConfig)
  }
}

@objc public class LoginConfig: NSObject {

  public var loginURL: NSURL
  public var changeUserURL: NSURL?
  public let redirectURI: String

  public init(loginURL: NSURL, redirectURI: String, changeUserURL: NSURL? = nil) {
    self.loginURL = loginURL
    self.changeUserURL = changeUserURL
    self.redirectURI = redirectURI
  }
}

@objc public class TokenConfig: NSObject {

  public let accessGrantType = "authorization_code"
  public let refreshGrantType = "refresh_token"

  public var URL: NSURL
  public var resource: String
  public let clientId: String
  public let clientSecret: String

  public init(URL: NSURL, resource: String, clientId: String, clientSecret: String) {
    self.URL = URL
    self.resource = resource
    self.clientId = clientId
    self.clientSecret = clientSecret
  }
}
