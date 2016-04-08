protocol NetworkQueueable {}

protocol NetworkTaskable {
  associatedtype Input
  associatedtype Output

  func process(data: Input) throws -> Output
}

extension NetworkTaskable {

  func execute(request: NetworkRequestable, completion: Result<Output> -> Void) {
    request.start { result in
      switch result {
      case .Success(let data):
        guard let data = data as? Input else {
          completion(.Failure(Error.NoDataInResponse.toNSError()))
          return
        }

        do {
          let output = try self.process(data)
          completion(.Success(output))
        } catch {
          completion(.Failure(error))
        }
      case .Failure(let error):
        completion(.Failure(error))
      }
    }
  }
}
