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

  // MARK: - Helper

  public static func locker(serviceName: String) -> Lockable? {
    return serviceNamed(serviceName)?.locker
  }

  public static func tokenProvider(serviceName: String) -> TokenProvider? {
    return serviceNamed(serviceName)?.tokenProvider
  }

  public static func codePrivider(serviceName: String) -> CodePrivider? {
    return serviceNamed(serviceName)?.codeProvider
  }
}
