import Foundation
import Sugar
import Alamofire
import JWTDecode

@objc public class TokenProvider: NSObject, ErrorThrowable {

  public static let minimumValidity: NSTimeInterval = 5 * 60
  let errorDomain = "AzureOAuth.TokenProvider"

  @objc enum Error: Int, ErrorType {
    case NoConfigFound = -1
    case NoDataInResponse = -2
    case AuthenticationFailed = -3
    case ExpirationDateNotFound = -4
    case NoAccessTokenFound = -5
    case NoRefreshTokenFound = -6
  }

  public func accessToken(completion: (String?, NSError?) -> Void) {
    guard let expiryDate = AzureOAuthConfig.locker.expiryDate else {
      let error = NSError(domain: errorDomain, code: Error.ExpirationDateNotFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Expiration date not found"])

      completion(nil, error)
      return
    }

    guard expiryDate.timeIntervalSinceNow < TokenProvider.minimumValidity else {
      completion(AzureOAuthConfig.locker.accessToken, nil)
      return
    }

    refreshAccessToken { (accessToken, error) in
      completion(accessToken, error as? NSError)
    }
  }

  // MARK: - Requests

  func acquireAccessToken(code: String, completion: (String?, ErrorType?) -> Void) {
    guard let tokenConfig = AzureOAuthConfig.tokenConfig,
      loginConfig = AzureOAuthConfig.loginConfig
      else {
        completion(nil, NSError(domain: errorDomain, code: Error.NoConfigFound.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No token or login config provided"]))
        return
    }

    let parameters = [
      "client_id" : tokenConfig.clientId,
      "code" : code,
      "grant_type" : tokenConfig.accessGrantType,
      "resource" : tokenConfig.resource,
      "redirect_uri": loginConfig.redirectURI
    ]


    Alamofire.request(.POST, tokenConfig.URL, parameters: parameters, encoding: .URL).responseJSON {
      [weak self] response in

      guard let weakSelf = self where response.result.isSuccess else {
        completion(nil, response.result.error)
        return
      }

      guard let JSON = response.result.value as? JSONDictionary else {
        completion(nil, NSError(domain: weakSelf.errorDomain, code: Error.NoDataInResponse.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
        return
      }

      do {
        let accessToken = try weakSelf.processTokenData(JSON)
        completion(accessToken, nil)
      } catch {
        completion(nil, error)
      }
    }
  }

  func refreshAccessToken(completion: (String?, ErrorType?) -> Void) {
    guard let tokenConfig = AzureOAuthConfig.tokenConfig,
      loginConfig = AzureOAuthConfig.loginConfig
      else {
        completion(nil, NSError(domain: errorDomain, code: Error.NoConfigFound.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No token or login config provided"]))
        return
    }

    guard let refreshToken = AzureOAuthConfig.locker.refreshToken else {
      completion(nil, NSError(domain: errorDomain,
        code: Error.NoRefreshTokenFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "No refresh token found"]))
      return
    }

    let parameters = [
      "client_id" : tokenConfig.clientId,
      "grant_type": tokenConfig.refreshGrantType,
      "refresh_token": refreshToken,
      "resource": tokenConfig.resource,
      "redirect_uri": loginConfig.redirectURI
    ]

    Alamofire.request(.POST, tokenConfig.URL, parameters: parameters, encoding: .URL).responseJSON {
      [weak self ] response in

      guard let weakSelf = self where response.result.isSuccess else {
        completion(nil, response.result.error)
        return
      }

      guard let JSON = response.result.value as? JSONDictionary else {
        completion(nil, NSError(domain: weakSelf.errorDomain, code: Error.NoDataInResponse.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
        return
      }

      do {
        let accessToken = try weakSelf.processTokenData(JSON)
        completion(accessToken, nil)
      } catch {
        completion(nil, error)
      }
    }
  }

  // MARK: - Processing

  private func processTokenData(data: JSONDictionary) throws -> String {
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
      AzureOAuthConfig.locker.clear()

      throw NSError(domain: errorDomain, code: Error.NoAccessTokenFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "No access token found"])
    }

    guard let refreshToken = data["refresh_token"] as? String else {
      AzureOAuthConfig.locker.clear()

      throw NSError(domain: errorDomain, code: Error.NoAccessTokenFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "No refresh token found"])
    }

    AzureOAuthConfig.locker.accessToken = accessToken
    AzureOAuthConfig.locker.refreshToken = refreshToken

    if let expiresOn = data["expires_on"] {
      AzureOAuthConfig.locker.expiryDate = NSDate(timeIntervalSince1970: expiresOn.doubleValue)
    } else {
      AzureOAuthConfig.locker.expiryDate = nil
    }

    if let jwtString = data["id_token"] as? String {
      do {
        let payload = try decode(jwtString)

        if let name = payload.body["name"] as? String {
          AzureOAuthConfig.locker.userName = name
        }
        if let upn = payload.body["upn"] as? String {
          AzureOAuthConfig.locker.userUPN = upn
        }
      } catch {}
    }

    return accessToken
  }
}
