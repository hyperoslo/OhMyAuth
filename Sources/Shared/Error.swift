import Foundation

@objc enum Error: Int, ErrorType {
  case InvalidRedirectURI = -1
  case CodeParameterNotFound = -2
  case ExpirationDateNotFound = -3
  case NoConfigFound = -4
  case NoDataInResponse = -5
  case TokenRequestFailed = -6
  case NoAccessTokenFound = -7
  case NoRefreshTokenFound = -8

  // MARK: - Helpers

  var defaultMessage: String {
    var message: String

    switch self {
    case InvalidRedirectURI:
      message = "Invalid redirect URI"
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
    }

    return message
  }

  func toNSError(message: String? = nil) -> NSError {
    let text = message ?? defaultMessage

    return NSError(domain: AuthConfig.errorDomain,
      code: rawValue,
      userInfo: [NSLocalizedDescriptionKey: text])
  }
}
