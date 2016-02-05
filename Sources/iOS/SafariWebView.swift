import UIKit
import SafariServices
import Sugar

@available(iOS 9, *)
@objc public class SafariWebView: NSObject, WebViewable {

  public var animated: Bool
  let viewController: UIViewController

  public init(viewController: UIViewController, animated: Bool = true) {
    self.viewController = viewController
    self.animated = animated
  }

  public func open(URL: NSURL) {
    let webViewController = SFSafariViewController(URL: URL)
    viewController.presentViewController(webViewController, animated: animated, completion: nil)
  }

  public func close() {
    dispatch {
      UIApplication.presentedViewController()?.dismissViewControllerAnimated(true, completion: nil)
    }
  }
}
