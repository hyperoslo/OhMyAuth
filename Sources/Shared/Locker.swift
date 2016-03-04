import Foundation
import Keychain
import Sugar

struct Keys {
  static let service = "\(Application.name)"
  static let accessToken = "\(Application.name)-AccessToken"
  static let refreshToken = "\(Application.name)-RefreshToken"
  static let tokenType = "\(Application.name)-TokenType"
  static let expiryDate = "\(Application.name)-ExpiryDate"
  static let userName = "\(Application.name)-UserName"
  static let userUPN = "\(Application.name)-UserUPN"
}

@objc public protocol Lockable {
  var name: String { get }
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
  var tokenType: String? { get set }
  var expiryDate: NSDate? { get set }
  var userName: String? { get set }
  var userUPN: String? { get set }

  init(name: String)
  func clear()
}

extension Lockable {

  func getFromDefaults<T>(key: String) -> T? {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let namedKey = generateKey(key)
    return userDefaults.objectForKey(namedKey) as? T
  }

  func saveInDefaults(key: String, _ value: AnyObject?) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let namedKey = generateKey(key)

    if let value = value {
      userDefaults.setObject(value, forKey: namedKey)
    } else {
      userDefaults.removeObjectForKey(namedKey)
    }

    userDefaults.synchronize()
  }

  func generateKey(key: String) -> String {
    return "\(name)-\(key)"
  }
}

@objc public class Locker: NSObject, Lockable {

  public let name: String

  // MARK: - Initialization

  public required init(name: String) {
    self.name = name
  }

  // MARK: - Keychain

  public var accessToken: String? {
    get { return getFromKeychain(Keys.accessToken) }
    set { saveInKeychain(Keys.accessToken, newValue) }
  }

  public var refreshToken: String? {
    get { return getFromKeychain(Keys.refreshToken) }
    set { saveInKeychain(Keys.refreshToken, newValue) }
  }

  public var tokenType: String? {
    get { return getFromKeychain(Keys.tokenType) }
    set { saveInKeychain(Keys.tokenType, newValue) }
  }

  // MARK: - UserDefaults

  public var expiryDate: NSDate? {
    get { return getFromDefaults(Keys.expiryDate) as NSDate? }
    set { saveInDefaults(Keys.expiryDate, newValue) }
  }

  public var userName: String? {
    get { return getFromDefaults(Keys.userName) as String? }
    set { saveInDefaults(Keys.userName, newValue) }
  }

  public var userUPN: String? {
    get { return getFromDefaults(Keys.userUPN) as String? }
    set { saveInDefaults(Keys.userUPN, newValue) }
  }

  // MARK: - Helpers

  func getFromKeychain(key: String) -> String? {
    let namedKey = generateKey(key)
    let password = Keychain.password(forAccount: namedKey, service: Keys.service)

    return !password.isEmpty ? password : nil
  }

  func saveInKeychain(key: String, _ value: String?) {
    let namedKey = generateKey(key)

    if let value = value {
      Keychain.setPassword(value, forAccount: namedKey, service: Keys.service)
    } else {
      Keychain.deletePassword(forAccount: namedKey, service: Keys.service)
    }
  }

  // MARK: - Clear

  public func clear() {
    accessToken = nil
    refreshToken = nil
    tokenType = nil
    expiryDate = nil
  }
}
