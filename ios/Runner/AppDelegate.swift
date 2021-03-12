import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
      return true
    }
}
