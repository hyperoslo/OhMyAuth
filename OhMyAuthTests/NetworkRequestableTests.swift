import Foundation
import XCTest
@testable import OhMyAuth

final class NetworkRequestableTests: XCTestCase {
  func testSuccessfulResult() throws {
    let networking = NetworkingMock(configuration: .default)
    networking.data = try JSONSerialization.data(withJSONObject: [:], options: [])
    networking.response = HTTPURLResponse()

    var result: Result<Any>?
    let request = RequestMock()
    request.start(using: networking) { result = $0 }

    switch result {
    case .some(.success(let object)):
      // Since we get an untyped object from the API, we need to use reflection for verification
      XCTAssertEqual(String(reflecting: object), String(reflecting: [:]))
    default:
      XCTFail("Unexpected result: \(String(describing: result))")
    }
  }

  func testOfflineErrorReturnedAsResult() {
    let networking = NetworkingMock(configuration: .default)
    networking.error = NSError(
      domain: NSURLErrorDomain,
      code: URLError.notConnectedToInternet.rawValue,
      userInfo: nil
    )

    var result: Result<Any>?
    let request = RequestMock()
    request.start(using: networking) { result = $0 }

    switch result {
    case .some(.failure(let error as NSError)):
      XCTAssertEqual(error.code, URLError.notConnectedToInternet.rawValue)
    default:
      XCTFail("Unexpected result: \(String(describing: result))")
    }
  }
}

private extension NetworkRequestableTests {
  struct RequestMock: NetworkRequestable {
    let url = URL(string: "https://www.hyper.no")!
    let parameters = [String: Any]()
    let headers = [String: String]()
  }

  class NetworkingMock: Networking {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    override func post(url: URL, parameters: [String : Any], headers: [String : String], completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
      completion(data, response, error)
    }
  }
}
