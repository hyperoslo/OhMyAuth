import UIKit
import Keychain
import Sugar

public protocol Lockable {
  var accessToken: String? { get set }
  var refreshToken: String? { get set }
  var tokenType: String? { get set }
  var expirationTimestamp: NSTimeInterval? { get set }

  func clear()
}

public class Locker: Lockable {

  public let prefix = "AzureOAuth-"

  public struct KeychainKeys {
    public static let service = "\(prefix)\(Application.name)"
    public static let accessToken = "\(prefix)\(Application.name)-AccessToken"
    public static let refreshToken = "\(prefix)\(Application.name)-RefreshToken"
    public static let tokenType = "\(prefix)\(Application.name)-TokenType"
  }

  public struct UserDefaultsKeys {
    public static let expirationTimestamp = "\(prefix)\(Application.name)-ExpirationTimestamp"
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

  public var expirationTimestamp: NSTimeInterval? {
    get {
      let value = userDefaults.doubleForKey(UserDefaultsKeys.expirationTimestamp)
      return value == 0 ? nil : value
    }
    set {
      if let value = newValue {
        userDefaults.setDouble(value, forKey: UserDefaultsKeys.expirationTimestamp)
      } else {
        userDefaults.removeObjectForKey(UserDefaultsKeys.expirationTimestamp)
      }

      userDefaults.synchronize()
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

  public func clear() {
    accessToken = nil
    refreshToken = nil
    tokenType = nil
    expirationTimestamp = nil
  }
}
