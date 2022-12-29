import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let CHANNEL = "com.mwbconnect.app/api"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let apiChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
    apiChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        switch call.method {
            case "getHTTP":
                let session = URLSession.shared
                let args = call.arguments as! NSDictionary
                let url = args["url"] as! String
                let accessToken = args["accessToken"] as? String

                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "GET"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                
                let task = session.dataTask(with: request) { data, response, error in
                    var statusCode = 200
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                    }
                    result([
                        "data": String(data: data!, encoding: .utf8)!,
                        "statusCode": String(statusCode)
                    ]);
                }

                task.resume()
        
            case "postHTTP":
                let session = URLSession.shared
                let args = call.arguments as! NSDictionary
                let url = args["url"] as! String
                let data = args["data"] as? Dictionary<String, Any>
                let accessToken = args["accessToken"] as? String

                let jsonData = try? JSONSerialization.data(withJSONObject: data)
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                request.httpBody = jsonData
                
                let task = session.dataTask(with: request) { data, response, error in
                    var statusCode = 200
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                    }
                    result([
                        "data": String(data: data!, encoding: .utf8)!,
                        "statusCode": String(statusCode)
                    ]);
                }

                task.resume()
        
            case "putHTTP":
                let session = URLSession.shared
                let args = call.arguments as! NSDictionary
                let url = args["url"] as! String
                let data = args["data"] as? Dictionary<String, Any>
                let accessToken = args["accessToken"] as? String

                let jsonData = try? JSONSerialization.data(withJSONObject: data)
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "PUT"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                request.httpBody = jsonData
                
                let task = session.dataTask(with: request) { data, response, error in
                    var statusCode = 200
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                    }
                    result([
                        "data": String(data: data!, encoding: .utf8)!,
                        "statusCode": String(statusCode)
                    ]);
                }

                task.resume()
        
            case "deleteHTTP":
                let session = URLSession.shared
                let args = call.arguments as! NSDictionary
                let url = args["url"] as! String
                let accessToken = args["accessToken"] as? String
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "DELETE"
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                
                let task = session.dataTask(with: request) { data, response, error in
                    var statusCode = 200
                    if let httpResponse = response as? HTTPURLResponse {
                        statusCode = httpResponse.statusCode
                    }
                    result([
                        "data": String(data: data!, encoding: .utf8)!,
                        "statusCode": String(statusCode)
                    ]);
                }

                task.resume()
        
            default:
                result(FlutterMethodNotImplemented)
        }
    })

    GeneratedPluginRegistrant.register(with: self)
      if FirebaseApp.app() == nil {
          FirebaseApp.configure()
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
