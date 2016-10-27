import Foundation
import Alamofire

struct AccessTokenRequest: NetworkRequestable {
  let url: URL
  var parameters: [String: Any]
  var headers: [String: String]
  var manager: Alamofire.SessionManager

  init(config: AuthConfig, parameters: [String: Any]) {
    manager = config.manager
    url = config.accessTokenUrl

    self.parameters = config.accessTokenParameters
    self.headers = config.headers

    parameters.forEach { key, value in
      self.parameters[key] = value
    }
  }
}

struct RefreshTokenRequest: NetworkRequestable {
  let url: URL
  var parameters: [String: Any]
  var headers: [String: String]
  var manager: Alamofire.SessionManager

  init(config: AuthConfig, refreshToken: String) {
    manager = config.manager
    url = config.accessTokenUrl
    parameters = config.refreshTokenParameters
    parameters["refresh_token"] = refreshToken
    self.headers = config.headers
  }
}
