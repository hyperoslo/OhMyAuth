import Foundation

open class Networking {
  public let session: URLSession
  
  public init(configuration: URLSessionConfiguration) {
    session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
  }
  
  public func post(url: URL, parameters: [String: Any], headers: [String: String], completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
    var request = URLRequest(url: url)
    
    headers.forEach { (key, value) in
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    if request.value(forHTTPHeaderField: "Content-Type") == nil {
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    
    request.httpMethod = "POST"

    request.httpBody = QueryBuilder()
      .buildQuery(from: parameters)
      .data(using: String.Encoding.utf8, allowLossyConversion: false)

    let task = session.dataTask(with: request) { (data, response, error) in
      completion(data, response, error)
    }
    
    task.resume()
  }
}

// https://github.com/hyperoslo/Malibu/blob/master/Sources/Helpers/QueryBuilder.swift
fileprivate struct QueryBuilder {

  typealias Component = (String, String)

  let escapingCharacters = ":#[]@!$&'()*+,;="

  init() {}

  func buildQuery(from parameters: [String: Any]) -> String {
    return buildComponents(from: parameters).map({ "\($0)=\($1)" }).joined(separator: "&")
  }

  func buildComponents(from parameters: [String: Any]) -> [Component] {
    var components: [Component] = []

    for key in parameters.keys.sorted(by: <) {
      guard let value = parameters[key] else {
        continue
      }

      components += buildComponents(key: key, value: value)
    }

    return components
  }

  func buildComponents(key: String, value: Any) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: Any] {
      dictionary.forEach { nestedKey, value in
        components += buildComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [Any] {
      array.forEach { value in
        components += buildComponents(key: "\(key)[]", value: value)
      }
    } else if let bool = value as? Bool {
      components.append((escape(key), escape((bool ? "1" : "0"))))
    } else {
      components.append((escape(key), escape("\(value)")))
    }

    return components
  }

  func escape(_ string: String) -> String {
    guard let allowedCharacters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as? NSMutableCharacterSet else {
      return string
    }

    allowedCharacters.removeCharacters(in: escapingCharacters)

    var escapedString = ""

    if #available(iOS 8.3, *) {
      escapedString = string.addingPercentEncoding(
        withAllowedCharacters: allowedCharacters as CharacterSet) ?? string
    } else {
      var index = string.startIndex

      while index != string.endIndex {
        let endIndex = string.index(index, offsetBy: 50, limitedBy: string.endIndex) ?? string.endIndex
        let range = Range(index..<endIndex)
        let substring = string.substring(with: range)

        escapedString += substring.addingPercentEncoding(
          withAllowedCharacters: allowedCharacters as CharacterSet) ?? substring

        index = endIndex
      }
    }
    
    return escapedString
  }
}

