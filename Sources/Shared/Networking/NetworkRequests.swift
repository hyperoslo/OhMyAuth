import Foundation

struct AccessTokenRequest: NetworkRequestable {
  let URL: NSURL
  var parameters: [String: AnyObject]

  init(config: AuthConfig, parameters: [String: AnyObject]) {
    URL = config.accessTokenUrl

    self.parameters = config.accessTokenParameters

    parameters.forEach { key, value in
      self.parameters[key] = value
    }
  }
}

struct RefreshTokenRequest: NetworkRequestable {
  let URL: NSURL
  var parameters: [String: AnyObject]

  init(config: AuthConfig, refreshToken: String) {
    URL = config.accessTokenUrl
    parameters = config.refreshTokenParameters
    parameters["refresh_token"] = refreshToken
  }
}
