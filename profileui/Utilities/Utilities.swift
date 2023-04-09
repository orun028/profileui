//
//  Utilities.swift
//  profileui
//
//  Created by Admin on 02/04/2023.
//

import Foundation
import UIKit
// NETWORK
import SystemConfiguration.CaptiveNetwork
import Alamofire
// FACEID
import SwiftUI
import LocalAuthentication
import CoreLocation

final class Utilities {
    static let shared = Utilities()
    let locationManager = CLLocationManager()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    func getNetworkType() -> String {
        if let reachability = NetworkReachabilityManager() {
            if reachability.isReachableOnCellular {
                return "Cellular"
            } else if reachability.isReachableOnEthernetOrWiFi {
                return "Wi-Fi/Ethernet"
            }
        }
        return "Unknown"
    }

    func getWiFiSsid() -> String? {
        let locationWhenInUse = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String
        let locationAlwaysAndWhenInUse = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as? String

        if locationWhenInUse == nil {
            print("App does not have NSLocationWhenInUseUsageDescription key in Info.plist")
            locationManager.requestWhenInUseAuthorization()
        }

        if locationAlwaysAndWhenInUse == nil {
            print("App does not have NSLocationAlwaysAndWhenInUseUsageDescription key in Info.plist")
            locationManager.requestAlwaysAuthorization()
        }

        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }

    func getPublicIPAddress() -> String? {
        var publicIP: String?
        AF.request("https://api.ipify.org").responseString { response in
            if let result = response.value {
                publicIP = result
            }
        }
        return publicIP
    }

    func getInternalIPAddress() -> String? {
        var internalIP: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        internalIP = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return internalIP
    }
    
    func checkFaceID() throws {
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authorize with touch id!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                  self.showAlert(title: "Success", message: "Authentication successful")
                } else {
                    if let error = error {
                        print("Authentication failed \(error)")
                    } else {
                        print("Authentication failed")
                    }
                }
            }
        }
        else {
            showAlert(title: "Unavailable", message: "You cant use this feature")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
