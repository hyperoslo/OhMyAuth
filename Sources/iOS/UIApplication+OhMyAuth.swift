import UIKit

extension UIApplication {

  class func presentedViewController(rootController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

    if let navigationController = rootController as? UINavigationController {
      return presentedViewController(rootController: navigationController.visibleViewController)
    }

    if let tabBarController = rootController as? UITabBarController {
      if let selectedController = tabBarController.selectedViewController {
        return presentedViewController(rootController: selectedController)
      }
    }

    if let presented = rootController?.presentedViewController {
      return presentedViewController(rootController: presented)
    }

    return rootController
  }
}
