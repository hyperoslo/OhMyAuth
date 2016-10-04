import Foundation

@objc open class UserDefaultsLocker: NSObject, Lockable {

  let name: String
  let userDefaults = UserDefaults.standard

  public required init(name: String) {
    self.name = name
  }

  // MARK: - Getters and setters

  open var accessToken: String? {
    get { return getFromDefaults(Keys.accessToken) }
    set { saveInDefaults(Keys.accessToken, newValue as AnyObject?) }
  }

  open var refreshToken: String? {
    get { return getFromDefaults(Keys.refreshToken) }
    set { saveInDefaults(Keys.refreshToken, newValue as AnyObject?) }
  }

  open var tokenType: String? {
    get { return getFromDefaults(Keys.tokenType) }
    set { saveInDefaults(Keys.tokenType, newValue as AnyObject?) }
  }

  open var expiryDate: Date? {
    get { return getFromDefaults(Keys.expiryDate) as Date? }
    set { saveInDefaults(Keys.expiryDate, newValue as AnyObject?) }
  }

  open var userName: String? {
    get { return getFromDefaults(Keys.userName) as String? }
    set { saveInDefaults(Keys.userName, newValue as AnyObject?) }
  }

  open var userUPN: String? {
    get { return getFromDefaults(Keys.userUPN) as String? }
    set { saveInDefaults(Keys.userUPN, newValue as AnyObject?) }
  }

  // MARK: - Helpers

  @discardableResult open func synchronize() -> Bool {
    return userDefaults.synchronize()
  }

  func getFromDefaults<T>(_ key: String) -> T? {
    let namedKey = generateKey(key)
    return userDefaults.object(forKey: namedKey) as? T
  }

  func saveInDefaults(_ key: String, _ value: AnyObject?) {
    let namedKey = generateKey(key)

    if let value = value {
      userDefaults.set(value, forKey: namedKey)
    } else {
      userDefaults.removeObject(forKey: namedKey)
    }
  }

  func generateKey(_ key: String) -> String {
    return "\(name)-\(key)"
  }

  // MARK: - Clear

  open func clear() {
    accessToken = nil
    refreshToken = nil
    tokenType = nil
    expiryDate = nil
    userName = nil
    userUPN = nil
  }
}
