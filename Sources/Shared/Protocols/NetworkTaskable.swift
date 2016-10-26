import Malibu

protocol NetworkQueueable {}

protocol NetworkTaskable {
  associatedtype Input
  associatedtype Output

  func process(_ data: Input) throws -> Output
}

extension NetworkTaskable {

  func execute(_ request: NetworkRequestable, completion: @escaping (Result<Output>) -> Void) {
    request.start { result in
      switch result {
      case .success(let data):
        guard let data = data as? Input else {
          completion(.failure(OhMyAuthError.tokenRequestFailed.toNSError()))
          return
        }

        do {
          let output = try self.process(data)
          completion(.success(output))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
