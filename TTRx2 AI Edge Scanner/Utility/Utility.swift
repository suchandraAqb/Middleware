//
//  Utility.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 14/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import CoreData
import MobileCoreServices
import AVFoundation
import AFNetworking


let AppLanguage = "AppLanguage"
let activeStepButtonImgStr = "active_circle"
let inActiveStepButtonImgStr = "inactive_circle"
let completedStepButtonImgStr = "completed_circle"
let activeColorStr = "39DFA7"
let inActiveColorStr = "8EADAD"
let activeFontColorStr = "072144"
let ttrShipmentDetails = "shipmentDetails"
let App_Title:String! = "Error".localized()
let Success_Title:String! = "Success".localized()
let Warning :String! = "Warning!".localized()
let Info :String! = "Information!".localized()
let No_Internet_Msg:String! = "NoInternet".localized()
let No_Data_Msg:String! = "NoDataFound".localized()
let ServiceTimeout:Double = 120.0
let defaults = UserDefaults.standard
let stdTimeFormat = (defaults.object(forKey: "timeFormat") as? String) ?? "hh:mm a"
var BaseUrl:String! = "https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/"
let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let MaxNumberOfSerialsForVerification : Int = 10
let MaxNumberOfSerialsForSalesOrderByPicking : Int = 10
let MaxNumberOfSerialsForSerialFinder : Int = 20
let FileUploadLimit :Float = 10
let VideoUploadLimit :Float = 512
let shipment_cond_array = [["name" : "Excellent", "value":"EXCELLENT"],
                           ["name" : "Good", "value":"GOOD"],
                           ["name" : "Average", "value":"AVERAGE"],
                           ["name" : "Bad", "value":"BAD"],
                           ["name" : "Not Usable", "value":"NOT_USABLE"],
                           ["name" : "Damaged", "value":"DAMAGED"],["name" : "Destroyed", "value":"DESTROYED"]]

enum Adjustments_Types:String {
    case Quarantine = "QUARANTINE"
    case Destruction = "DESTRUCTION"
    case Dispense = "DISPENSING"
    case Transfer = "TRANSFER"
    case MissingStolen = "MISC_ADJUSTMENT"

}

enum Product_Types:String {
    case LotBased = "LOT_BASED"
    case SerialBased = "GS1_SERIAL_BASED"
    case Container = "CONTAINER"
    case AggregaionBased = "AGGREGATION_SERIAL_BASED"
    
}


//MARK : - SingleScanViewControllerDelegate

//MARK: - Adding Transition Animation
extension UINavigationController {
    public func addTransition(transitionType type: CATransitionType , duration: CFTimeInterval = 0.3) {
        self.clearAllAnimations()
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
    public func clearAllAnimations() {
        self.view.subviews.forEach({$0.layer.removeAllAnimations()})
        self.view.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
}
//MARK: - End
//////////////////////////////////////////
extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: (self.contentSize.height - self.bounds.size.height)+200)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func validatedStringWithRegex(regexStr:String)->Bool{
        
        let regex = try! NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        
    }
    
}
extension Date {
    func isBeforeDate(_ comparisonDate: Date) -> Bool {
        let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
        return order == .orderedAscending
    }
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension UITextField{
    func addLeftViewPadding(padding:CGFloat){
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}



extension UIView {
    
    func setRoundCorner(cornerRadious:CGFloat) {
        
        self.layer.cornerRadius = cornerRadious
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
    }
    
    func setBorder(width:CGFloat, borderColor:UIColor, cornerRadious:CGFloat) {
        
        self.layer.cornerRadius = cornerRadious
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
    }
    
    func roundTopCorners(cornerRadious:CGFloat) {
        
        self.layer.cornerRadius = cornerRadious
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
    func roundBottomCorners(cornerRadious:CGFloat) {
        
        self.layer.cornerRadius = cornerRadious
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    }
}

class Utility: NSObject {
    class func color(from isActive:Bool, defaultColorCode:String = "072144") -> UIColor? {
        if isActive {
            return Utility.hexStringToUIColor(hex: "00AFEF")
        }else{
            return Utility.hexStringToUIColor(hex:defaultColorCode )
        }
        
    }
    class func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    class func dropShadow(viewDrop:UIView!)
    {
        viewDrop.layer.masksToBounds = false
        viewDrop.layer.shadowColor = UIColor.darkGray.cgColor
        viewDrop.layer.shadowOpacity = 0.3
        viewDrop.layer.shadowOffset = CGSize(width: 0, height:0)
        viewDrop.layer.shadowRadius = 10
        viewDrop.layer.cornerRadius = 10
    }
    
    
    //MARK: - ALERT ACTIONS -
    class func showAlertDefault(Title:String?, Message:String?, InViewC:UIViewController?, action: (() -> (Void))? = nil) {
        
        let popUpAlert = UIAlertController(title: Title!, message: Message!, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: {_ in
            guard let act = action else{
                return
            }
            return act()
        })
        //let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
        //popUpAlert.addAction(cancelAction)
        popUpAlert.addAction(okAction)
        
        InViewC?.present(popUpAlert, animated: true, completion: nil)
    }
    
    class func showAlertDefaultWithPopAction(Title:String?, Message:String?, InViewC:UIViewController?, action: @escaping () -> Void) {
        
        let popUpAlert = UIAlertController(title: Title!, message: Message!, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: {_ in
            return action()
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
        popUpAlert.addAction(cancelAction)
        popUpAlert.addAction(okAction)
        
        InViewC?.present(popUpAlert, animated: true, completion: nil)
    }
    
    class func showPopup(Title:String?, Message:String?, InViewC:UIViewController?) {
        
        let popUpAlert = CustomAlert(title: Title!, message: Message!, preferredStyle: .alert)
        popUpAlert.setTitleImage((Title == App_Title ? UIImage(named: "Error") : Title == Success_Title ? UIImage(named: "success") : Title == Warning ? UIImage(named: "warning") : Title == Info ? UIImage(named: "info") : UIImage(named: "warning")) ?? UIImage())
        
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
            
        })
        
        popUpAlert.addAction(okAction)
        
        InViewC?.present(popUpAlert, animated: true, completion: nil)
        
        //UIColor(red: 4/255, green: 46/255, blue: 86/255
        
    }
    
    class func showPopupWithAction(Title:String?, Message:String?, InViewC:UIViewController?, action: (() -> (Void))? = nil) {
            
            let popUpAlert = CustomAlert(title: Title!, message: Message!, preferredStyle: .alert)
            popUpAlert.setTitleImage((Title == App_Title ? UIImage(named: "Error") : Title == Success_Title ? UIImage(named: "success") : Title == Warning ? UIImage(named: "warning") : Title == Info ? UIImage(named: "info") : UIImage(named: "warning")) ?? UIImage())
            
            let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: {_ in
                guard let act = action else{
                    return
                }
                return act()
            })
            popUpAlert.addAction(okAction)
            
            InViewC?.present(popUpAlert, animated: true, completion: nil)
        }//,,,sb4
    class func showPopupWithAction(Title:String?, Message:String?, InViewC:UIViewController?, isCancel:Bool, action: (() -> (Void))? = nil) {
            
            let popUpAlert = CustomAlert(title: Title!, message: Message!, preferredStyle: .alert)
            popUpAlert.setTitleImage((Title == App_Title ? UIImage(named: "Error") : Title == Success_Title ? UIImage(named: "success") : Title == Warning ? UIImage(named: "warning") : Title == Info ? UIImage(named: "info") : UIImage(named: "warning")) ?? UIImage())
        
            if isCancel {
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
                popUpAlert.addAction(cancelAction)
            }
            
            let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
                guard let act = action else{
                    return
                }
                return act()
            })
            popUpAlert.addAction(okAction)
            
            InViewC?.present(popUpAlert, animated: true, completion: nil)
    }//,,,sb11-3
    
