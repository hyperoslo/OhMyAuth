import Foundation

@objc enum Error: Int, ErrorType {
  case CodeParameterNotFound = -1
  case NoConfigFound = -2
  case NoExpiryDateFound = -3
  case NoRefreshTokenFound = -4
  case TokenRequestFailed = -5
  case NoDataInResponse = -6
  case NoAccessTokenInResponse = -7
  case NoRefreshTokenInResponse = -8
  case NoExpiryDateInResponse = -9
  case TokenRequestAlreadyStarted = -10

  // MARK: - Helpers

  var defaultMessage: String {
    var message: String

    switch self {
    case CodeParameterNotFound:
      message = "Code parameter not found"
    case NoConfigFound:
      message = "No token or login config provided"
    case NoExpiryDateFound:
      message = "No expiration date in keychain"
    case NoRefreshTokenFound:
      message = "No refresh token in keychain"
    case TokenRequestFailed:
      message = "Token request error"
    case NoDataInResponse:
      message = "No data in response"
    case NoAccessTokenInResponse:
      message = "No access token in response"
    case NoRefreshTokenInResponse:
      message = "No refresh token in response"
    case NoExpiryDateInResponse:
      message = "No expiration date in response"
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
