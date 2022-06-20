//
//  DeviceMgmtModel.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 28/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum DeviceEnrollmentRequestStatus:String {
    case Enrolled = "ENROLLED"
    case Unknown = "UNKNOWN"
    case EnrollConfirmed = "ENROLL_CONFIRMED"
    
}

enum DeviceEnrollmentResponseStatus:String {
    case UnknownDevice = "UNKNOWN_DEVICE"
    case KnownDevice = "KNOWN_DEVICE"
    case EnrollDenied = "ENROLLMENT_DENIED"
    case EnrollAccepted = "ENROLLMENT_ACCEPTED"
    case BlockedDevice = "BLOCKED_DEVICE"
}

enum AppUpdateStatus:String {
    case Ok = "OK"
    case UpdateAvailable = "UPDATE_AVAIL"
    case UpdateRequired = "UPDATE_REQUIRED"
}

let AppStoreURL = "https://apps.apple.com/us/app/id1514772560"
extension Bundle {

    public var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var fullVersion: String {
        return "\(shortVersion).\(buildVersion)"
    }
}

class DeviceMgmtModel: NSObject {
    static let DeviceMgmtShared = DeviceMgmtModel()
    
    let deviceType = "IOS"
    var currentEnrollmentStatus: String {
        return (defaults.object(forKey: "device_enrollment_status") as? String) ?? DeviceEnrollmentRequestStatus.Unknown.rawValue
    }
    
    var currentLicenseUUID: String {
        return (defaults.object(forKey: "device_license_uuid") as? String) ?? ""
    }
    
    var appUpdateSkipStatus: Bool {
        return (defaults.object(forKey: "rapid_rx_is_skip_update") as? Bool) ?? false
    }
    
    
    var currentDeviceId: String {
        return UIDevice.current.identifierForVendor?.description ?? ""
    }
    
    var previousDeviceId: String {
        return (defaults.object(forKey: "device_id") as? String) ?? ""
    }
    
    var isSameDevice:Bool{
        return currentDeviceId == previousDeviceId
    }
    
    
    func setLicenseUUID(_ newUUID:String){
        defaults.set(newUUID, forKey: "device_license_uuid")
    }
    
    func setEnrollmentStatus(_ status:String){
        defaults.set(status, forKey: "device_enrollment_status")
    }
    
    func setAppUpdateSkipStatus(_ status:Bool){
        defaults.set(status, forKey: "rapid_rx_is_skip_update")
    }
    
    
    
}
