import Foundation
import Keychain

struct Keys {

  static let service = "\(Application.name)"
  static let accessToken = "\(Application.name)-AccessToken"
  static let refreshToken = "\(Application.name)-RefreshToken"
  static let tokenType = "\(Application.name)-TokenType"
  static let expiryDate = "\(Application.name)-ExpiryDate"
  static let userName = "\(Application.name)-UserName"
  static let userUPN = "\(Application.name)-UserUPN"
}

@objc open class KeychainLocker: UserDefaultsLocker {

  public required init(name: String) {
    super.init(name: name)
  }

  // MARK: - Keychain

  open override var accessToken: String? {
    get { return getFromKeychain(Keys.accessToken) }
    set { saveInKeychain(Keys.accessToken, newValue) }
  }

  open override var refreshToken: String? {
    get { return getFromKeychain(Keys.refreshToken) }
    set { saveInKeychain(Keys.refreshToken, newValue) }
  }

  open override var tokenType: String? {
    get { return getFromKeychain(Keys.tokenType) }
    set { saveInKeychain(Keys.tokenType, newValue) }
  }

  // MARK: - Helpers

  func getFromKeychain(_ key: String) -> String? {
    let namedKey = generateKey(key)
    let password = Keychain.password(forAccount: namedKey, service: Keys.service)

    return !password.isEmpty ? password : nil
  }

  func saveInKeychain(_ key: String, _ value: String?) {
    let namedKey = generateKey(key)

    if let value = value {
      Keychain.setPassword(value, forAccount: namedKey, service: Keys.service)
    } else {
      Keychain.deletePassword(forAccount: namedKey, service: Keys.service)
    }
  }
}
