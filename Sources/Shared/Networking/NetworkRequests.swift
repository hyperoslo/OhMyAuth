import Foundation

struct AccessTokenRequest: NetworkRequestable {
  let URL: NSURL
  let parameters: [String: AnyObject]

  init(code: String) throws {
    do {
      let config = try AuthConfig.config()
      URL = config.token.URL

      parameters = [
        "client_id" : config.token.clientId,
        "code" : code,
        "grant_type" : config.token.accessGrantType,
        "resource" : config.token.resource,
        "redirect_uri": config.login.redirectURI
      ]
    } catch {
      throw error
    }
  }
}

struct RefreshTokenRequest: NetworkRequestable {
  let URL: NSURL
  let parameters: [String: AnyObject]

  init() throws {
    do {
      let config = try AuthConfig.config()
      URL = config.token.URL

      guard let refreshToken = AuthContainer.locker.refreshToken else {
        throw Error.NoRefreshTokenFound.toNSError()
      }

      parameters = [
        "client_id" : config.token.clientId,
        "grant_type": config.token.refreshGrantType,
        "refresh_token": refreshToken,
        "resource": config.token.resource,
        "redirect_uri": config.login.redirectURI
      ]
    } catch {
      throw error
    }
  }
}
