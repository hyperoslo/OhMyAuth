import Foundation
import UIKit
import SafariServices

@objc public class CodePrivider: NSObject {

  private var webViewController: UIViewController?

  let config: AuthConfig
  let locker: Lockable

  // MARK: - Initialization

  public init(config: AuthConfig, locker: Lockable) {
    self.config = config
    self.locker = locker
  }

  // MARK: - Login

  @available(iOS 9, *)
  public func authorize(parentController: UIViewController, forceLogout: Bool = false) -> Bool {
    guard let authorizeURL = config.authorizeURL else {
      return false
    }

    if forceLogout {
      locker.clear()
    }

    webViewController = SFSafariViewController(URL: authorizeURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return true
  }

  public func authorize(forceLogout: Bool = false) -> Bool {
    guard let authorizeURL = config.authorizeURL else {
      return false
    }

    if forceLogout {
      locker.clear()
    }

    UIApplication.sharedApplication().openURL(authorizeURL)

    return true
  }

  // MARK: - Change user

  @available(iOS 9, *)
  public func changeUser(parentController: UIViewController) {
    guard let changeUserURL = config.changeUserURL else {
      return
    }

    locker.clear()

    webViewController = SFSafariViewController(URL: changeUserURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)
  }

  // MARK: - URL handling

  public func acquireTokenWithCode(url: NSURL, completion: NSError? -> Void) {
    guard let redirectURI = config.redirectURI
      where url.absoluteString.hasPrefix(redirectURI)
      else {
        completion(Error.InvalidRedirectURI.toNSError())
        return
    }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

    if let code = urlComponents?.queryItems?.filter({ $0.name == "code" }).first?.value {
      let request = AccessTokenRequest(config: config, parameters: ["code" : code])

      TokenNetworkTask(locker: locker).execute(request) { result in
        switch result {
        case .Failure(let error):
          completion(error as? NSError)
        default:
          completion(nil)
        }
      }
    } else {
      completion(Error.CodeParameterNotFound.toNSError())
    }
  }
}
