import Foundation

protocol NetworkRequestable {
  var url: URL { get }
  var parameters: [String: Any] { get }
  var headers: [String: String] { get }
}

extension NetworkRequestable {

  func start(_ completion: @escaping (_ result: Result<Any>) -> Void) {
    AuthConfig.networking.post(url: url, parameters: parameters, headers: headers) { (data, response, error) in
      guard let response = response as? HTTPURLResponse else {
        completion(Result.failure(OhMyAuthError.internalError.toNSError()))
        return
      }
      
      guard error == nil
      else {
        if let error = error as? NSError {
          completion(Result.failure(error))
        } else {
          completion(Result.failure(OhMyAuthError.internalError.toNSError()))
        }
        
        return
      }
      
      guard let data = data,
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
        let json = jsonObject as? [String: Any]
      else {
        completion(Result.failure(OhMyAuthError.internalError.toNSError()))
        return
      }
      
      if response.statusCode != 401 {
        completion(Result.success(json))
      } else {
        var userInfo: [String: Any] = json
        userInfo["statusCode"] = response.statusCode
        
        completion(.failure(OhMyAuthError.tokenRequestFailed.toNSError(userInfo: userInfo)))
      }
    }
  }
}
