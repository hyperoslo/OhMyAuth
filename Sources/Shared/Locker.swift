import Foundation
import Keychain
import Sugar

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

@objc public class Locker: NSObject, Lockable {

  public struct KeychainKeys {
    public static let service = "\(Application.name)"
    public static let accessToken = "\(Application.name)-AccessToken"
    public static let refreshToken = "\(Application.name)-RefreshToken"
    public static let tokenType = "\(Application.name)-TokenType"
  }

  public struct UserDefaultsKeys {
    public static let expiryDate = "\(Application.name)-ExpiryDate"
    public static let userName = "\(Application.name)-UserName"
    public static let userUPN = "\(Application.name)-UserUPN"
  }

  let name: String
  let userDefaults = NSUserDefaults.standardUserDefaults()


  // MARK: - Initialization

  public required init(name: String) {
    self.name = name
  }

  // MARK: - Keychain

  public var accessToken: String? {
    get { return getFromKeychain(KeychainKeys.accessToken) }
    set { saveInKeychain(KeychainKeys.accessToken, newValue) }
  }

  public var refreshToken: String? {
    get { return getFromKeychain(KeychainKeys.refreshToken) }
    set { saveInKeychain(KeychainKeys.refreshToken, newValue) }
  }

  public var tokenType: String? {
    get { return getFromKeychain(KeychainKeys.tokenType) }
    set { saveInKeychain(KeychainKeys.tokenType, newValue) }
  }

  // MARK: - UserDefaults

  public var expiryDate: NSDate? {
    get { return getFromDefaults(UserDefaultsKeys.expiryDate) as NSDate? }
    set { saveInDefaults(UserDefaultsKeys.expiryDate, newValue) }
  }

  public var userName: String? {
    get { return getFromDefaults(UserDefaultsKeys.userName) as String? }
    set { saveInDefaults(UserDefaultsKeys.userName, newValue) }
  }

  public var userUPN: String? {
    get { return getFromDefaults(UserDefaultsKeys.userUPN) as String? }
    set { saveInDefaults(UserDefaultsKeys.userUPN, newValue) }
  }

  // MARK: - Helpers

  func getFromKeychain(key: String) -> String? {
    let namedKey = generateKey(key)
    let password = Keychain.password(forAccount: namedKey, service: KeychainKeys.service)

    return !password.isEmpty ? password : nil
  }

  func saveInKeychain(key: String, _ value: String?) {
    let namedKey = generateKey(key)

    if let value = value {
      Keychain.setPassword(value, forAccount: namedKey, service: KeychainKeys.service)
    } else {
      Keychain.deletePassword(forAccount: namedKey, service: KeychainKeys.service)
    }
  }

  func getFromDefaults<T>(key: String) -> T? {
    let namedKey = generateKey(key)
    return userDefaults.objectForKey(namedKey) as? T
  }

  func saveInDefaults(key: String, _ value: AnyObject?) {
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

  // MARK: - Clear

  public func clear() {
    accessToken = nil
    refreshToken = nil
    tokenType = nil
    expiryDate = nil
  }
}
