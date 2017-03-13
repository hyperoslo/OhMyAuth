import XCTest
@testable import OhMyAuth

class ServiceTests: XCTestCase {

  class LockerMock: Lockable {
    var accessToken: String?
    var refreshToken: String?
    var tokenType: String?
    var expiryDate: Date?
    var userName: String?
    var userUPN: String?

    required init(name: String) {

    }

    func clear() {

    }

    @discardableResult func synchronize() -> Bool {
      return false
    }
  }

  var locker: LockerMock!
  var config: AuthConfig!
  var service: AuthService!

  override func setUp() {
    super.setUp()

    locker = LockerMock(name: "locker")
    config = AuthConfig(clientId: "", accessTokenUrl: URL(string: "http://testservice.no")!)
    config.minimumValidity = 5
    service = AuthService(name: "service", config: config, locker: locker)
  }

  func testBeforeExpiredDate() {
    locker.expiryDate = Date(timeIntervalSinceNow: 1)
    XCTAssertTrue(service.tokenIsExpired)

    locker.expiryDate = Date(timeIntervalSinceNow: 2)
    XCTAssertTrue(service.tokenIsExpired)

    locker.expiryDate = Date(timeIntervalSinceNow: 5)
    XCTAssertTrue(service.tokenIsExpired)

    locker.expiryDate = Date(timeIntervalSinceNow: 6)
    XCTAssertFalse(service.tokenIsExpired)
  }

  func testExactExpiredDate() {
    locker.expiryDate = Date()
    XCTAssertTrue(service.tokenIsExpired)
  }

  func testAfterExpiredDate() {
    locker.expiryDate = Date(timeIntervalSinceNow: -1)
    XCTAssertTrue(service.tokenIsExpired)
  }
}
