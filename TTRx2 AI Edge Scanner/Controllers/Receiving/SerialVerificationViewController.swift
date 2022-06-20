//
//  SerialVerificationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 28/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import LinearProgressView


class SerialVerificationViewController: BaseViewController {
    var shipmentId:String?
    
    @IBOutlet weak var step5View: UIView!
    @IBOutlet weak var step4BarViewContainer: UIView!
    
    @IBOutlet weak var minimumVerificationView: UIView!
    @IBOutlet weak var nonMinimumVerificationView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var verifiedSerialsButton: UIButton!
    @IBOutlet weak var verifiedSerialsButton1: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var progressBarView:LinearProgressView!
    @IBOutlet weak var minSuccessCountLabel: UILabel!
    @IBOutlet weak var minAttemptCountLabel: UILabel!
    @IBOutlet weak var minfailedCountLabel: UILabel!
    @IBOutlet weak var minToVerifyCountLabel: UILabel!
    @IBOutlet weak var nonMinSuccessCountLabel: UILabel!
    @IBOutlet weak var nonMinAttemptCountLabel: UILabel!
    @IBOutlet weak var nonMinfailedCountLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: Step Items
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step5Button: UIButton!
    
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step4BarView: UIView!
    
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    
    var isFiveStep:Bool!
    
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var triggerSwitch:UISwitch!

    //MARK: - End
    
    var allScannedSerials = Array<String>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var failedSerials = Array<Dictionary<String,Any>>()
    var minimumSerialsToVerify = 0
    
