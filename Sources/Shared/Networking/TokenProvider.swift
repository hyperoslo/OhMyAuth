import Foundation
import Sugar
import JWTDecode
import Alamofire

enum TokenResult {
  case Success(String)
  case Failure(ErrorType?)
}

struct TokenProvider {

  var errorDomain: String {
    return Authenticator.errorDomain
  }

  // MARK: - Networking

  func request(request: Requestable, completion: (result: TokenResult) -> Void) {
    Alamofire.request(.POST, request.URL, parameters: request.parameters, encoding: .URL).responseJSON {
      response in

      guard response.result.isSuccess else {
        completion(result: .Failure(response.result.error))
        return
      }

      guard let JSON = response.result.value as? JSONDictionary else {
        let error = NSError(domain: self.errorDomain, code: Error.NoDataInResponse.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No data in response"])
        completion(result: .Failure(error))
        return
      }

      do {
        let accessToken = try self.processTokenData(JSON)
        completion(result: .Success(accessToken))
      } catch {
        completion(result: .Failure(error))
      }
    }
  }

  // MARK: - Processing

  func processTokenData(data: JSONDictionary) throws -> String {
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
