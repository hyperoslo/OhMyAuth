import Foundation

@objc public class AuthContainer: NSObject {

  static var services = [String: AuthService]()

  public static func addService(service: AuthService) {
    services[service.name] = service
  }

  public static func resolveService(name: String) -> AuthService? {
    return services[name]
  }
}
