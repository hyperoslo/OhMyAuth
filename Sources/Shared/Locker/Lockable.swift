import Foundation

@objc public protocol Lockable {
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
  var tokenType: String? { get set }
  var expiryDate: Date? { get set }
  var userName: String? { get set }
  var userUPN: String? { get set }

  init(name: String)
  func clear()
  @discardableResult  func synchronize() -> Bool
}

public extension Lockable {

  public func migrate(from locker: Lockable) {
    accessToken = locker.accessToken
    refreshToken = locker.refreshToken
    tokenType = locker.tokenType
    expiryDate = locker.expiryDate
    userName = locker.userName
    userUPN = locker.userUPN
    
    locker.clear()
  }
}
