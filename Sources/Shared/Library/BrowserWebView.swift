import Foundation

#if os(iOS) || os(tvOS)
  import UIKit
#elseif os(OSX)
  import Cocoa
#endif

@objc open class BrowserWebView: NSObject, WebViewable {

  open func open(_ URL: Foundation.URL) {
    #if os(iOS)
      UIApplication.sharedApplication().openURL(URL)
    #elseif os(OSX)
      NSWorkspace.shared().open(URL)
    #endif
  }
}
