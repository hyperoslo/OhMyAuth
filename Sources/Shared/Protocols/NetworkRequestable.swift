import Alamofire
import Sugar

protocol NetworkRequestable {
  var URL: NSURL { get }
  var parameters: [String: AnyObject] { get }
}

extension NetworkRequestable {

  func start(completion: (result: Result<AnyObject>) -> Void) {
    Alamofire.request(.POST, URL, parameters: parameters, encoding: .URL).responseJSON { response in
      guard response.result.isSuccess else {
        completion(result: .Failure(response.result.error))
        return
      }

      guard let value = response.result.value else {
        completion(result: .Failure(Error.NoDataInResponse.toNSError()))
        return
      }

      if let JSON = value as? JSONDictionary, errorDictionary = JSON["error"] as? JSONDictionary {
        let error = Error.TokenRequestFailed.toNSError(
          JSON["error_description"] as? String, userInfo: errorDictionary)

        completion(result: .Failure(error))
        return
      }

      guard response.response?.statusCode == 200 else {
        completion(result: .Failure(Error.TokenRequestFailed.toNSError()))
        return
      }

      completion(result: .Success(response.result.value!))
    }
  }
}
