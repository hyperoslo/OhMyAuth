import Foundation
import Alamofire

protocol Requestable {
  var URL: NSURL { get }
  var parameters: [String: AnyObject] { get }
}

extension Requestable {

  func start(completion: (result: Result<AnyObject>) -> Void) {
    Alamofire.request(.POST, URL, parameters: parameters, encoding: .URL).responseJSON {
      response in

      guard response.result.isSuccess else {
        completion(result: .Failure(response.result.error))
        return
      }

      completion(result: .Success(response.result.value!))
    }
  }
}

struct AccessTokenRequest: Requestable {
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

struct RefreshTokenRequest: Requestable {
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
