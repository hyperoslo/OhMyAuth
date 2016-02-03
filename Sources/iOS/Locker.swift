import UIKit
import Keychain
import Sugar

public protocol Lockable {
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
  var tokenType: String? { get set }
  var expiryDate: NSDate? { get set }
  var userName: String? { get set }
  var userUPN: String? { get set }

  func clear()
}

public class Locker: Lockable {

  public static let prefix = "AzureOAuth-"

  public struct KeychainKeys {
    public static let service = "\(prefix)\(Application.name)"
    public static let accessToken = "\(prefix)\(Application.name)-AccessToken"
    public static let refreshToken = "\(prefix)\(Application.name)-RefreshToken"
    public static let tokenType = "\(prefix)\(Application.name)-TokenType"
  }

  public struct UserDefaultsKeys {
    public static let expiryDate = "\(prefix)\(Application.name)-ExpiryDate"
    public static let userName = "\(prefix)\(Application.name)-UserName"
    public static let userUPN = "\(prefix)\(Application.name)-UserUPN"
  }

  let userDefaults = NSUserDefaults.standardUserDefaults()

  // MARK: - Keychain

  public var accessToken: String? {
    get {
      return getFromKeychain(KeychainKeys.accessToken)
    }
    set {
      saveInKeychain(KeychainKeys.accessToken, newValue)
    }
  }

  public var refreshToken: String? {
    get {
      return getFromKeychain(KeychainKeys.refreshToken)
    }
    set {
      saveInKeychain(KeychainKeys.refreshToken, newValue)
    }
  }

  public var tokenType: String? {
    get {
      return getFromKeychain(KeychainKeys.tokenType)
    }
    set {
      saveInKeychain(KeychainKeys.tokenType, newValue)
    }
  }

  // MARK: - UserDefaults

  public var expiryDate: NSDate? {
    get {
      return getFromDefaults(UserDefaultsKeys.expiryDate) as NSDate?
    }
    set {
      saveInDefaults(UserDefaultsKeys.expiryDate, newValue)
    }
  }

  public var userName: String? {
    get {
      return getFromDefaults(UserDefaultsKeys.userName) as String?
    }
    set {
      saveInDefaults(UserDefaultsKeys.userName, newValue)
    }
  }

  public var userUPN: String? {
    get {
      return getFromDefaults(UserDefaultsKeys.userUPN) as String?
    }
    set {
      saveInDefaults(UserDefaultsKeys.userUPN, newValue)
    }
  }

  // MARK: - Helpers

  func getFromKeychain(key: String) -> String? {
    return Keychain.password(forAccount: key, service: KeychainKeys.service)
  }

  func saveInKeychain(key: String, _ value: String?) {
    if let value = value {
      Keychain.setPassword(value, forAccount: key, service: KeychainKeys.service)
    } else {
      Keychain.deletePassword(forAccount: key, service: KeychainKeys.service)
    }
  }

  func getFromDefaults<T>(key: String) -> T? {
    return userDefaults.objectForKey(key) as? T
  }

  func saveInDefaults(key: String, _ value: AnyObject?) {
    if let value = value {
      userDefaults.setObject(value, forKey: key)
    } else {
      userDefaults.removeObjectForKey(key)
    }

    userDefaults.synchronize()
  }

  public func clear() {
    accessToken = nil
    refreshToken = nil
    tokenType = nil
    expiryDate = nil
  }
}
