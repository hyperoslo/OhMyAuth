import XCTest
import OhMyAuth

class Tests: XCTestCase {

  func testLockerWithName() {
    let locker = UserDefaultsLocker(name: "app")
    XCTAssertEqual(locker.name, "app")
  }

  func testLockerWithService() {
    let locker = UserDefaultsLocker(name: "app")
    locker.service = "service"
    XCTAssertEqual(locker.service, "service")
  }
}
