import Foundation
import JWTDecode
import UIKit
import SafariServices

@objc public class Authorizer: NSObject {

  enum Error: Int {
    case CodeParameterNotFound = -1
  }

  private var webViewController: UIViewController?

  // MARK: - Login

  @available(iOS 9, *)
  public func login(parentController: UIViewController, forceLogout: Bool = false) {
    guard let loginConfig = AzureOAuthConfig.loginConfig else {
      return
    }

    if forceLogout {
      logout()
    }

    webViewController = SFSafariViewController(URL: loginConfig.loginURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)
  }

  public func login(forceLogout: Bool = false) {
    guard let loginConfig = AzureOAuthConfig.loginConfig else {
      return
    }

    if forceLogout {
      logout()
    }

    UIApplication.sharedApplication().openURL(loginConfig.loginURL)
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

  public func processUrl(url: NSURL, completion: NSError? -> Void) throws -> Bool {
    guard let redirectURI = AzureOAuthConfig.loginConfig?.redirectURI
      where url.absoluteString.hasPrefix(redirectURI)
      else { return false }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

    if let code = urlComponents?.queryItems?.filter({ $0.name == "code" }).first?.value {
      //requestAccessToken(code, completion: { error in
      //  completion(error)
      //})
    } else {
      //completion(NSError(domain: ErrorDomain, code: Error.CodeParameterNotFound.rawValue, userInfo: [NSLocalizedDescriptionKey: "code parameter not found"]))
    }

    return true
  }
}
