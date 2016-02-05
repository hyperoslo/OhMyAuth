import UIKit

extension UIApplication {

  class func presentedViewController(rootController: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {

    if let navigationController = rootController as? UINavigationController {
      return presentedViewController(navigationController.visibleViewController)
    }

    if let tabBarController = rootController as? UITabBarController {
      if let selectedController = tabBarController.selectedViewController {
        return presentedViewController(selectedController)
      }
    }

    if let presented = rootController?.presentedViewController {
      return presentedViewController(presented)
    }

    return rootController
  }
}
