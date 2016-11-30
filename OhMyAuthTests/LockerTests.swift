import XCTest
import OhMyAuth

class LockerTests: XCTestCase {

  func testLockerWithName() {
    let locker = UserDefaultsLocker(name: "app")
    XCTAssertEqual(locker.name, "app")
    print(locker.service)
  }

  func testLockerWithService() {
    let locker = UserDefaultsLocker(name: "app")
    locker.service = "service"
    XCTAssertEqual(locker.service, "service")
  }

  func testUserDefaultsLocker() {
    let locker = UserDefaultsLocker(name: "app")
    locker.service = "service"

    let uuid = NSUUID().uuidString
    locker.accessToken = uuid

    XCTAssertEqual(locker.accessToken, uuid)

    XCTAssertEqual(locker.generateKey(Keys.accessToken), "app-service-\(Keys.accessToken)")
    XCTAssertEqual(locker.generateKey(Keys.expiryDate), "app-service-\(Keys.expiryDate)")
    XCTAssertEqual(locker.generateKey("custom-key"), "app-service-custom-key")
  }

  func testSuiteLocker() {
    let suiteName = "group.com.hyper.OhMyAuth"
    let locker = SuiteDefaultsLocker(name: "app", suiteName: suiteName)

    XCTAssertEqual(locker.suiteName, suiteName)
    XCTAssertEqual(locker.generateKey(Keys.accessToken), "app-\(suiteName)-\(Keys.accessToken)")
    XCTAssertEqual(locker.generateKey(Keys.expiryDate), "app-\(suiteName)-\(Keys.expiryDate)")
    XCTAssertEqual(locker.generateKey("custom-key"), "app-\(suiteName)-custom-key")
  }
}
