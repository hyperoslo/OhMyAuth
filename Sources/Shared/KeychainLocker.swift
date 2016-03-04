import Foundation
import Keychain
import Sugar

public struct Keys {

  public static let service = "\(Application.name)"
  public static let accessToken = "\(Application.name)-AccessToken"
  public static let refreshToken = "\(Application.name)-RefreshToken"
  public static let tokenType = "\(Application.name)-TokenType"
  public static let expiryDate = "\(Application.name)-ExpiryDate"
  public static let userName = "\(Application.name)-UserName"
  public static let userUPN = "\(Application.name)-UserUPN"
}

@objc public class KeychainLocker: NSObject, Lockable {

  let name: String
  let userDefaults = NSUserDefaults.standardUserDefaults()

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
