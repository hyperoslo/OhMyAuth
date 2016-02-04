import Foundation

@objc public class AuthContainer: NSObject {

  static var services = [String: AuthService]()

  // MARK: - Services

  public static func addService(service: AuthService) {
    services[service.name] = service
  }

  public static func serviceNamed(name: String) -> AuthService? {
    return services[name]
  }

  // MARK: - Helpers

  public static func locker(serviceName: String) -> Lockable? {
    return serviceNamed(serviceName)?.locker
  }
}
