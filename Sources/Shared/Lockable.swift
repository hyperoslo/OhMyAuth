import Foundation

@objc public protocol Lockable {
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
  var tokenType: String? { get set }
  var expiryDate: NSDate? { get set }
  var userName: String? { get set }
  var userUPN: String? { get set }

  init(name: String)
  func clear()
}

public extension Lockable {

  public func migrate(from: Lockable, to: Lockable) {
    to.accessToken = from.accessToken
    to.refreshToken = from.refreshToken
    to.tokenType = from.tokenType
    to.expiryDate = from.expiryDate
    to.userName = from.userName
    to.userUPN = from.userUPN
    from.clear()
  }
}
