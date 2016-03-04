import Foundation

@objc public class UserDefaultsLocker: NSObject, Lockable {

  let name: String
  let userDefaults = NSUserDefaults.standardUserDefaults()

  public required init(name: String) {
    self.name = name
  }

  // MARK: - Getters and setters

  public var accessToken: String? {
    get { return getFromDefaults(Keys.accessToken) }
    set { saveInDefaults(Keys.accessToken, newValue) }
  }

  public var refreshToken: String? {
    get { return getFromDefaults(Keys.refreshToken) }
    set { saveInDefaults(Keys.refreshToken, newValue) }
  }

  public var tokenType: String? {
    get { return getFromDefaults(Keys.tokenType) }
    set { saveInDefaults(Keys.tokenType, newValue) }
  }

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
