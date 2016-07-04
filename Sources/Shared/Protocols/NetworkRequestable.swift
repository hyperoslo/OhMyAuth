import Alamofire
import Sugar

protocol NetworkRequestable {
  var URL: NSURL { get }
  var parameters: [String: AnyObject] { get }
  var headers: [String: String] { get }
}

extension NetworkRequestable {

  func start(completion: (result: Result<AnyObject>) -> Void) {
    Alamofire.request(.POST, URL, parameters: parameters, encoding: .URL, headers: headers).responseJSON { response in
      guard response.result.isSuccess else {
        completion(result: .Failure(response.result.error))
        return
      }

      guard response.response?.statusCode != 401 else {
        var userInfo: [String: AnyObject] = [:]

        if let value = response.result.value as? [String: AnyObject],
          parsedValue = AuthConfig.parse?(response: value) {
          userInfo = parsedValue
        }

        if let statusCode = response.response?.statusCode {
          userInfo["statusCode"] = statusCode
        }

        completion(result: .Failure(Error.TokenRequestFailed.toNSError(userInfo: userInfo)))
        return
      }

      completion(result: .Success(response.result.value!))
    }
  }
}