    var basicQueryResultArray = Array<Dictionary<String,Any>>()
    var isLotBased  : Bool = false
    var isLotProductScan :Bool = false
    var responseDict : NSDictionary?
    var isReceiveProductInshipment:Bool!
    var shipementProductCheck :Bool!
    var scanLotbasedArray:Array<Any>?
    var triggerScanEnable : Bool = false
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shipmentId = defaults.string(forKey: "shipmentId")
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotificationForSerialUpdate(notification:)), name: Notification.Name("UpdateVerifiedSerials"), object: nil)
        isFiveStep = defaults.bool(forKey: "isFiveStep")
        if !isFiveStep{
            step4Label.text = "Confirm Receiving"
            step5View.isHidden = true
            step4BarViewContainer.isHidden = true
        }
        
        sectionView.roundTopCorners(cornerRadious: 40)
        nonMinimumVerificationView.setRoundCorner(cornerRadious: 10)
        minimumVerificationView.setRoundCorner(cornerRadious: 10)
        cameraView.setRoundCorner(cornerRadious: 10)
        minimumVerificationView.isHidden = false
        
        if let shipmentData = defaults.object(forKey: ttrShipmentDetails) as? Data{
            do{
                let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData) as! NSDictionary
                
                if let minVerRequired = shipmentDict["minimum_serials_count_to_validate"] as? Int{
                    
                    if minVerRequired > 0 {
                        minimumSerialsToVerify = minVerRequired
                        progressBarView.maximumValue = Float(minVerRequired)
                        progressBarView.minimumValue = Float(0)
                        minimumVerificationView.isHidden = false
                        nonMinimumVerificationView.isHidden = true
                        minToVerifyCountLabel.text = "\(minVerRequired)"
                    }else{
                        minimumVerificationView.isHidden = true
                        nonMinimumVerificationView.isHidden = false
                    }
                }                
            }catch{
                print("Shipment Data Not Found")
            }
        }
        self.clearAttemptData()
        self.getVerifiedSerials()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected 
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        basicQueryResultArray = []
        setup_stepview()
        self.refreshVerificationView()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateVerifiedSerials"), object: nil)
    }
    
    //MARK: - End
    //MARK: - Private Method
    
    func callApiForSerialVerification(scannedCode: [String]){
        self.allScannedSerials.append(contentsOf: scannedCode)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
        //        let arrayRemainingLetters = allSerials.filter {
        //            !first3.contains($0)
        //        }
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"),scannedcode:scannedCode)
           // self.serialVerification(serials: first.joined(separator: "\n"))
            self.showSpinner(onView: self.view)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.", InViewC: self)
            return
        }
    }
    func clearAttemptData(){
        if let tempfailedArray = Utility.getObjectFromDefauls(key: "\(self.shipmentId ?? "")_failedArray") as? [[String : Any]]{
            self.failedSerials = tempfailedArray
            print(self.verifiedSerials)

        }else{
            self.failedSerials = Array<Dictionary<String,Any>>()
        }
        if let tempVerifiedArray = Utility.getObjectFromDefauls(key: "\(self.shipmentId ?? "")_verifiedArray") as? [[String : Any]]{
            self.verifiedSerials = tempVerifiedArray
            print(self.verifiedSerials)
        }else{
            self.verifiedSerials = Array<Dictionary<String,Any>>()
        }
    }
    func refreshVerificationView(){
        print(self.failedSerials)
        if let tempVerifiedArray = Utility.getObjectFromDefauls(key: "\(self.shipmentId ?? "")_verifiedArray") as? [[String : Any]]{
            self.verifiedSerials = tempVerifiedArray
        }
        if minimumVerificationView.isHidden {
            nonMinfailedCountLabel.text = "\(String(describing: self.failedSerials.count))"
            nonMinSuccessCountLabel.text = "\(String(describing: self.verifiedSerials.count))"
            nonMinAttemptCountLabel.text = "\(String(describing: self.failedSerials.count + self.verifiedSerials.count))"
            
        }else{
            //        progressBarView.maximumValue = Float(120)
            //        progressBarView.minimumValue = Float(0)
            progressBarView.setProgress(Float(self.verifiedSerials.count), animated: true)
            minfailedCountLabel.text = "\(String(describing: self.failedSerials.count))"
            minSuccessCountLabel.text = "\(String(describing: self.verifiedSerials.count))"
            minAttemptCountLabel.text = "\(String(describing: self.failedSerials.count + self.verifiedSerials.count))"
            
        }
    }
    func getGS1BarcodeLookupDetails(serials : String,scannedcode:[String]){
        
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?gs1_barcode=\(str ?? "")"
            
            Utility.GETServiceCall(type: "GS1BarcodeLookup", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        self.clearAttemptData()
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let arr = responseArray as? [[String : Any]]{
                                self.basicQueryResultArray.append(contentsOf: arr)
                                Utility.saveObjectTodefaults(key: "\(self.shipmentId ?? "")_basicQueryResultArray", dataObject: self.basicQueryResultArray)
                               
                                for dict in arr {
                                    let is_available_for_sale = (dict["is_available_for_sale"] as? Bool) ?? false
                                    if dict["status"] as! String == "FOUND" && !is_available_for_sale{
                                        self.isLotProductScan = false
                                        self.serialVerification(serials: dict["gs1_barcode"] as! String, scannedcode: scannedcode)
                                    }else if (dict["status"] as! String == "LOT_FOUND" && !is_available_for_sale){
                                        self.isLotProductScan = true
                                        if self.triggerScanEnable {
                                            self.dismiss(animated: false) {
                                                let controller = self.navigationController?.visibleViewController
                                                if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                                                self.navigationController?.popViewController(animated: false)
                                              }
                                            }
                                         }
                                    }
                                }
                                var quantity = 0
                                var scanarr = self.basicQueryResultArray as NSArray
                                self.isReceiveProductInshipment = false
                                
                                if self.triggerScanEnable{
                                    let arr = NSMutableArray()
                                    for product in self.scanLotbasedArray!{
                                            let quantity = (product as! ProductListModel).productCount
                                            let uuid:String = (product as! ProductListModel).uuid!
                                            let lotNumber:String = (product as! ProductListModel).lotNumber!
                                            let predicate = NSPredicate(format: "lot_number = '\(lotNumber)' and product_uuid = '\(uuid)'")
                                            let filterarr = scanarr.filtered(using: predicate)
                                            if filterarr.count > 0 {
                                                for _ in 0..<quantity! {
                                                    arr.add(filterarr.first as Any)
                                                }
                                           }
                                      }
                                    scanarr = arr.mutableCopy() as! NSArray
                                }

                                if let items = self.responseDict!["ship_lines_item"] as? Array<Any>  {
                                    for item in items{
                                        let itemDict = item as! NSDictionary
                                        let lots = itemDict["lots"] as! NSArray
                                        if ((itemDict["is_having_serial"]) != nil && !(itemDict["is_having_serial"] as! Bool)){
                                        for lot in lots {
                                            let lotDict = lot as! NSDictionary
                                            let predicate = NSPredicate(format: "lot_number = '\(lotDict["lot_number"] ?? 0)'")
                                            let filterarr = scanarr.filtered(using: predicate)
                                            if filterarr.count > 0 {
                                                    if filterarr.count == (lotDict["quantity"] as! Int){
                                                    self.isReceiveProductInshipment = true
                                                }
                                            }
                                            quantity = quantity + (lotDict["quantity"] as! Int)
                                        }
                                       }
                                    }
                                    if quantity == scanarr.count && self.isReceiveProductInshipment{
                                        self.verifiedSerials = scanarr as! [[String : Any]]
                                        Utility.saveObjectTodefaults(key: "\(self.shipmentId ?? "")_verifiedArray", dataObject: self.verifiedSerials)
                                        self.refreshVerificationView()
                                    }
                                }
                               
                                var count = 0
                                for dict in arr {
                                    let is_available_for_sale = (dict["is_available_for_sale"] as? Bool) ?? false
                                    if dict["status"] as! String == "FOUND" && is_available_for_sale{
                                        count = count + 1
                                    }
                                }
                                if count == arr.count {
                                    Utility.showPopup(Title: App_Title, Message: "Product alredy exist in inventory.", InViewC: self)
                                }
                                
                            }
                        }else{
                            
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)

                        }
                    }else{
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                            let errorMsg = responseDict["message"] as? String ?? ""
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))

                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)

                    if first.count > 0 {
                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedcode: scannedcode)
                    }else{
                        self.removeSpinner()
                        if !self.triggerScanEnable {
                            if (self.verifiedSerials.count != self.basicQueryResultArray.count) && self.isLotProductScan{
                                Utility.showPopup(Title: App_Title, Message: "Mismatch between shipment items and product verfication", InViewC: self)

                            }
                        }else{
                            if self.isLotProductScan {
                                var qty = 0
                                for product in self.scanLotbasedArray!{
                                    qty = qty + (product as! ProductListModel).productCount!
                                }
                            if qty == self.verifiedSerials.count{
                                    self.nextButtonPressed(UIButton())
                            }else{
                                Utility.showPopup(Title: App_Title, Message: "Mismatch between shipment items and product verfication", InViewC: self)

                              }
                           }
                        }
                    }
                    self.removeSpinner()
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
        
    }
    func checkitems(productGtin14:String,lotNumber:String,Productname:String,expirationDate:String){
       if let items = self.responseDict!["ship_lines_item"] as? Array<Any>  {
           let itemArr = items as NSArray
           for item in itemArr {
               let dict = item as! NSDictionary
               var gtin14Str = ""
               if (dict["gtin14"] is NSNull) {
                   gtin14Str = dict["ndc"] as! String
               }else{
                   gtin14Str = dict["gtin14"] as! String
               }
               
            shipementProductCheck = false
               if gtin14Str == productGtin14 &&  (Productname == dict["name"] as! String) {
                       if((dict["lots"]) != nil){
                           let lots = dict["lots"] as! NSArray
                           let predicate = NSPredicate(format: "lot_number = '\(lotNumber)'")
                           let filterarr = lots.filtered(using: predicate)
                           if filterarr.count>0 {
                               shipementProductCheck = true
                            }
                       }else{
                             shipementProductCheck = true
                       }
                  }
             }
       }
   }
    @objc func getVerifiedSerials(){
        let appendStr:String! = (shipmentId ?? "") + "/verify"
       // self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ReceivingVerifiedSerials", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
               // self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let serials_validated: [[String : Any]] = responseDict["serials_validated"] as? [[String : Any]] {
                        self.verifiedSerials = serials_validated
                        Utility.saveObjectTodefaults(key: "\(self.shipmentId ?? "")_verifiedArray", dataObject: self.verifiedSerials)
                        if self.scanLotbasedArray != nil && !self.scanLotbasedArray!.isEmpty{
                            if self.triggerScanEnable {
                                self.dismiss(animated: false) {
                                    let controller = self.navigationController?.visibleViewController
                                    if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                                    self.navigationController?.popViewController(animated: false)
                                  }
                                }
                                self.nextButtonPressed(UIButton())

                             }
                        }
                    }else{
                        self.verifiedSerials = Array<Dictionary<String,Any>>()
                        defaults.removeObject(forKey: "\(self.shipmentId ?? "")_verifiedArray")
                    }
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
                self.refreshVerificationView()
            }
        }
    }
    
    func serialVerification(serials : String,scannedcode:[String]){
        
        if !serials.isEmpty{
            var requestDict = [String:Any]()
            requestDict["type"] = "GS1_BARCODE" // Test Client ID
            requestDict["serials_list"] = serials
            
            
            let  appendStr = "\(shipmentId ?? "")/verify"
            let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            Utility.POSTServiceCall(type: "VerifyShipmentsForReceiving", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: escapedString, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    //                    if(MaxNumberOfSerialsForVerification <= self.allScannedSerials.count){
                    //                        self.allScannedSerials = Array(self.allScannedSerials.suffix(from:MaxNumberOfSerialsForVerification))
                    //                    }else{
                    //                        self.allScannedSerials = Array<String>()
                    //                    }
                    if isDone! {
                        let responseArray: NSArray = responseData as! NSArray
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                for serialDetails in serialDetailsArray {
                                    if let result = serialDetails["result"] as? String {
                                        if result == "NOT_FOUND" {
                                            if let serial_validated = serialDetails["serial_validated"] as? [String : Any]{
                                                if !(self.failedSerials as NSArray).contains(serial_validated){
                                                    self.failedSerials.append(serial_validated)
                                                }
                                            }
                                        }
                                    }
                                }
                                print(self.failedSerials)
                                Utility.saveObjectTodefaults(key: "\(self.shipmentId ?? "")_failedArray", dataObject: self.failedSerials)
                            }
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later." , InViewC: self)
                        }
                    }else{
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            let errorMsg = responseDict["message"] as! String
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
//                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.split(separator: "\n").count))
//
//                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
//                    //        let arrayRemainingLetters = allSerials.filter {
//                    //            !first3.contains($0)
//                    //        }
//                    if first.count > 0 {
//                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\n"), scannedcode: scannedcode)
//                    }else{
//                        self.removeSpinner()
//                        self.getVerifiedSerials()
//                    }
                    self.removeSpinner()
                    self.getVerifiedSerials()

                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
        
    }
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "rec_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "rec_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "rec_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "rec_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            //step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    func showAlertForNonserialized(){
        let popUpAlert = CustomAlert(title: Info!, message: "Verification process is only applicable to serialized product.(Support EPCIS)", preferredStyle: .alert)
        popUpAlert.setTitleImage(UIImage(named: "info"))
        
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: {_ in
            if(defaults.bool(forKey: "IsMultiScan")){
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isForReceivingSerialVerificationScan = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.isForReceivingSerialVerificationScan = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
                }
        })
        
        popUpAlert.addAction(okAction)
        
        self.present(popUpAlert, animated: true, completion: nil)
        
    }
    
    //chayan
    func addUpdateFailedSerialsToDB(scannedCode: [String]){
        for data in scannedCode {
            do{
                let predicate = NSPredicate(format:"scanned_code='\(data)'")
                let serial_obj = try PersistenceService.context.fetch(InboundFailedSerials.fetchRequestWithPredicate(predicate: predicate))
                
                if serial_obj.isEmpty{
                    let obj = InboundFailedSerials(context: PersistenceService.context)
                    obj.scanned_code = data
                    obj.shipment_id = shipmentId
                    obj.reason = "Invalid Shipment"
                    
                    var product_name = ""
                    var lotNumber = ""
                    var product_uuid = ""
                    var gtin = ""
                    var serialNumber = ""
                    var idValue = ""
                    var expDate = ""
                    
                    let details = UtilityScanning(with:data).decoded_info
                    if details.count > 0 {
                        
                        if(details.keys.contains("00")){
                            
                        }else{
                            if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                                if !allproducts.isEmpty  {
                                    if(details.keys.contains("01")){
                                        if let gtin14 = details["01"]?["value"] as? String{
                                            gtin = gtin14
                                            let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
                                            print(filteredArray as Any)
                                            if filteredArray.count > 0 {
                                                product_name = (filteredArray.first?["name"] as? String)!
                                                product_uuid = (filteredArray.first?["uuid"] as? String)!
                                                idValue =  (filteredArray.first?["identifier_us_ndc"] as? String) ?? ""
                                            }
                                        }
                                    }
                                }
                            }
                            if(details.keys.contains("10")){
                                if let lot = details["10"]?["value"] as? String{
                                    lotNumber = lot
                                }
                            }
                            if(details.keys.contains("17")){
                                if let exp = details["17"]?["value"] as? String{
                                    expDate = exp
                                }
                            }
                            if(details.keys.contains("21")){
                                if let serial = details["21"]?["value"] as? String{
                                    serialNumber = serial
                                }
                            }
                            
                        }
                        
                    }
                    obj.product_name = product_name
                    obj.product_uuid = product_uuid
                    obj.lot_number = lotNumber
                    obj.gtin14 = gtin
                    obj.serial_number = serialNumber
                    obj.expiration_date = expDate
                    
                    PersistenceService.saveContext()
                    print("Data saved at : " , FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not found")
                }else{
                    print("Existing Serial Fetched")
                    continue
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func viewVerifiedSerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "VerifiedSerialsView") as! VerifiedSerialsViewController
        controller.failedSerials = self.failedSerials
        controller.verfiedLotSerials = self.verifiedSerials
        controller.isLotBased = isLotProductScan
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func toggleSingleMultiScan(_ sender: UIButton) {
        sender.isSelected.toggle()
        defaults.set(sender.isSelected, forKey: "IsMultiScan")
        multiButton.isSelected = sender.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        //        if isLotBased {
        //            isLotBased = false
        //            self.showAlertForNonserialized()
        //        }else{
                DispatchQueue.main.async {
                    if(defaults.bool(forKey: "IsMultiScan")){
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                        if self.triggerScanEnable {
                            controller.isForBottomSheetScan = true
                        }else{
                            controller.isForOnlyReceive = true

                        }
                        controller.delegate = self
                        if (self.responseDict!["ship_lines_item"] != nil)  {
                            controller.lineItemsArr = self.responseDict!["ship_lines_item"] as? Array<Any>
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }else{
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                            if self.triggerScanEnable {
                                controller.isForBottomSheetScan = true
                            }else{
                                controller.isForOnlyReceive = true
                        }
                        controller.delegate = self
                        if (self.responseDict!["ship_lines_item"] != nil)  {
                            controller.lineItemsArr = self.responseDict!["ship_lines_item"] as? Array<Any>
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                }
        //        }
            }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if minimumSerialsToVerify > 0 && verifiedSerials.count < minimumSerialsToVerify {
            Utility.showPopup(Title: App_Title, Message: "Please verify minimum \(minimumSerialsToVerify) \(minimumSerialsToVerify > 1 ? "serials": "serial") to proceed." , InViewC: self)
            return
        }
        defaults.set(true, forKey: "rec_3rdStep")
        if isFiveStep {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "StorageSelectionView") as! StorageSelectionViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ShipmentDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2{
            
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: PurchaseOrderVC.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 4 {
            if minimumSerialsToVerify > 0 && verifiedSerials.count < minimumSerialsToVerify {
                Utility.showPopup(Title: App_Title, Message: "Please verify minimum \(minimumSerialsToVerify) \(minimumSerialsToVerify > 1 ? "serials": "serial") to proceed." , InViewC: self)
                return
            }
            if isFiveStep {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "StorageSelectionView") as! StorageSelectionViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }else{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }else if sender.tag == 5 {
            if minimumSerialsToVerify > 0 && verifiedSerials.count < minimumSerialsToVerify {
                Utility.showPopup(Title: App_Title, Message: "Please verify minimum \(minimumSerialsToVerify) \(minimumSerialsToVerify > 1 ? "serials": "serial") to proceed." , InViewC: self)
                return
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    @IBAction func triggerScanEnableSwitch(_ sender: UISwitch){
        if sender.isOn{
            triggerScanEnable = true
        }else{
            triggerScanEnable = false
        }
        defaults.set(triggerScanEnable, forKey: "trigger_Scan")
    }
    //MARK: - End
    
    //MARK: - Local Notification Receiver Method
    @objc func receiveNotificationForSerialUpdate(notification: NSNotification) {
        // Take Action on Notification
        getVerifiedSerials()
    }
    
    //MARK: - End
}
extension SerialVerificationViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            self.callApiForSerialVerification(scannedCode: scannedCode)
        }
    }
    func didScanCodeForFailedSerial(scannedCode: [String]){
        self.addUpdateFailedSerialsToDB(scannedCode: scannedCode)
    }
    func didLotBasedTriggerScanDetailsForLotBased(arr : NSArray){
         scanLotbasedArray = arr.mutableCopy() as? Array<Any>

     }
}


extension SerialVerificationViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            self.callApiForSerialVerification(scannedCode: scannedCode)
//            let failedArr = ["010083491310500821133413571022612\u{1D}172312011058BA533A","010083491310500821133413571991255\u{1D}172312011058BA533A"]
        }
    }
    func didSingleScanCodeForFailedSerial(scannedCode: [String]){
        self.addUpdateFailedSerialsToDB(scannedCode: scannedCode)
    }
    func didLotBasedTriggerScanDetails(arr : NSArray){
        scanLotbasedArray = arr.mutableCopy() as? Array<Any>
    }
}
