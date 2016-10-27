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
      
      guard let data = data,
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
      else {
        completion(Result.failure(OhMyAuthError.internalError.toNSError()))
        return
      }
      
      completion(Result.success(json))
    }
  }
}
