import Foundation

@objc public protocol WebViewable {
  func open(URL: NSURL)
  optional func close()
}

