import Foundation
import Malibu

struct AccessTokenRequest: NetworkRequestable, POSTRequestable {
  var networking: Networking
  var message: Message

  init(config: AuthConfig, parameters: [String: Any]) {
    networking = config.networking
    
    var allParameters: [String: Any] = config.accessTokenParameters

    parameters.forEach { (key, value) in
      allParameters[key] = value
    }
    
    message = Message(resource: config.accessTokenUrl, parameters: allParameters, headers: config.headers)
  }
}

struct RefreshTokenRequest: NetworkRequestable, POSTRequestable {
  var networking: Networking
  var message: Message

  init(config: AuthConfig, refreshToken: String) {
    networking = config.networking

    var parameters = config.refreshTokenParameters
    parameters["refresh_token"] = refreshToken
    
    message = Message(resource: config.accessTokenUrl, parameters: parameters, headers: config.headers)
  }
}
