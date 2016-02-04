import Foundation
import Sugar
import JWTDecode

enum Result<T> {
  case Success(T)
  case Failure(ErrorType?)
}

protocol NetworkQueueable {}

protocol NetworkTaskable {
  typealias Input
  typealias Output

  func process(data: Input) throws -> Output
}

extension NetworkTaskable {

  func execute(request: Requestable, completion: Result<Output> -> Void) {
    request.start { result in
      switch result {
      case .Failure(let error):
        completion(.Failure(error))
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
      }
    }
  }
}

struct TokenNetworkTask: NetworkTaskable, NetworkQueueable {

  func process(data: JSONDictionary) throws -> String {
    guard data["error"] == nil else {
      throw Error.TokenRequestFailed.toNSError(data["error_description"] as? String)
    }

    guard let accessToken = data["access_token"] as? String else {
      AuthContainer.locker.clear()
      throw Error.NoAccessTokenFound.toNSError()
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      AuthContainer.locker.clear()
      throw Error.NoAccessTokenFound.toNSError()
    }

    AuthContainer.locker.accessToken = accessToken
    AuthContainer.locker.refreshToken = refreshToken

    if let expiresOn = data["expires_on"] {
      AuthContainer.locker.expiryDate = NSDate(timeIntervalSince1970: expiresOn.doubleValue)
    } else {
      AuthContainer.locker.expiryDate = nil
    }

    if let jwtString = data["id_token"] as? String {
      do {
        let payload = try decode(jwtString)

        if let name = payload.body["name"] as? String {
          AuthContainer.locker.userName = name
        }
        if let upn = payload.body["upn"] as? String {
          AuthContainer.locker.userUPN = upn
        }
      } catch {}
    }

    return accessToken
  }
}
