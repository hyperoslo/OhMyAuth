import Foundation

open class Networking {
  public let session: URLSession
  
  public init(configuration: URLSessionConfiguration) {
    session = URLSession(configuration: configuration, delegateQueue: OperationQueue.main)
  }
  
  public func post(url: URL, parameters: [String: Any], headers: [String: String], completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
    var request = URLRequest(url: url)
    
    headers.forEach { (key, value) in
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if request.value(forHTTPHeaderField: "Content-Type") == nil {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        
    let task = session.dataTask(with: request) { (data, response, error) in
      completion(data, response, error)
    }
    
    task.resume()
  }
}
