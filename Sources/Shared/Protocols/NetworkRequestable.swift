import Foundation
import Malibu

protocol NetworkRequestable: POSTRequestable {
  var networking: Networking { get }
}

extension NetworkRequestable {

  func start(_ completion: @escaping (_ result: Result<Any>) -> Void) {
    networking
      .POST(self)
      .toJsonDictionary()
      .always({ (result) in
        switch result {
        case .success(let value):
          
          break
        case .failure(let error):
          
          break
        }
      })
  }
}
