import Foundation

@objc public class AuthConfig: NSObject {

  // Parse network response to userInfo
  public static var parse: ((response: [String: AnyObject]) -> [String: AnyObject]?)?

  public var clientId: String
  public var accessGrantType: String
  public var accessTokenUrl: NSURL
  public var authorizeURL: NSURL?
  public var changeUserURL: NSURL?
  public var deauthorizeURL: NSURL?
  public var redirectURI: String?
  public var minimumValidity: NSTimeInterval = 5 * 60

  public var expiryDate: (data: [String : AnyObject]) -> NSDate? = { data -> NSDate? in
    var date: NSDate?

    if let expiresIn = data["expires_in"] as? Double {
      date = NSDate(timeIntervalSinceNow: expiresIn)
    }

    return date
  }

  public var extraAccessTokenParameters = [String: String]()
  public var extraRefreshTokenParameters = [String: String]()

  public var webView: WebViewable = BrowserWebView()

  let refreshGrantType = "refresh_token"
  var name = "OhMyAuth"

  var sharedParameters: [String: String] {
    var parameters = ["client_id" : clientId]

    if let redirectURI = redirectURI {
      parameters["redirect_uri"] = redirectURI
    }

    return parameters
  }

  var accessTokenParameters: [String: String] {
    var parameters = sharedParameters
    parameters["grant_type"] = accessGrantType

    extraAccessTokenParameters.forEach { key, value in
      parameters[key] = value
    }

    return parameters
  }

  var refreshTokenParameters: [String: String] {
    var parameters = sharedParameters
    parameters["grant_type"] = refreshGrantType

    extraRefreshTokenParameters.forEach { key, value in
      parameters[key] = value
    }

    return parameters
  }

  // MARK: - Initialization

  public init(clientId: String, accessTokenUrl: NSURL, accessGrantType: String = "authorization_code",
    authorizeURL: NSURL? = nil, changeUserURL: NSURL? = nil, redirectURI: String? = nil) {
      self.clientId = clientId
      self.accessGrantType = accessGrantType
      self.accessTokenUrl = accessTokenUrl
      self.authorizeURL = authorizeURL
      self.changeUserURL = changeUserURL
      self.redirectURI = redirectURI
  }
}
