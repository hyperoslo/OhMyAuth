import Foundation

@objc public class AuthContainer: NSObject {

  public static var locker: Lockable = Locker()
  public static var authenticator: Authenticator = Authenticator()
  public static var tokenProvider: TokenProvider = TokenProvider()
}
