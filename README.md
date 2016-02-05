# OhMyAuth

[![CI Status](http://img.shields.io/travis/hyperoslo/OhMyAuth.svg?style=flat)](https://travis-ci.org/hyperoslo/OhMyAuth)
[![Version](https://img.shields.io/cocoapods/v/OhMyAuth.svg?style=flat)](http://cocoadocs.org/docsets/OhMyAuth)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/OhMyAuth.svg?style=flat)](http://cocoadocs.org/docsets/OhMyAuth)
[![Platform](https://img.shields.io/cocoapods/p/OhMyAuth.svg?style=flat)](http://cocoadocs.org/docsets/OhMyAuth)

## Description

Simple `OAuth2` library with a support of multiple services.

## Usage

- Setup:
```swift
let config = AuthConfig(
  clientId: "client-id",
  accessTokenUrl: NSURL(string: "access-token-url")!,
  accessGrantType: "authorization_code",
  authorizeURL: NSURL(string: "authorise-url")!,
  changeUserURL: NSURL(string: "change-user-url")!,
  redirectURI: "yourapp://auth")

config.extraAccessTokenParameters = ["resource": "resource"]
config.extraRefreshTokenParameters = ["resource": "resource"]

let service = AuthService(name: "service", config: config)
AuthContainer.addService(service)
```

- Safari app will be opened by default for authorization, if it's iOS9 and you'd
like to use `SFSafariViewController`, there is a ready-to-use class for you:
```swift
// SFSafariViewController will be presented on top of provided controller
service.config.webView = SafariWebView(viewController: viewController)
```

- Show a login web page:
```swift
AuthContainer.serviceNamed("service")?.authorize()
```

- Handle response. If you use `SafariWebView` it will be dismissed ***automagically***:
```swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
   AuthContainer.serviceNamed("service")?.accessToken(URL: url) { accessToken, error in
      if let accessToken = accessToken where error == nil {
         // User is logged in!!!
      }
   }
}
```

- Get an access token to include it in the each request. If token is about to
expire it will be refreshed ***automagically***, so you always get an active
token is the completion closure:
```swift
AuthContainer.serviceNamed("service")?.accessToken(completion)
```

- If you need to change user and have a separate URL for that:
```swift
AuthContainer.serviceNamed("service")?.changeUser()
```

- If you don't have authorisation by code, but by username and password,
there is a flow:
```swift
let config = AuthConfig(
  clientId: "client-id",
  accessTokenUrl: NSURL(string: "access-token-url")!,
  accessGrantType: "password")

let service = AuthService(name: "service", config: config)
AuthContainer.addService(service)

let parameters = ["username": "weirdo", "password": "123456"]
service.accessToken(parameters: parameters) { accessToken, error in
 // Ready!
}
```

- If you need to get your tokens, expiry date, username, user UPN:
```swift
let accessToken = AuthContainer.serviceNamed("service")?.locker.accessToken
let userUPN = AuthContainer.serviceNamed("service")?.locker.userUPN
```

And yeah, you could add as many auth services as you want if you have some
crazy setup in the app. Just register a new one with a different name:
```swift
let service = AuthService(name: "another-service", config: config)
```

## Author

Hyper Interaktiv AS, ios@hyper.no

## Installation

**OhMyAuth** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OhMyAuth'
```

**OhMyAuth** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/OhMyAuth"
```

## Author

Hyper Interaktiv AS, ios@hyper.no

## Contributing

We would love you to contribute to **OhMyAuth**, check the [CONTRIBUTING](https://github.com/hyperoslo/OhMyAuth/blob/master/CONTRIBUTING.md) file for more info.

## License

**OhMyAuth** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/OhMyAuth/blob/master/LICENSE.md) file for more info.
