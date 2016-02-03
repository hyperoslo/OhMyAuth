import Foundation

@objc enum Error: Int, ErrorType {
  case InvalidRedirectURI = -1
  case CodeParameterNotFound = -2
  case ExpirationDateNotFound = -3
  case NoConfigFound = -4
  case NoDataInResponse = -5
  case AuthenticationFailed = -6
  case NoAccessTokenFound = -7
  case NoRefreshTokenFound = -8
}
