import Foundation

#if os(iOS) || os(tvOS)
  import UIKit
#elseif os(OSX)
  import AppKit
#endif

@objc public class BrowserWebView: NSObject, WebViewable {

  public func open(URL: NSURL) {
    #if os(iOS)
      UIApplication.sharedApplication().openURL(URL)
    #elseif os(OSX)
      NSWorkspace.sharedWorkspace().openURL(url)
    #endif
  }
}
