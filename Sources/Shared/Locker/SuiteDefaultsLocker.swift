import Foundation

@objc open class SuiteDefaultsLocker: NSObject, Lockable {

  public let name: String
  public let suiteName: String
  public let userDefaults: UserDefaults!

  public init(name: String, suiteName: String) {
    self.name = name
    self.suiteName = suiteName
    self.userDefaults = UserDefaults(suiteName: suiteName)
  }

  public required init(name: String) {
    self.name = name
    self.suiteName = name
    self.userDefaults = UserDefaults(suiteName: suiteName)
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

  open func synchronize() -> Bool {
    return userDefaults.synchronize()
  }

  public func getFromDefaults<T>(_ key: String) -> T? {
    let namedKey = generateKey(key)
    return userDefaults.object(forKey: namedKey) as? T
  }

  public func saveInDefaults(_ key: String, _ value: AnyObject?) {
    let namedKey = generateKey(key)

    if let value = value {
      userDefaults.set(value, forKey: namedKey)
    } else {
      userDefaults.removeObject(forKey: namedKey)
    }
  }

  public func generateKey(_ key: String) -> String {
    return "\(name)-\(suiteName)-\(key)"
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
