import Alamofire

protocol NetworkRequestable {
  var URL: NSURL { get }
  var parameters: [String: AnyObject] { get }
}

extension NetworkRequestable {

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
