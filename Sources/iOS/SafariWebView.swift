import UIKit
import SafariServices

@available(iOS 9, *)
@objc public class SafariWebView: NSObject, WebViewable {

  public var animated: Bool
  let viewController: UIViewController
  var dismissWebController: (Void -> Void)?

  init(viewController: UIViewController, animated: Bool = true) {
    self.viewController = viewController
    self.animated = animated
  }

  public func open(URL: NSURL) {
    let webViewController = SFSafariViewController(URL: URL)
    viewController.presentViewController(webViewController, animated: animated, completion: nil)

    dismissWebController = {
      webViewController.dismissViewControllerAnimated(true, completion: nil)
    }
  }

  public func close() {
    dismissWebController?()
  }
}
