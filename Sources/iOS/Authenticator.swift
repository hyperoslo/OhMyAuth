import Foundation
import UIKit
import SafariServices

@objc public class Authenticator: NSObject {

  private var webViewController: UIViewController?

  // MARK: - Login

  @available(iOS 9, *)
  public func authorize(parentController: UIViewController, forceLogout: Bool = false) -> Bool {
    guard let loginConfig = AuthConfig.loginConfig else {
      return false
    }

    if forceLogout {
      Authenticator.logout()
    }

    webViewController = SFSafariViewController(URL: loginConfig.loginURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return true
  }

  public func authorize(forceLogout: Bool = false) -> Bool {
    guard let loginConfig = AuthConfig.loginConfig else {
      return false
    }

    if forceLogout {
      Authenticator.logout()
    }

    UIApplication.sharedApplication().openURL(loginConfig.loginURL)

    return true
  }

  public static func logout() {
    AuthContainer.locker.clear()
  }

  // MARK: - Change user

  @available(iOS 9, *)
  public func changeUser(parentController: UIViewController) {
    guard let changeUserURL = AuthConfig.loginConfig?.loginURL else {
      return
    }

    Authenticator.logout()

    webViewController = SFSafariViewController(URL: changeUserURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)
  }

  // MARK: - URL handling

  public func processUrl(url: NSURL, completion: NSError? -> Void) {
    guard let redirectURI = AuthConfig.loginConfig?.redirectURI
      where url.absoluteString.hasPrefix(redirectURI)
      else {
        completion(Error.InvalidRedirectURI.toNSError())
        return
    }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

    if let code = urlComponents?.queryItems?.filter({ $0.name == "code" }).first?.value {
      do {
        let request = try AccessTokenRequest(code: code)

        TokenNetworkTask().execute(request) { result in
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
      completion(Error.CodeParameterNotFound.toNSError())
    }
  }
}
