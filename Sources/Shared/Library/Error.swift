import Foundation

@objc enum Error: Int, ErrorType {
  case CodeParameterNotFound = -1
  case ExpirationDateNotFound = -2
  case NoConfigFound = -3
  case NoDataInResponse = -4
  case TokenRequestFailed = -5
  case NoAccessTokenFound = -6
  case NoRefreshTokenFound = -7
  case TokenRequestAlreadyStarted = -8

  // MARK: - Helpers

  var defaultMessage: String {
    var message: String

    switch self {
    case CodeParameterNotFound:
      message = "Code parameter not found"
    case ExpirationDateNotFound:
      message = "Expiration date not found"
    case NoConfigFound:
      message = "No token or login config provided"
    case NoDataInResponse:
      message = "No data in response"
    case TokenRequestFailed:
      message = "Token request error"
    case NoAccessTokenFound:
      message = "No access token found"
    case NoRefreshTokenFound:
      message = "No access token found"
      break
    case TokenRequestAlreadyStarted:
      message = "Token request has already been started"
      break
    }

    return message
  }

  func toNSError(message: String? = nil, userInfo: [String: AnyObject] = [:]) -> NSError {
    let text = message ?? defaultMessage
    let domain = "OhMyAuth"

    NSLog("\(domain): \(text)")

    var dictionary = userInfo
    dictionary[NSLocalizedDescriptionKey] = text

    return NSError(domain: domain,
      code: rawValue,
      userInfo: dictionary)
  }
}
