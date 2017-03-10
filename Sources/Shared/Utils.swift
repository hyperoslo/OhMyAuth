import Foundation

struct Application {
  
  static var name: String {
    guard let infoDictionary = Bundle.main.infoDictionary,
      let value = infoDictionary["CFBundleDisplayName"] as? String
      else { return "" }
    
    return value
  }
}
