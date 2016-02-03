import Foundation
import JWTDecode
import UIKit
import SafariServices

@objc public class Authorizer: NSObject, ErrorThrowable {

  let errorDomain = "AzureOAuth.Authorizer"

  enum Error: Int, ErrorType {
    case InvalidRedirectURI = -1
    case CodeParameterNotFound = -2
  }

  private var webViewController: UIViewController?

  // MARK: - Login

  @available(iOS 9, *)
  public func login(parentController: UIViewController, forceLogout: Bool = false) -> Bool {
    guard let loginConfig = AzureOAuthConfig.loginConfig else {
      return false
    }

    if forceLogout {
      logout()
    }

    webViewController = SFSafariViewController(URL: loginConfig.loginURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return true
  }

  public func login(forceLogout: Bool = false) -> Bool {
    guard let loginConfig = AzureOAuthConfig.loginConfig else {
      return false
    }

    if forceLogout {
      logout()
    }

    UIApplication.sharedApplication().openURL(loginConfig.loginURL)

    return true
  }

  public func logout() {
    AzureOAuthConfig.locker.clear()
  }

  // MARK: - Change user

  @available(iOS 9, *)
  public func changeUser(parentController: UIViewController) {
    guard let changeUserURL = AzureOAuthConfig.loginConfig?.loginURL else {
      return
    }

    AzureOAuthConfig.locker.clear()

    webViewController = SFSafariViewController(URL: changeUserURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)
  }

  // MARK: - URL handling

  public func processUrl(url: NSURL, completion: NSError? -> Void) {
    guard let redirectURI = AzureOAuthConfig.loginConfig?.redirectURI
      where url.absoluteString.hasPrefix(redirectURI)
      else {
        completion(NSError(domain: errorDomain,
          code: Error.InvalidRedirectURI.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URI"]))
        return
    }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

    if let code = urlComponents?.queryItems?.filter({ $0.name == "code" }).first?.value {
      AzureOAuthConfig.tokenProvider.acquireAccessToken(code) { error in
        completion(error)
      }
    } else {
      completion(NSError(domain: errorDomain,
        code: Error.CodeParameterNotFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Code parameter not found"]))
    }
  }
}
