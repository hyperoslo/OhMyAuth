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
          let error = NSError(domain: Authenticator.errorDomain,
            code: Error.NoDataInResponse.rawValue,
            userInfo: [NSLocalizedDescriptionKey: "No data in response"])
          completion(.Failure(error))
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

  var errorDomain: String {
    return Authenticator.errorDomain
  }

  func process(data: JSONDictionary) throws -> String {
    guard data["error"] == nil else {
      let error: NSError

      if let errorDescription = data["error_description"] as? String {
        error = NSError(domain: errorDomain, code: Error.AuthenticationFailed.rawValue,
          userInfo: [NSLocalizedDescriptionKey: errorDescription])
      } else {
        error = NSError(domain: errorDomain, code: Error.AuthenticationFailed.rawValue,
          userInfo: [:])
      }

      throw error
    }

    guard let accessToken = data["access_token"] as? String else {
      Authenticator.locker.clear()

      throw NSError(domain: errorDomain, code: Error.NoAccessTokenFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "No access token found"])
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      Authenticator.locker.clear()

      throw NSError(domain: errorDomain, code: Error.NoAccessTokenFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "No refresh token found"])
    }

    Authenticator.locker.accessToken = accessToken
    Authenticator.locker.refreshToken = refreshToken

    if let expiresOn = data["expires_on"] {
      Authenticator.locker.expiryDate = NSDate(timeIntervalSince1970: expiresOn.doubleValue)
    } else {
      Authenticator.locker.expiryDate = nil
    }

    if let jwtString = data["id_token"] as? String {
      do {
        let payload = try decode(jwtString)

        if let name = payload.body["name"] as? String {
          Authenticator.locker.userName = name
        }
        if let upn = payload.body["upn"] as? String {
          Authenticator.locker.userUPN = upn
        }
      } catch {}
    }

    return accessToken
  }
}
