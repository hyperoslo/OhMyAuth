import Foundation

public struct LoginConfig {

  public var loginURL: NSURL
  public var changeUserURL: NSURL?

  public init(loginURL: NSURL, changeUserURL: NSURL?) {
    self.loginURL = loginURL
    self.changeUserURL = changeUserURL
  }
}

public struct TokenConfig {

  public let accessGrantType = "authorization_code"
  public let refreshGrantType = "refresh_token"

  public var URL: NSURL
  public var resource: String
  public let clientId: String
  public let clientSecret: String
  public let redirectURI: String

  public init(URL: NSURL, resource: String, clientId: String, clientSecret: String, redirectURI: String) {
    self.URL = URL
    self.resource = resource
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.redirectURI = redirectURI
  }
}
