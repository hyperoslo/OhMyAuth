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
