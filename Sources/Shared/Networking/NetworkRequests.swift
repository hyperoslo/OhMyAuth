import Foundation

struct AccessTokenRequest: NetworkRequestable {
  let URL: NSURL
  var parameters: [String: AnyObject]
  var headers: [String: String]

  init(config: AuthConfig, parameters: [String: AnyObject]) {
    URL = config.accessTokenUrl

    self.parameters = config.accessTokenParameters
    self.headers = config.headers

    parameters.forEach { key, value in
      self.parameters[key] = value
    }
  }
}

struct RefreshTokenRequest: NetworkRequestable {
  let URL: NSURL
  var parameters: [String: AnyObject]
  var headers: [String: String]

  init(config: AuthConfig, refreshToken: String) {
    URL = config.accessTokenUrl
    parameters = config.refreshTokenParameters
    parameters["refresh_token"] = refreshToken
    self.headers = config.headers
  }
}
