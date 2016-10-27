import Foundation

@objc open class AuthConfig: NSObject {

  // Parse network response to userInfo
  open static var parse: ((_ response: [String: Any]) -> [String: Any]?)?
  open static var networking: Networking = Networking(configuration: URLSessionConfiguration.default)

  open var clientId: String
  open var accessGrantType: String
  open var accessTokenUrl: URL
  open var authorizeURL: URL?
  open var changeUserURL: URL?
  open var deauthorizeURL: URL?
  open var redirectURI: String?
  open var minimumValidity: TimeInterval = 5 * 60
  open var checkExpiry = true

  open var expiryDate: (_ data: [String : AnyObject]) -> Date? = { data -> Date? in
    var date: Date?

    if let expiresIn = data["expires_in"] as? Double {
      date = Date(timeIntervalSinceNow: expiresIn)
    }

    return date
  }

  open var extraAccessTokenParameters = [String: String]()
  open var extraRefreshTokenParameters = [String: String]()

  open var webView: WebViewable = BrowserWebView()

  let refreshGrantType = "refresh_token"
  var name = "OhMyAuth"

  open var headers: [String: String] = [:]

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

  public init(clientId: String, accessTokenUrl: URL, accessGrantType: String = "authorization_code",
              authorizeURL: URL? = nil, changeUserURL: URL? = nil, redirectURI: String? = nil, headers: [String: String] = [:]) {
      self.clientId = clientId
      self.accessGrantType = accessGrantType
      self.accessTokenUrl = accessTokenUrl
      self.authorizeURL = authorizeURL
      self.changeUserURL = changeUserURL
      self.redirectURI = redirectURI
      self.headers = headers
  }
}
