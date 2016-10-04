import Foundation

@objc public protocol WebViewable {
  func open(_ URL: URL)
  @objc optional func close()
}

