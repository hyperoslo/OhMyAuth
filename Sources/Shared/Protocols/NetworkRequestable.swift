import Alamofire

protocol NetworkRequestable {
  var url: URL { get }
  var parameters: [String: Any] { get }
  var headers: [String: String] { get }
  var manager: Alamofire.SessionManager { get }
}

extension NetworkRequestable {

  func start(_ completion: @escaping (_ result: Result<Any>) -> Void) {
    manager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
      guard response.result.isSuccess else {
        completion(.failure(response.result.error))
        return
      }

      guard response.response?.statusCode != 401 else {
        var userInfo: [String: Any] = [:]

        if let value = response.result.value as? [String: Any],
          let parsedValue = AuthConfig.parse?(value) {
          userInfo = parsedValue
        }

        if let statusCode = response.response?.statusCode {
          userInfo["statusCode"] = statusCode
        }

        completion(.failure(OhMyAuthError.tokenRequestFailed.toNSError(userInfo: userInfo)))
        return
      }

      completion(.success(response.result.value!))
    }
  }
}
