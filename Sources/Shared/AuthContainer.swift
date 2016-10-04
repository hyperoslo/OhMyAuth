import Foundation

@objc open class AuthContainer: NSObject {

  static var services = [String: AuthService]()

  // MARK: - Services

  open static func addService(_ service: AuthService) {
    services[service.name] = service
  }

  open static func serviceNamed(_ name: String) -> AuthService? {
    return services[name]
  }

  // MARK: - Helpers

  open static func locker(_ serviceName: String) -> Lockable? {
    return serviceNamed(serviceName)?.locker
  }
}