    class func showAlertWithPopAction(Title:String?, Message:String?, InViewC:UIViewController?,isPop:Bool , isPopToRoot:Bool) {
        
        let popUpAlert = CustomAlert(title: Title!, message: Message!, preferredStyle: .alert)
        popUpAlert.setTitleImage((Title == App_Title ? UIImage(named: "Error") : Title == Success_Title ? UIImage(named: "success") : UIImage(named: "warning")) ?? UIImage())
        
        
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
            if isPop && isPopToRoot {
                InViewC?.navigationController?.popToRootViewController(animated: true)
            }else if isPop{
                InViewC?.navigationController?.popViewController(animated: true)
            }
            
        })
        
        popUpAlert.addAction(okAction)
        InViewC?.present(popUpAlert, animated: true, completion: nil)
    }
    class func openSacnDetails(controller:UIViewController){
        let controller1 = controller.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller1.delegate = controller as? SingleScanViewControllerDelegate
        controller1.isFromBarCodeCpature = true
        controller.navigationController?.pushViewController(controller1, animated: true)
    }

    //MARK: - END -
    class func getURL(type:String, isOpt:Bool = false)->String{
      
        var finalUrlStr = ""
        
        if type == "Login"{
            finalUrlStr = BaseUrl + "sign-in"
        }else if type == "NewPasswordRequird"{
            finalUrlStr = BaseUrl + "new-password-required"
        }else  if type == "Logout"{
            finalUrlStr = BaseUrl + "sign-out"
        }else if type == "ErpList"{
            finalUrlStr = BaseUrl + "list-erps"
        }else if type == "ErpAction"{
            finalUrlStr = BaseUrl + "get-erps-in-action"
        }else  if type == "ShipmentDetails"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }else  if type == "GetInboundSerials"{
            finalUrlStr = BaseUrl + "shipments/Inbound/"
        }else  if type == "ReceivingVerifiedSerials"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }else  if type == "GetShelfList"{
            finalUrlStr = BaseUrl + "locations/"
        }else  if type == "ConfirmShipment"{
            finalUrlStr = BaseUrl + "shipments/"
        }else  if type == "UserInfo"{
            finalUrlStr = BaseUrl + "user/all_user_infos"
        }else  if type == "GetTradingPartners"{
            finalUrlStr = BaseUrl + "trading_partners/"
        }else  if type == "GetIndividualProduct"{
            finalUrlStr = BaseUrl + "products/gs1_barcode_serialized_query"
        }else if type == "VerifyShipmentsForReceiving" {
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }else  if type == "GetLocationDetails"{
            finalUrlStr = BaseUrl + "locations/"
        }else  if type == "GetCountryDetails"{
            finalUrlStr = BaseUrl + "utility/country_list/"
        }else  if type == "Picking_Transactions"{
            finalUrlStr = BaseUrl + "transaction_shipment/"
        }else  if type == "Company_Mgmt"{
            finalUrlStr = BaseUrl + "company_management/"
        }else  if type == "SalesOrderByPickingMultipleGS1"{
            finalUrlStr = BaseUrl + "picking/sales_order_by_picking/gs1_barcode_multiple/"
        }else  if type == "SalesOrderByPickingGS1"{
            finalUrlStr = BaseUrl + "picking/sales_order_by_picking/simple_serial"
        }else  if type == "SalesOrderByPickingAggregationSerial"{
            finalUrlStr = BaseUrl + "picking/sales_order_by_picking/aggregation_serial"
        }else  if type == "GetProducts"{
            finalUrlStr = BaseUrl + "products/"
        }else  if type == "GetProductAll"{
            finalUrlStr = BaseUrl + "products/?clean_identifiers=true"
        }else  if type == "AddPickingLotBasedProduct"{
            finalUrlStr = BaseUrl + "picking/sales_order_by_picking/lot_based"
        }else  if type == "GetPickingItems"{
            finalUrlStr = BaseUrl + "picking/sales_order_by_picking/"
        }else  if type == "GetSerialDetails"{
            finalUrlStr = BaseUrl + "serial_finder/serial_detail?"
        }else  if type == "InitiateReturn"{
            finalUrlStr = BaseUrl + "returns_manager/return"
        }else  if type == "SearchShipmentForReturns"{
            finalUrlStr = BaseUrl + "returns_manager/return"
        }else  if type == "GetOutboundSerials"{
            finalUrlStr = BaseUrl + "shipments/Outbound/"
        }else  if type == "RemoveReturnSerial"{
            finalUrlStr = BaseUrl + "returns_manager/return_session_item"
        }else if type == "GetQuarantineList"{
            finalUrlStr = BaseUrl + "adjustments/"
        }else if type == "GS1BarcodeLookup"{
            finalUrlStr = BaseUrl + "inventory/basic_query/gs1_barcode"
        }else if type == "barcodedecoder"{
            finalUrlStr = BaseUrl + "barcode_decoder"
        }else if type == "ShipmentPickings"{
            finalUrlStr = BaseUrl + "shipments/picking/"
        }else if type == "SerialFinder"{
            finalUrlStr = BaseUrl + "serial_finder/"
        }else if type == "ShipmentLotsItem"{
            finalUrlStr = BaseUrl + "shipments/lots_lines_items"
        }else if type == "GetContainerSerials"{
            finalUrlStr = BaseUrl + "containers/serial_generation"
        }else if type == "ContainersSearch"{
            finalUrlStr = BaseUrl + "containers_search/"
        }else if type == "GetPackageTypeList"{
            finalUrlStr = BaseUrl + "products/packaging_types"
        }else if type == "ContainersDetails"{
            finalUrlStr = BaseUrl + "containers/"
        }else if type == "Manufacturer"{
            finalUrlStr = BaseUrl + "products/manufacturer/"
        }else if type == "AddUpdateManufacturerLot"{
            finalUrlStr = BaseUrl + "products/"
        }else if type == "VerifyReturnSerials"{
            finalUrlStr = BaseUrl + "returns_manager/return_session_item_multiple_by_barcode"
        }else if type == "ReturnSerialsStatusCheck"{
            finalUrlStr = BaseUrl + "returns_manager/"
        }else if type == "OutboundShipments"{
            finalUrlStr = BaseUrl + "shipments/outbound/find_shipment_who_contains_lot_based_item"
        }else if type == "PurchaseOrder"{
            finalUrlStr = BaseUrl + "transactions/purchase"
        }else if type == "ManualInboundShipment"{
            finalUrlStr = BaseUrl + "shipments/Inbound"
        }else if type == "UpdateProductLot"{
            finalUrlStr = BaseUrl + "products/"
        }else if type == "quarantine"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }
        else if type == "InboundShipmentList"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }else if type == "OutboundShipmentList"{
            finalUrlStr = BaseUrl + "shipments/"
        }
        else if type == "UpdateShipment"{
            finalUrlStr = BaseUrl + "shipments/"
        }
        else if type == "InboundShipmentDetails"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        }
        else if type == "change_password"{
            finalUrlStr = BaseUrl + "user/change_password"
        }else if type == "basic_profile"{
            finalUrlStr = BaseUrl + "user/basic_profile"
        }else if type == "lost_password"{
            finalUrlStr = BaseUrl + "user/lost_password"
        }else if type == "SerialFinderExport"{
            finalUrlStr = BaseUrl + "serial_finder/data_export"
        }else if type == "ProductsTypes"{
            finalUrlStr = BaseUrl + "products/types/"
        }else if type == "AddNewProduct"{
            finalUrlStr = BaseUrl + "products"
        }
        else if type == "deleteReceivingShipment"{
            finalUrlStr = BaseUrl + "shipments/receiving/"
        } else if type == "deleteShipment"{
            finalUrlStr = BaseUrl + "shipments/"
        }
        else if type == "get_filter_options"{
            finalUrlStr = BaseUrl + "ar_viewer/get_filter_options"
        }
        else if type == "get_filter_operators"{
            finalUrlStr = BaseUrl + "ar_viewer/get_filter_operators"
        }
        else if type == "downloadable_files"{
            finalUrlStr = BaseUrl + "ar_viewer/downloadable_files"
        }
        else if type == "downloadable_files_delete_multiple"{
            finalUrlStr = BaseUrl + "ar_viewer/downloadable_files/delete_multiple"
        }//,,,sb10
        
        else if type == "last_used_filters"{
            finalUrlStr = BaseUrl + "ar_viewer/last_used_filters"
        }//,,,sb9
        else if type == "ar_viewer"{
            finalUrlStr = BaseUrl + "ar_viewer"
        }//,,,sb9
        else if type == "ar_viewer_save_and_search"{
            finalUrlStr = BaseUrl + "ar_viewer/save_and_search"
        }//,,,sb11
        else if type == "ar_viewer_search"{
            finalUrlStr = BaseUrl + "ar_viewer"
        }//,,,sb11-1
        
        else if type == "GetLotListOfLocation"{
            finalUrlStr = BaseUrl + "products/lots_autocomplete"
        }
        else if type == "PickNewItem"{
            finalUrlStr = BaseUrl + "shipments/picking"
        }else if type == "staffMgtGetApiCall"{
            finalUrlStr = BaseUrl + "company_management/staff_mgt"
        }else if type == "revalidateAccessToken"{
            finalUrlStr = BaseUrl + "revalidate-access-token"
        }else if type == "saveuserSettings"{
            finalUrlStr = BaseUrl + "save-user-settings"
        }
        return finalUrlStr
    }
    class func getActionId(type:String)->String{
        var finalIdStr = ""
            if type == "Login"{
                finalIdStr = "25236406-acab-4c64-8baa-356f1398f483"
            }else if type == "NewPasswordRequird"{
                finalIdStr = "f25a363c-d4aa-471b-8889-acae4591ef6e"
            }else if type == "Logout"{
                finalIdStr = "cd86196c-47c6-498c-8358-ed5671c2c2dc"
            }else if type == "revalidateAccessToken"{
                finalIdStr = "3b82ddb7-e456-4627-8e9d-083bc2686839"
            }else if type == "erpList"{
                finalIdStr = "9d111570-82b0-439b-8108-d7fbfc47b4c8"
            }else if type == "erpAction"{
                finalIdStr = "18a6c216-5320-4ab8-bec7-61a4eb2a9997"
            }else if type == "getuserSettings"{
                finalIdStr = "0206493c-0747-49c6-b27f-eacf9c7b35c1"
            }else if type == "saveusersettings"{
                finalIdStr = "a1141524-b22b-4304-bbe5-620b54612db1"
            }
        return finalIdStr
    }
    //MARK: - Suffix String to Date
    class func dateSuffix(day:Int)->String{
        
        switch day {
        case 11...13: return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
    //MARK: End -
    
    //MARK: - Localized String
    class func setAppDefaultLanguage(){
        Localize.resetCurrentLanguageToDefault()
    }
    
    class func setAppLanguage(language:String){
        Localize.setCurrentLanguage(language)
    }
    //MARK: End -
    
    //MARK: - Custom Date
    class func getDateFromString(sourceformat:String,outputFormat:String,dateStr:String )->String?{
        let formatter = DateFormatter()
        
        
        
        if let tzone = defaults.object(forKey: "user_timezone") as? String{ // "time_zone" Client Time Zone
            //print("Timezone:\(tzone)")
            formatter.timeZone = TimeZone(identifier: tzone)
            
        }
        
        formatter.dateFormat = sourceformat
        if let date = formatter.date(from: dateStr) {
            //print(date)  // Prints:  2018-12-10 06:00:00 +0000
            formatter.dateFormat = outputFormat
            return formatter.string(from: date)
        }
        
        return nil
        
    }
    
    class func dateFromString(sourceformat:String,dateStr:String)->Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = sourceformat
        if let date = formatter.date(from: dateStr) {
            return date
        }
        return nil
    }
    //MARK: End -
    ///////////////////////////////////////////////////
    //MARK: - WebService Call
    class func POSTServiceCall(type:String, serviceParam:Any, parentViewC:UIViewController?, willShowLoader:Bool?,viewController:BaseViewController,appendStr:String?,isOpt:Bool = false, ServiceCompletion:@escaping (_ response:Any?, _ isDone:Bool?, _ errMessage:String?) -> Void) {
        var serviceUrl = self.getURL(type: type, isOpt: isOpt)
        
        if appendStr != nil{
            serviceUrl = serviceUrl + (appendStr ?? "")
        }
     
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
            
            if parentViewC != nil && willShowLoader == true {
                MBProgressHUD.showAdded(to: (parentViewC?.view)!, animated: true)
            }
            let manager = AFHTTPSessionManager()
            manager.requestSerializer.timeoutInterval = ServiceTimeout
            let indexSet: IndexSet = [200,202,400,500]
            manager.responseSerializer.acceptableStatusCodes = indexSet
            let contentType: Set = ["application/json","text/html"] //"text/html"
            manager.responseSerializer.acceptableContentTypes = contentType
            //manager.securityPolicy.allowInvalidCertificates = true
      
            var headers = [String : String]()
            headers["Content-Type"] = "application/json"
            let authToken = (defaults.value(forKey: "accesstoken") ?? "") as! String

            if !authToken.isEmpty{
                headers["Authorization"] = authToken
            }
//            if let lang = defaults.object(forKey: AppLanguage) as? String{
//                if lang == "pt-BR"{
//                    headers["Accept-Language"] = "pt"
//                }else{
//                    headers["Accept-Language"] = lang
//                }
//                
//            }
            print("Headers",headers)
            print("Request URL:",serviceUrl)
            print("Request Data:", serviceParam as Any)
        
            manager.post(serviceUrl, parameters: serviceParam, headers: headers , progress: { (progress:Progress) in
                print(progress.totalUnitCount)
                
            }, success: { (sessionDataTask:URLSessionDataTask, responseData:Any?) in
                print(NSString(data: (sessionDataTask.originalRequest?.httpBody)!, encoding: String.Encoding.utf8.rawValue) as Any)
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print("Response Data:",responseData as Any)
                let response = sessionDataTask.response as! HTTPURLResponse
                if responseData != nil{
                    //print("responseDic = \(responseDic)")
                    print(response.statusCode)
                    if response.statusCode == 200 {
                        ServiceCompletion(responseData, true,"")
                    }else if response.statusCode == 202 && type == "ManualInboundShipment" {
                        ServiceCompletion(responseData, true,"")
                    }else{
                        if let responseDict = responseData as? NSDictionary{
                            var tokenstr = ""
                            if let token = responseDict["token"] as? String,!token.isEmpty{
                                tokenstr = token
                            }
                            var expireStr = ""
                            if let expire = responseDict["expire"] as? String,!expire.isEmpty{
                                expireStr = expire
                            }
                            if !tokenstr.isEmpty && !expireStr.isEmpty {
                                Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
                                return
                            }
//                            if let errorCode = responseDict["code"] as? String{
//                                if errorCode == "TT2CORE__LIB__APILIB-G01111" || errorCode == "OAPI_SESSION-Technical Error01105" {
//                                    Utility.showAlertDefault(Title: responseDict["message"] as? String ?? "", Message: "", InViewC: parentViewC) {
//                                        Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
//                                        return
//                                    }
//                                }
//                            }
                        }
                        ServiceCompletion(responseData, false,"")
                    }
                } else {
                    ServiceCompletion(nil, false, No_Data_Msg)
                }
            }) { (sessionDataTask:URLSessionDataTask?, error:Error) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print(error.localizedDescription)
                ServiceCompletion(nil, false, error.localizedDescription)
            }
            
        }else {
            ServiceCompletion(nil, false, No_Internet_Msg)
        }
    }
    class func save(key: String, data: Data) -> OSStatus {
            let query = [
                kSecClass as String       : kSecClassGenericPassword as String,
                kSecAttrAccount as String : key,
                kSecValueData as String   : data ] as [String : Any]

            SecItemDelete(query as CFDictionary)

            return SecItemAdd(query as CFDictionary, nil)
        }

        class func load(key: String) -> Data? {
            let query = [
                kSecClass as String       : kSecClassGenericPassword,
                kSecAttrAccount as String : key,
                kSecReturnData as String  : kCFBooleanTrue!,
                kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

            var dataTypeRef: AnyObject? = nil

            let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

            if status == noErr {
                return dataTypeRef as! Data?
            } else {
                return nil
            }
        }
    class func GETServiceCall(type:String, serviceParam:Any, parentViewC:UIViewController?, willShowLoader:Bool?,viewController:BaseViewController,appendStr:String?,isOpt:Bool = false, ServiceCompletion:@escaping (_ response:Any?, _ isDone:Bool?, _ errMessage:String?) -> Void) {
        
        var serviceUrl = self.getURL(type: type, isOpt: isOpt)
        
        if appendStr != nil{
            serviceUrl = serviceUrl + (appendStr ?? "")
        }
        
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
            
            if parentViewC != nil && willShowLoader == true {
                MBProgressHUD.showAdded(to: (parentViewC?.view)!, animated: true)
            }
            
            let manager = AFHTTPSessionManager()
            //manager.responseSerializer = AFJSONResponseSerializer()
            manager.requestSerializer.timeoutInterval = ServiceTimeout
            let indexSet: IndexSet = [200,400,500]
            manager.responseSerializer.acceptableStatusCodes = indexSet
            let contentType: Set = ["application/json","text/html"] //"text/html"
            manager.responseSerializer.acceptableContentTypes = contentType
            
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            
            if !authToken.isEmpty{
                manager.requestSerializer.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            print(authToken)
            var headers = [String : String]()
            headers["Content-Type"] = "application/json"
            headers["accept"] = "application/json"
            
            if let lang = defaults.object(forKey: AppLanguage) as? String{
                if lang == "pt-BR"{
                    headers["Accept-Language"] = "pt"
                }else{
                    headers["Accept-Language"] = lang
                }
                
            }
            print("Header :",headers)
            print("Request URL:",serviceUrl)
            print("Request Data:", serviceParam as Any)
            
            manager.get(serviceUrl, parameters: serviceParam, headers: headers , progress: { (progress:Progress) in
                
                print(progress.totalUnitCount)
                
            }, success: { (sessionDataTask:URLSessionDataTask, responseData:Any?) in
                
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print("Response Data:",responseData as Any)
                
                let response = sessionDataTask.response as! HTTPURLResponse
                if responseData != nil{
                    
                    //print("responseDic = \(responseDic)")
                    if response.statusCode == 200 {
                        
                        ServiceCompletion(responseData, true,"")
                        
                    }else{
                        if let responseDict = responseData as? NSDictionary{
                            if let errorCode = responseDict["code"] as? String{
                                if errorCode == "TT2CORE__LIB__APILIB-G01111" || errorCode == "OAPI_SESSION-Technical Error01105"{
                                    Utility.showAlertDefault(Title: responseDict["message"] as? String ?? "", Message: "", InViewC: parentViewC) {
                                        Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
                                        return
                                    }
                                }
                            }
                        }
                        
                        ServiceCompletion(responseData, false,"")
                    }
                } else {
                    ServiceCompletion(nil, false, No_Data_Msg)
                }
            }) { (sessionDataTask:URLSessionDataTask?, error:Error) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                
                //print(error.localizedDescription)
                ServiceCompletion(nil, false, error.localizedDescription)
            }
            
        }else {
            ServiceCompletion(nil, false, No_Internet_Msg)
        }
        
    }
    
    class func DELETEServiceCall(type:String, serviceParam:Any, parentViewC:UIViewController?, willShowLoader:Bool?,viewController:BaseViewController,appendStr:String?,    ServiceCompletion:@escaping (_ response:Any?, _ isDone:Bool?, _ errMessage:String?) -> Void) {
        
        var serviceUrl = self.getURL(type: type)
        if appendStr != nil{
            serviceUrl = serviceUrl + (appendStr ?? "")
        }
        
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
            
            if parentViewC != nil && willShowLoader == true {
                MBProgressHUD.showAdded(to: (parentViewC?.view)!, animated: true)
            }
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer.timeoutInterval = ServiceTimeout
            
            let indexSet: IndexSet = [200,400]
            manager.responseSerializer.acceptableStatusCodes = indexSet
            let contentType: Set = ["application/json"] //"text/html"
            manager.responseSerializer.acceptableContentTypes = contentType
            let methods: Set = ["GET","HEAD"]
            manager.requestSerializer.httpMethodsEncodingParametersInURI = methods
            
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            
            if !authToken.isEmpty{
                manager.requestSerializer.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            
            var headers = [String : String]()
            headers["Content-Type"] = "application/json"
            
            if let lang = defaults.object(forKey: AppLanguage) as? String{
                if lang == "pt-BR"{
                    headers["Accept-Language"] = "pt"
                }else{
                    headers["Accept-Language"] = lang
                }
                
            }
            
            print("Request URL:",serviceUrl)
            print("Request Data:", serviceParam as Any)
            
            manager.delete(serviceUrl, parameters: serviceParam, headers: headers , success: { (sessionDataTask:URLSessionDataTask, responseData:Any?) in
                
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print("Response Data:",responseData as Any)
                
                
                let response = sessionDataTask.response as! HTTPURLResponse
                if responseData != nil{
                    
                    //print("responseDic = \(responseDic)")
                    if response.statusCode == 200 {
                        ServiceCompletion(responseData, true,"")
                    }else{
                        if let responseDict = responseData as? NSDictionary{
                            if let errorCode = responseDict["code"] as? String{
                                if errorCode == "TT2CORE__LIB__APILIB-G01111" || errorCode == "OAPI_SESSION-Technical Error01105" {
                                    Utility.showAlertDefault(Title: responseDict["message"] as? String ?? "", Message: "", InViewC: parentViewC) {
                                        Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
                                        return
                                    }
                                }
                            }
                        }
                        ServiceCompletion(responseData, false,"")
                    }
                } else {
                    ServiceCompletion(nil, false, No_Data_Msg)
                }
            }) { (sessionDataTask:URLSessionDataTask?, error:Error) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                
                //print(error.localizedDescription)
                ServiceCompletion(nil, false, error.localizedDescription)
            }
            
        }else {
            ServiceCompletion(nil, false, No_Internet_Msg)
        }
    }
    class func PUTServiceCall(type:String, serviceParam:Any, parentViewC:UIViewController?, willShowLoader:Bool?,viewController:BaseViewController,appendStr:String?,isOpt:Bool = false,   ServiceCompletion:@escaping (_ response:Any?, _ isDone:Bool?, _ errMessage:String?) -> Void) {
        var serviceUrl = self.getURL(type: type, isOpt: isOpt)
        
        if appendStr != nil{
            serviceUrl = serviceUrl + (appendStr ?? "")
        }
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
            
            if parentViewC != nil && willShowLoader == true {
                MBProgressHUD.showAdded(to: (parentViewC?.view)!, animated: true)
            }
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer.timeoutInterval = ServiceTimeout
            let indexSet: IndexSet = [200,400,500]
            manager.responseSerializer.acceptableStatusCodes = indexSet
            //manager.securityPolicy.allowInvalidCertificates = true
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            
            if !authToken.isEmpty{
                manager.requestSerializer.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            
            var headers = [String : String]()
            headers["Content-Type"] = "application/json"
            
            if let lang = defaults.object(forKey: AppLanguage) as? String{
                if lang == "pt-BR"{
                    headers["Accept-Language"] = "pt"
                }else{
                    headers["Accept-Language"] = lang
                }
                
            }
            
            print("Request URL:",serviceUrl)
            print("Request Data:", serviceParam as Any)
            
            manager.put(serviceUrl, parameters: serviceParam, headers: headers , success: { (sessionDataTask:URLSessionDataTask, responseData:Any?) in
                print(NSString(data: (sessionDataTask.originalRequest?.httpBody)!, encoding: String.Encoding.utf8.rawValue) as Any   )
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print("Response Data:",responseData as Any)
                
                
                let response = sessionDataTask.response as! HTTPURLResponse
                if responseData != nil{
                    
                    //print("responseDic = \(responseDic)")
                    if response.statusCode == 200 {
                        ServiceCompletion(responseData, true,"")
                    }else{
                        if let responseDict = responseData as? NSDictionary{
                            if let errorCode = responseDict["code"] as? String{
                                if errorCode == "TT2CORE__LIB__APILIB-G01111" || errorCode == "OAPI_SESSION-Technical Error01105" {
                                    Utility.showAlertDefault(Title: responseDict["message"] as? String ?? "", Message: "", InViewC: parentViewC) {
                                        Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
                                        return
                                    }
                                }
                            }
                        }
                        ServiceCompletion(responseData, false,"")
                    }
                } else {
                    ServiceCompletion(nil, false, No_Data_Msg)
                }
            }) { (sessionDataTask:URLSessionDataTask?, error:Error) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                
                //print(error.localizedDescription)
                ServiceCompletion(nil, false, error.localizedDescription)
            }
            
        }else {
            ServiceCompletion(nil, false, No_Internet_Msg)
        }
        
    }
    
    class func MultiPartPOSTServiceCall(type:String, serviceParam:Any, fileFieldName:String, fileName:String, fileMimeType:String, filePath:String, parentViewC:UIViewController?, willShowLoader:Bool?,viewController:BaseViewController,appendStr:String?,isOpt:Bool = false,   ServiceCompletion:@escaping (_ response:Any?, _ isDone:Bool?, _ errMessage:String?) -> Void) {
        var serviceUrl = self.getURL(type: type, isOpt: isOpt)
        
        if appendStr != nil{
            serviceUrl = serviceUrl + (appendStr ?? "")
        }
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
            
            if parentViewC != nil && willShowLoader == true {
                MBProgressHUD.showAdded(to: (parentViewC?.view)!, animated: true)
            }
            let manager = AFHTTPSessionManager()
            manager.requestSerializer.timeoutInterval = ServiceTimeout
            let indexSet: IndexSet = [200,202,400,500]
            manager.responseSerializer.acceptableStatusCodes = indexSet
            let contentType: Set = ["application/json","text/html"] //"text/html"
            manager.responseSerializer.acceptableContentTypes = contentType
            //manager.securityPolicy.allowInvalidCertificates = true
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            
            if !authToken.isEmpty{
                manager.requestSerializer.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            
            var headers = [String : String]()
            headers["Content-Type"] = "application/json"
            
            if let lang = defaults.object(forKey: AppLanguage) as? String{
                if lang == "pt-BR"{
                    headers["Accept-Language"] = "pt"
                }else{
                    headers["Accept-Language"] = lang
                }
                
            }
            print("Headers",headers)
            print("Request URL:",serviceUrl)
            print("Request Data:", serviceParam as Any)
            
            manager.post(serviceUrl, parameters: serviceParam, headers: headers, constructingBodyWith: { (FromData) in
                do {
                    try FromData.appendPart(withFileURL: URL(string: filePath)!, name: fileFieldName, fileName: fileName, mimeType: fileMimeType)
                } catch let error {
                    print(error)
                }
                
            }, progress: { (progress) in
                print(progress.fractionCompleted)
            }, success: { (sessionDataTask:URLSessionDataTask, responseData:Any?) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print("Response Data:",responseData as Any)
                let response = sessionDataTask.response as! HTTPURLResponse
                if responseData != nil{
                    if response.statusCode == 200 {
                        ServiceCompletion(responseData, true,"")
                    }else{
                        if let responseDict = responseData as? NSDictionary{
                            if let errorCode = responseDict["code"] as? String{
                                if errorCode == "TT2CORE__LIB__APILIB-G01111" || errorCode == "OAPI_SESSION-Technical Error01105" {
                                    Utility.showAlertDefault(Title: responseDict["message"] as? String ?? "", Message: "", InViewC: parentViewC) {
                                        Utility.sessionExpireHandler(vc: parentViewC ?? UIViewController(), baseVC: viewController)
                                        return
                                    }
                                }
                            }
                        }
                        ServiceCompletion(responseData, false,"")
                    }
                } else {
                    ServiceCompletion(nil, false, No_Data_Msg)
                }
            }, failure: { (sessionDataTask:URLSessionDataTask?, error:Error) in
                if parentViewC != nil && willShowLoader == true {
                    MBProgressHUD.hide(for: (parentViewC?.view)!, animated: true)
                }
                print(error.localizedDescription)
                ServiceCompletion(nil, false, error.localizedDescription)
            })
        }else {
            ServiceCompletion(nil, false, No_Internet_Msg)
        }
    }
    
    //MARK: End -
    //MARK: - Session Handler functions
    class func sessionExpireHandler(vc: UIViewController, baseVC: BaseViewController){
                
        if let _ = defaults.value( forKey: "accesstoken") as? String , let _ = defaults.value(forKey: "userName") as? String , let _ = defaults.value(forKey: "password") as? String , let _ = defaults.value(forKey: "sub") as? String {
//            baseVC.showSpinner(onView: vc.view)
            
            var requestDict = [String:Any]()
            requestDict["action_uuid"] = Utility.getActionId(type:"revalidateAccessToken")
            requestDict["sub"] = defaults.object(forKey: "sub")
            requestDict["refresh_token"] = defaults.object(forKey: "refreshtoken")
            
            Utility.POSTServiceCall(type: "revalidateAccessToken", serviceParam:requestDict as NSDictionary, parentViewC: vc, willShowLoader: false, viewController: baseVC,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
//                    baseVC.removeSpinner()
                     if isDone! {
                         if let responseDict: NSDictionary = responseData as? NSDictionary{
                            let statusCode = responseDict["status_code"] as? Bool
                             if statusCode! {
                                 let responseDict = Utility.convertToDictionary(text: responseDict["data"] as! String) as NSDictionary?
                                 if let access_token = responseDict?["access_token"] as? String,!access_token.isEmpty{
                                     defaults.setValue(access_token, forKey: "accesstoken")
                                 }
                                 if let refresh_token = responseDict?["refresh_token"] as? String,!refresh_token.isEmpty{
                                     defaults.setValue(refresh_token , forKey: "refreshtoken")
                                 }
                             }
                         }
                     }
                }
            }
        }
    }
    class func removeTimer(){
        if DashboardViewController.repeatTimer != nil {
            DashboardViewController.repeatTimer?.invalidate()
            DashboardViewController.repeatTimer = nil
        }
    }
    //MARK: End -
    ///////////////////////////////////////////////////
    //MARK: - UIColor From String
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    //MARK: End -
    ///////////////////////////////////////////////////
    //MARK: - Move To Dashboard as Root
    class func moveToHomeAsRoot(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navC = storyboard.instantiateViewController(withIdentifier: "navC") as? UINavigationController
        let dashBoardVC = storyboard.instantiateViewController(withIdentifier: "DashboardView") as! DashboardViewController
        navC!.viewControllers = [dashBoardVC]
        appDel.window?.rootViewController = navC
        appDel.window?.makeKeyAndVisible()
    }
    //MARK: End -
    ///////////////////////////////////////////////
    //MARK: - Save and Fetch Dictionary To Defautls
    class func saveDictTodefaults(key:String,dataDict:NSDictionary){
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: dataDict, requiringSecureCoding: false)
            defaults.set(data, forKey: key)
        } catch {
            print("Unable to Save Dictionary")
        }
    }
   class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    class func getDictFromdefaults(key:String)->NSDictionary?{
        var dataDict:NSDictionary?
        if let data = defaults.object(forKey: key){
            
            do{
                dataDict  = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data) as? NSDictionary
                
                
            }catch{
                print("\(key) Data Not Found")
            }
            
        }
        
        return dataDict
    }
    class func getObjectFromDefauls(key:String) -> Any? {
        var dataDict:Any?
        if let data = defaults.object(forKey: key){
            do{
                dataDict  = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data)
            }catch{
                print("\(key) Data Not Found")
            }
        }
        return dataDict
    }
    class func saveObjectTodefaults(key:String,dataObject:Any){
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: dataObject, requiringSecureCoding: false)
            defaults.set(data, forKey: key)
        } catch {
            print("Unable to Save Dictionary")
        }
    }
    //MARK: End -
    ///////////////////////////////////////////////
    //MARK: - Core Data Methods
    class func removeReturnFromDB(){
        
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            
            do{
                
                let return_obj = try PersistenceService.context.fetch(Return.fetchReturnRequest(serial: txt))
                print("Existing Return Fetched for Removed")
                
                
                if !return_obj.isEmpty{
                    
                    for obj in return_obj{
                        PersistenceService.context.delete(obj)
                    }
                    
                }
                
            }catch let error {
                print(error.localizedDescription)
                
            }
            
            
            do{
                
                let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialForReturnRequest(uuid: txt))
                print("Existing Return Serials Fetched for Removed")
                
                if !return_obj.isEmpty{
                    
                    for obj in return_obj{
                        PersistenceService.context.delete(obj)
                    }
                    
                }
                
            }catch let error {
                print(error.localizedDescription)
                
            }
            
            PersistenceService.saveContext()
            
        }
    }
    
    class func removeReturnLotDB(){
        
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            
            do {
                let predicate = NSPredicate(format:"return_uuid == '\(txt)'")
                let fetchRequest = NSFetchRequest<Return_Lot>(entityName: "Return_Lot")
                fetchRequest.predicate = predicate
                
                let return_obj = try PersistenceService.context.fetch(fetchRequest)
                print("Existing Return Serials Fetched for Removed")
                
                if !return_obj.isEmpty{
                    
                    for obj in return_obj{
                        PersistenceService.context.delete(obj)
                    }
                    
                }
                
            }catch let error{
                print(error.localizedDescription)
            }
            PersistenceService.saveContext()
        }
    }
    
    class func removeReceivingLotDB(){
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ReceiveLotEdit")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try PersistenceService.context.execute(deleteRequest)
            PersistenceService.saveContext()
        } catch {
            print ("There was an error")
        }
    }
    
    class func removeReceivingLineDB(){
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ReceiveLineItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try PersistenceService.context.execute(deleteRequest)
            PersistenceService.saveContext()
        } catch {
            print ("There was an error")
        }
    }
    class func removeARCriteriasDB(){
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCriterias")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try PersistenceService.context.execute(deleteRequest)
            PersistenceService.saveContext()
        } catch {
            print ("There was an error")
        }
    }//,,,sb11-1
    class func getProductConditionCountForReturn(condition:String)->Int{
        var count = 0
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return count
        }
        
        let predicate = NSPredicate(format: "return_uuid == '\(return_uuid)' and condition == '\(condition)' and status != 'REMOVED'")
        
        
        do{
            
            let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
            
            if !return_obj.isEmpty{
                
                count = return_obj.count
            }
            
        }catch let error {
            print(error.localizedDescription)
            
        }
        
        return count
    }
    class func converJsonToArray(string : String)-> [Any]{
        var jsonArray: [[String: Any]] = []

        let data = string.data(using: .utf8)!
        do {
            if let arr = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
               jsonArray = arr
               print(jsonArray) // use the json here
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return jsonArray
    }
    class func convertCoreDataRequestsToJSONArray(moArray: [NSManagedObject]) -> [Any] {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        // print(jsonArray as Any)
        return jsonArray
    }
    
    class func removeAdjustmentsFromDB(){
        
        do{
            
            let adjustment_obj = try PersistenceService.context.fetch(Adjustments.fetchRequest())
            print("Existing Adjuments Fetched for Removed")
            
            
            if !adjustment_obj.isEmpty{
                
                for obj in adjustment_obj{
                    PersistenceService.context.delete(obj as! Adjustments)
                }
                
            }
            
        }catch let error {
            print(error.localizedDescription)
            
        }
        
        
    }
    class func removeDPFromDB(){
        
        do{
            
            let adjustment_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequest())
            print("Existing Adjuments Fetched for Removed")
            
            
            if !adjustment_obj.isEmpty{
                
                for obj in adjustment_obj{
                    PersistenceService.context.delete(obj as! DirectPicking)
                }
                
            }
            
        }catch let error {
            print(error.localizedDescription)
            
        }
        
        
    }
    //MARK: End -
    //MARK: - Populate Mandatory Fields
    class func populateMandatoryFieldsMark(_ mandatoryLabels:[UILabel],fontFamily:String,size:CGFloat,color:UIColor){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont(name: fontFamily, size: size)!]
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont(name: fontFamily, size: size)!]
        
        
        for label in mandatoryLabels{
            
            let descText = NSMutableAttributedString(string: label.text ?? "", attributes: custAttributes)
            let starText = NSAttributedString(string: "*", attributes: custTypeAttributes)
            descText.append(starText)
            label.attributedText = descText
        }
    }
    //MARK: - Gtin14 TO NDC
    class  func gtin14ToNdc(gtin14str:String)->NSDictionary {
        let dict =  NSDictionary()
        if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
            let start = gtin14str.index(gtin14str.startIndex, offsetBy: 3)
            let end = gtin14str.index(gtin14str.endIndex, offsetBy: -1)
            let range = start..<end
            let ndcStr = gtin14str[range]
            print(ndcStr)
            
            let startappendingzero = "0" + ndcStr  //Beigin 0 padding 11 digit
            let lastappendingzero =  ndcStr + "0" //Last added 0
   
            let firstfivedigit = ndcStr.prefix(5)
            
            let start1 = ndcStr.index(ndcStr.startIndex, offsetBy: 5)
            let end1 = ndcStr.index(ndcStr.endIndex, offsetBy: -3)
            let range1 = start1..<end1
            let middle = ndcStr[range1]
            let middleappendingzero = "0" + middle
            
            let str = ndcStr as NSString
            let trimStr : String = (ndcStr as NSString).substring(from: max(str.length-3, 0))
            
            
            let ndc_fivethreeone = (firstfivedigit  + middleappendingzero + trimStr)
            
            let filteredArray = allproducts.filter { ($0["identifier_us_ndc"] as? String)! == ndc_fivethreeone }

            if (filteredArray.count>0){
                return filteredArray.first! as NSDictionary
            }
            
            
            let filteredArray1 = allproducts.filter { ($0["identifier_us_ndc"] as? String)! == startappendingzero }
            if (filteredArray1.count>0){
                return filteredArray1.first! as NSDictionary
            }
            
            let filteredArray2 = allproducts.filter { ($0["identifier_us_ndc"] as? String)! == lastappendingzero }
            if (filteredArray2.count>0){
                return filteredArray2.first! as NSDictionary
            }
            
        }
        return dict
    }
    //MARK: End -
    //////////////////////////////////////////////
    //MARK: - Void SO Picking
    
    class func void_SOpicking_session(controller:UIViewController){
        let appendStr:String! = "\(defaults.value(forKey: "SOPickingUUID") ?? "")"
        //self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ShipmentPickings", serviceParam: "" as Any, parentViewC: controller, willShowLoader: false,viewController: controller as! BaseViewController, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                //self.removeSpinner()
                if isDone! {
                    let _: NSDictionary = responseData as! NSDictionary
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let _ = responseDict["message"] as! String
                        //Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                        //Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    //MARK: End -
    ///////////////////////////////////////////////////
    //MARK: - Update UI language
    class func UpdateUILanguage(_ views:[UIView]){
        for view in views{
            if view.isKind(of: UILabel.self){
                let lbl = view as! UILabel
                lbl.text = lbl.text?.localized()
            }else if view.isKind(of: UIButton.self){
                let btn = view as! UIButton
                btn.setTitle(btn.titleLabel?.text?.localized(), for: .normal)
            }else if view.isKind(of: UITextField.self){
                let txtField = view as! UITextField
                txtField.placeholder = txtField.placeholder?.localized()
            }
        }
    }
    //MARK: End -
    /////////////////////////////////
    //MARK: Get Document Directory URL
    class func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    //MARK: End -
    
    
    //MARK: - Convert String
    class func stringConversion(data:Any?) -> String {
        var data_string = "\(data ?? "")"
        data_string = data_string == "<null>" ? "" : data_string
        return data_string
    }//
    
    //MARK: - Return MimeType
    class func getMimeType(fileExtention: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtention as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCreatePreferredIdentifierForTag(uti, kUTTagClassMIMEType, nil)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return ""
    }//
    
    //MARK: - Compress Video File
    static var assetWriter:AVAssetWriter?
    static var assetReader:AVAssetReader?
    static let bitrate:NSNumber = NSNumber(value:250000)
    
    class func compressFile(urlToCompress: URL, outputURL: URL, progressBar: UIProgressView? ,completion:@escaping (URL)->Void){
        
        //video file to make the asset
        
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: urlToCompress);
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        print("Video Actual Duration -- \(durationTime)")
        
        //create asset reader
        do{
            assetReader = try AVAssetReader(asset: asset)
        } catch{
            assetReader = nil
        }
        
        guard let reader = assetReader else{
            fatalError("Could not initalize asset reader probably failed its try catch")
        }
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
        
        let videoReaderSettings: [String:Any] =  [(kCVPixelBufferPixelFormatTypeKey as String?)!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width
        ]
        
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        
        if reader.canAdd(assetReaderVideoOutput){
            reader.add(assetReaderVideoOutput)
        }else{
            fatalError("Couldn't add video output reader")
        }
        
        if reader.canAdd(assetReaderAudioOutput){
            reader.add(assetReaderAudioOutput)
        }else{
            fatalError("Couldn't add audio output reader")
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        //we need to add samples to the video input
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        }catch{
            assetWriter = nil
        }
        guard let writer = assetWriter else{
            fatalError("assetWriter was nil")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: CMTime.zero)
        
        
        let closeWriter:()->Void = {
            
            if (audioFinished && videoFinished){
                
                self.assetWriter?.finishWriting(completionHandler: {
                    
                    print("------ Finish Video Compressing")
                    print("File size after compression::", self.assetWriter?.outputURL.fileSizeString ?? "NA")
                    
                    completion((self.assetWriter?.outputURL)!)
                })
                
                self.assetReader?.cancelReading()
            }
        }
        
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData){
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil){
                    audioInput.append(sample!)
                }else{
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            //request data here
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    let timeStamp = CMSampleBufferGetPresentationTimeStamp(sample!)
                    let timeSecond = CMTimeGetSeconds(timeStamp)
                    let per = timeSecond / durationTime
                    print("Duration --- \(per)")
                    DispatchQueue.main.async {
                        progressBar?.progress = Float(per)
                    }
                    videoInput.append(sample!)
                }else{
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        progressBar?.progress = 1.0
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    //MARK: End -
    
    class func compressVideo(inputURL: URL,
                             outputURL: URL,
                             handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                       presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
}

//MARK: - Extension Methods
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}



