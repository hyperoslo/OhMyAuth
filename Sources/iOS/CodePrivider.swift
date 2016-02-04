import Foundation
import UIKit
import SafariServices

@objc public class CodePrivider: NSObject {

  private var webViewController: UIViewController?

  let config: AuthConfig
  let locker: Lockable
  let tokenProvider: TokenProvider

  // MARK: - Initialization

  public init(config: AuthConfig, locker: Lockable, tokenProvider: TokenProvider) {
    self.config = config
    self.locker = locker
    self.tokenProvider = tokenProvider
  }

  // MARK: - Login

  @available(iOS 9, *)
  public func authorize(parentController: UIViewController, forceLogout: Bool = false) -> UIViewController? {
    guard let authorizeURL = config.authorizeURL else {
      return nil
    }

    if forceLogout {
      locker.clear()
    }

    webViewController = SFSafariViewController(URL: authorizeURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return webViewController
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
  public func changeUser(parentController: UIViewController) -> UIViewController? {
    guard let changeUserURL = config.changeUserURL else {
      return nil
    }

    locker.clear()

    webViewController = SFSafariViewController(URL: changeUserURL)
    parentController.presentViewController(webViewController!, animated: true, completion: nil)

    return webViewController
  }

  // MARK: - URL handling

  public func acquireTokenFrom(URL: NSURL, completion: NSError? -> Void) {
    guard let redirectURI = config.redirectURI,
      URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false),
      code = URLComponents.queryItems?.filter({ $0.name == "code" }).first?.value
      where URL.absoluteString.hasPrefix(redirectURI)
      else {
        completion(Error.CodeParameterNotFound.toNSError())
        return
    }

    tokenProvider.acquireAccessToken(["code" : code]) { accessToken, error in
      completion(error)
    }
  }
}
