import Foundation
import UIKit
import SafariServices

@objc public class Authorizer: NSObject {

  private var webViewController: UIViewController?

  // MARK: - Login

  @available(iOS 9, *)
  public func login(parentController: UIViewController, forceLogout: Bool = false) -> Bool {
    guard let loginConfig = Authenticator.loginConfig else {
      return false
    }

    if forceLogout {
      Authenticator.logout()
    }

    webViewController = SFSafariViewController(URL: loginConfig.loginURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return true
  }

  public func login(forceLogout: Bool = false) -> Bool {
    guard let loginConfig = Authenticator.loginConfig else {
      return false
    }

    if forceLogout {
      Authenticator.logout()
    }

    UIApplication.sharedApplication().openURL(loginConfig.loginURL)

    return true
  }

  // MARK: - Change user

  @available(iOS 9, *)
  public func changeUser(parentController: UIViewController) {
    guard let changeUserURL = Authenticator.loginConfig?.loginURL else {
      return
    }

    Authenticator.locker.clear()

    webViewController = SFSafariViewController(URL: changeUserURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)
  }

  // MARK: - URL handling

  public func processUrl(url: NSURL, completion: NSError? -> Void) {
    let errorDomain = Authenticator.errorDomain

    guard let redirectURI = Authenticator.loginConfig?.redirectURI
      where url.absoluteString.hasPrefix(redirectURI)
      else {
        completion(NSError(domain: errorDomain,
          code: Error.InvalidRedirectURI.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URI"]))
        return
    }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

    if let code = urlComponents?.queryItems?.filter({ $0.name == "code" }).first?.value {
      do {
        let request = try AccessTokenRequest(code: code)

        TokenProvider().request(request) { result in
          switch result {
          case .Failure(let error):
            completion(error as? NSError)
          default:
            completion(nil)
          }
        }
      } catch {
        completion(error as NSError)
      }
    } else {
      completion(NSError(domain: errorDomain,
        code: Error.CodeParameterNotFound.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Code parameter not found"]))
    }
  }
}
