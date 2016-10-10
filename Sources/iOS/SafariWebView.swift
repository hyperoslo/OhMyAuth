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

  public func open(_ url: URL) {
    let webViewController = SFSafariViewController(url: url)
    viewController.present(webViewController, animated: animated, completion: nil)
  }

  public func close() {
    dispatch {
      UIApplication.presentedViewController()?.dismiss(animated: true, completion: nil)
    }
  }
}
