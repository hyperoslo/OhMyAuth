import Foundation

@objc public enum OhMyAuthError: Int {
  case codeParameterNotFound = -1
  case noConfigFound = -2
  case noRefreshTokenFound = -3
  case tokenRequestFailed = -4
  case tokenRequestAlreadyStarted = -5
  case authServiceDeallocated = -6

  // MARK: - Helpers

  public var defaultMessage: String {
    var message: String

    switch self {
    case .codeParameterNotFound:
      message = "Code parameter not found"
    case .noConfigFound:
      message = "No token or login config provided"
    case .noRefreshTokenFound:
      message = "No refresh token in locker"
    case .tokenRequestFailed:
      message = "Token request error"
    case .tokenRequestAlreadyStarted:
      message = "Token request has already been started"
    case .authServiceDeallocated:
      message = "AuthService has been deallocated"
    }

    return message
  }

  public func toNSError(_ message: String? = nil, userInfo: [String: Any] = [:]) -> NSError {
    let text = message ?? defaultMessage
    let domain = "OhMyAuth"

    NSLog("\(domain): \(text)")

    var dictionary = userInfo
    dictionary[NSLocalizedDescriptionKey] = text as AnyObject?

    return NSError(domain: domain,
      code: rawValue,
      userInfo: dictionary)
  }
}
