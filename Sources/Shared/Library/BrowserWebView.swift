import Foundation

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

@objc open class BrowserWebView: NSObject, WebViewable {

  open func open(_ URL: Foundation.URL) {
    #if os(iOS)
      UIApplication.shared.openURL(URL)
    #elseif os(OSX)
      NSWorkspace.shared.open(URL)
    #endif
  }
}
