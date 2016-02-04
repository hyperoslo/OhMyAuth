import Foundation

struct AccessTokenRequest: NetworkRequestable {
  let URL: NSURL
  var parameters: [String: AnyObject]

  init(config: AuthConfig, parameters: [String: AnyObject]) {
    URL = config.accessTokenUrl

    self.parameters = config.extraAccessTokenParameters

    parameters.forEach { key, value in
      self.parameters[key] = value
    }
  }
}

struct RefreshTokenRequest: NetworkRequestable {
  let URL: NSURL
  let parameters: [String: AnyObject]

  init(config: AuthConfig) {
    URL = config.accessTokenUrl
    parameters = config.extraRefreshTokenParameters
  }
}
