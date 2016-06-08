import Foundation

@objc public enum Error: Int, ErrorType {
  case CodeParameterNotFound = -1
  case NoConfigFound = -2
  case NoRefreshTokenFound = -3
  case TokenRequestFailed = -4
  case NoDataInResponse = -5
  case NoAccessTokenInResponse = -6
  case NoRefreshTokenInResponse = -7
  case NoExpiryDateInResponse = -8
  case TokenRequestAlreadyStarted = -9
  case AuthServiceDeallocated = -10

  // MARK: - Helpers

  public var defaultMessage: String {
    var message: String

    switch self {
    case CodeParameterNotFound:
      message = "Code parameter not found"
    case NoConfigFound:
      message = "No token or login config provided"
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
    case AuthServiceDeallocated:
      message = "AuthService has been deallocated"
    }

    return message
  }

  public func toNSError(message: String? = nil, userInfo: [String: AnyObject] = [:]) -> NSError {
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
