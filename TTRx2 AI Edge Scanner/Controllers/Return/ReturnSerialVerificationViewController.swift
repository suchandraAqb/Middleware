//
//  ReturnSerialVerificationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 12/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class ReturnSerialVerificationViewController: BaseViewController {
    
    @IBOutlet weak var step4View: UIView!
    @IBOutlet weak var step3BarViewContainer: UIView!
    
    @IBOutlet weak var serialsVerificationView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var verifiedSerialsButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var validCountLabel: UILabel!
    @IBOutlet weak var invalidCountLabel: UILabel!
    @IBOutlet weak var pendingCountLabel: UILabel!
    @IBOutlet weak var removedCountLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var itemsVerificationView: UIView!
    
    //MARK: - Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    var isFourStep:Bool!
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet weak var pendingItemsLabel: UILabel!
    //MARK: End -
    
    var allQuarantineScannedSerials = Array<String>()
    var allReusableScannedSerials = Array<String>()
    var allDestructScannedSerials = Array<String>()

    
    var verifiedSerials = Array<Dictionary<String,Any>>()
    private var verifiedLotSerials  = [[String:Any]]()
    
    var failedSerials = Array<Dictionary<String,Any>>()
    var serialScanned = 0
    var isOnVRS = false
    private var lotCounter = 0
    
    
    var disPatchGroup = DispatchGroup()
    let verificationModel = ReturnVerificationModel.ReturnVerificationObj
    
    //TODO: For LotBased
    var allScannedSerials = Array<String>()
    var duplicateSerials = Array<[String:String]>()
    var errorstr =  String()
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotificationForRefreshVerificationSTatus), name: Notification.Name("Return_RefreshProducts"), object: nil)
        
        self.disPatchGroup.notify(queue: .main){
            print("\(self.verifiedSerials.count) All Serials Verified")
        }
        
        sectionView.roundTopCorners(cornerRadious: 40)
        itemsVerificationView.setRoundCorner(cornerRadious: 10)
        serialsVerificationView.setRoundCorner(cornerRadious: 10)
        cameraView.setRoundCorner(cornerRadious: 10)
        populateProductandItemsCount(product: "0", items: "0")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        refresh_counts()
        
    }
    //MARK: End -
    //MARK: - Remove Observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: End -
    
    //MARK: - Private Method
    func refresh_counts(){
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            
            do{
                
                let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchValidSerialRequest(uuid: txt,isDistinct:true ))
                
                //print(return_obj as NSArray)
                if !return_obj.isEmpty{
                    
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: return_obj)
                    if let unique =  (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                        serialScanned = arr.count
                        populateProductandItemsCount(product: "\(unique.count)", items: "\(arr.count)")
                        
                    }
                }else{
                    serialScanned = 0
                    populateProductandItemsCount(product: "0", items: "0")
                }
                
            }catch let error {
                print(error.localizedDescription)
                
            }
            populateStatusLabel()
        }
    }
    
    func setup_stepview(){
        
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        
        
        let isFirstStepCompleted = defaults.bool(forKey: "return_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "return_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "return_3rdStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step1Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
        }else if isFirstStepCompleted && isSecondStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.isUserInteractionEnabled = true
            
            
        }else if isFirstStepCompleted {
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
        }
        
    }
    
    func populateProductandItemsCount(product:String?,items:String?){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 17.0)!]
        let productString = NSMutableAttributedString(string: product ?? "0", attributes: custAttributes)
        let itemsString = NSMutableAttributedString(string: items ?? "0", attributes: custAttributes)
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12.0)!]
        
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" " + "Products".localized() : " " + "Product".localized())", attributes: custTypeAttributes)
        //let itemStr = NSAttributedString(string: " Serials", attributes: custTypeAttributes)
        let itemStr = NSAttributedString(string: "\(Int(items!)!>1 ?" " + "Serials".localized() : " " + "Serial".localized())", attributes: custTypeAttributes)
        
        productString.append(productStr)
        itemsString.append(itemStr)
        
        productCountLabel.attributedText = productString
        itemsCountLabel.attributedText = itemsString
        //itemsCountLabel.textAlignment = .right
        //        productCountLabel.attributedText = itemsString
        //        itemsCountLabel.attributedText = NSAttributedString(string: "", attributes: custTypeAttributes)
    }
    
    
    func populateStatusLabel(){
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Verified.rawValue))
            
            
            if !serial_obj.isEmpty{
                validCountLabel.text = "\(serial_obj.count)"
            }else{
                validCountLabel.text = "0"
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Pending.rawValue))
            
            
            if !serial_obj.isEmpty{
                pendingCountLabel.text = "\(serial_obj.count)"
                pendingItemsLabel.isHidden = false
                pendingItemsLabel.text = "\(serial_obj.count) " + "Item(s) is pending for verifications.".localized()
            }else{
                pendingItemsLabel.isHidden = true
                pendingCountLabel.text = "0"
                pendingItemsLabel.text = "0 " + "Item(s) is pending for verifications.".localized()
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Failed.rawValue))
            
            
            if !serial_obj.isEmpty{
                invalidCountLabel.text = "\(serial_obj.count)"
            }else{
                invalidCountLabel.text = "0"
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Removed.rawValue))
            
            
            if !serial_obj.isEmpty{
                removedCountLabel.text = "\(serial_obj.count)"
            }else{
                removedCountLabel.text = "0"
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
    }
    //MARK: End -
    
    //MARK: - Add Scanned Serials to Return_Serial Table
    func addUpdateSerialsForVerification(serials:[[String : String]]){
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return
        }
        for data in serials {
            
            do{
                
                let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialRequest(barcode: data["code"] ?? ""))
                
                
                if serial_obj.isEmpty{
                    
                    self.allScannedSerials.append(data["code"] ?? "")
                    
                    let obj = Return_Serials(context: PersistenceService.context)
                    obj.barcode = data["code"] ?? ""
                    obj.condition = data["condition"] ?? ""
                    obj.is_send_for_verification = false
                    obj.event_id = ""
                    obj.return_uuid = return_uuid
                    
                    var product_name = ""
                    var lotNumber = ""
                    var product_uuid = ""
                    var status = ""
                    var gtin = ""
                    var serialNumber = ""
                    
                    let details = UtilityScanning(with:data["code"] ?? "").decoded_info
                    if details.count > 0 {
                        
                        if(details.keys.contains("00")){
                            status = Return_Serials.Status.Removed.rawValue
                        }else{
                            if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                                if !allproducts.isEmpty  {
                                    if(details.keys.contains("01")){
                                        if let gtin14 = details["01"]?["value"] as? String{
                                            gtin = gtin14
                                            let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
                                            print(filteredArray as Any)
                                            if filteredArray.count > 0 {
                                                product_name = (filteredArray.first?["name"] as? String)!
                                                product_uuid = (filteredArray.first?["uuid"] as? String)!
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
                            if(details.keys.contains("21")){
                                if let serial = details["21"]?["value"] as? String{
                                    serialNumber = serial
                                }
                            }
                            status = Return_Serials.Status.Pending.rawValue
                        }
                    }
                    
                    obj.product_name = product_name
                    obj.product_uuid = product_uuid
                    obj.lot = lotNumber
                    obj.status = status
                    obj.gtin = gtin
                    obj.serial = serialNumber
                    obj.error=""
                    
                    PersistenceService.saveContext()
                    
                }else{
                    duplicateSerials.append(data)
                    print("Existing Serial Fetched")
                    continue
                }
            }catch let error{
                print(error.localizedDescription)
                
            }
            
        }
        
        populateStatusLabel()
        
    }
    //MARK: END -
    //MARK: - START VERIFYING SERIAL BASED PRODUCT
    func setUpForverifySerials(){
        
        //verifiedSerials = []
        let first = self.allQuarantineScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        
        let second = self.allReusableScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        
        let third = self.allDestructScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        
        if first.count > 0 {
            self.verifyQuarantineSerials(serials: first.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }
        
        if second.count > 0 {
            self.verifyResaleableSerials(serials: second.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }
        
        if third.count > 0 {
            self.verifyDestructSerials(serials: third.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }
        
        if first.isEmpty && second.isEmpty && third.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    
    func startBackgroundStatusUpdate(){
        if !verificationModel.isCheckingInprogress{
            verificationModel.checkForUpdate()
        }
    }
    //MARK: - Verify Serials API Conditions
    func verifyQuarantineSerials(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?action=ADD&condition=\(Return_Serials.Condition.Quarantine.rawValue)&return_uuid=\(defaults.object(forKey: "current_returnuuid") ?? "")&is_vrs_check_enabled=\(self.isOnVRS ? "1" : "0")"
            
            let request = ["serials_list":str]
            disPatchGroup.enter()
            Utility.POSTServiceCall(type: "VerifyReturnSerials", serviceParam:request, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.disPatchGroup.leave()
                    if isDone!{
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                //self.verifiedSerials.append(contentsOf: serialDetailsArray)
                                //self.refreshProductView()
                                self.updateVerifiedSerialsToDB(items: serialDetailsArray, isLot: false)
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
                    
                    self.allQuarantineScannedSerials = Array(self.allQuarantineScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allQuarantineScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    
                    if first.count > 0 {
                        self.verifyQuarantineSerials(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    func verifyResaleableSerials(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?action=ADD&condition=\(Return_Serials.Condition.Resalable.rawValue)&return_uuid=\(defaults.object(forKey: "current_returnuuid") ?? "")&is_vrs_check_enabled=\(self.isOnVRS ? "1" : "0")"
            
            let request = ["serials_list":str]
            disPatchGroup.enter()
            Utility.POSTServiceCall(type: "VerifyReturnSerials", serviceParam:request, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.disPatchGroup.leave()
                    if isDone! {
                        let responseArray: NSArray = responseData as! NSArray
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                            self.updateVerifiedSerialsToDB(items: serialDetailsArray, isLot: false)

                            }
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
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
                    
                    self.allReusableScannedSerials = Array(self.allReusableScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allReusableScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    
                    if first.count > 0 {
                        self.verifyResaleableSerials(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                        
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
        
    }
    
    func verifyDestructSerials(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?action=ADD&condition=\(Return_Serials.Condition.Destruct.rawValue)&return_uuid=\(defaults.object(forKey: "current_returnuuid") ?? "")&is_vrs_check_enabled=\(self.isOnVRS ? "1" : "0")"
            
            let request = ["serials_list":str]
            disPatchGroup.enter()
            Utility.POSTServiceCall(type: "VerifyReturnSerials", serviceParam:request, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.disPatchGroup.leave()
                    if isDone! {
                        let responseArray: NSArray = responseData as! NSArray
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                //self.verifiedSerials.append(contentsOf: serialDetailsArray)
                                self.updateVerifiedSerialsToDB(items: serialDetailsArray, isLot: false)
                                //self.refreshProductView()
                            }
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
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
                    
                    self.allDestructScannedSerials = Array(self.allDestructScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allDestructScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    
                    if first.count > 0 {
                        self.verifyDestructSerials(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                        
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    
    //MARK: - Update Verified Serials to Return Serials Table
    func updateVerifiedSerialsToDB(items:[[String:Any]], isLot: Bool){
        
        for data in items {
            
            do{
                let barcode = data["serial_number"] ?? ""
                
                let predicate = NSPredicate(format: "serial='\(barcode)'")
                
                let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
                
                if !serial_obj.isEmpty{
                        let obj = serial_obj.first!
                        
                        obj.is_send_for_verification = true
                        
                        if let is_ok = data["is_ok"] as? Bool,!is_ok{
                            obj.status = Return_Serials.Status.Removed.rawValue
                        }
                        
                        if let txt = data["error"] as? String{
                            obj.error=txt;
                        }
                        
                        if let txt = data["return_id"] as? String{
                            obj.event_id = txt
                        }
                        
                        if let txt = data["gs1_serial"] as? String{
                            obj.gs1_serial = txt
                        }
                        
                        if let txt = data["product_uuid"] as? String{
                            obj.product_uuid = txt
                        }
                        
                        if let txt = data["lot_number"] as? String{
                            obj.lot = txt
                        }
                        
                        if let txt = data["expiration_date"] as? String{
                            obj.expiration_date = txt
                        }
                    
                    
                    PersistenceService.saveContext()
                    
                }

                
                
            }catch let error{
                print(error.localizedDescription)
                
            }
            
        }
        
        startBackgroundStatusUpdate()
        populateStatusLabel()
        
        //        if self.isLotProductScanned{
        //            self.isLotProductScanned = false
        //            self.moveToLotBasedView()
        //        }else{
        //            if self.isVerified{
        //                self.isVerified = false
        //                Utility.showPopup(Title: Success_Title, Message: "Serial(s) Verified Successfully.".localized() , InViewC: self)
        //            }
        //
        //        }
        
    }
    
    
    //MARK: End -
    
    //MARK: - IBAction
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnProductSummaryView") as! ReturnProductSummaryViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    @IBAction func viewVerifiedSerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnScanSerialsView") as! ReturnScanSerialsViewController
        controller.isOnVRS = self.isOnVRS
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
    DispatchQueue.main.async {
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.isForReturnSerialVerificationScan = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.isForReturnSerialVerificationScan = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
          }
        }
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if serialScanned <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Please scan serial(s) first.".localized(), InViewC: self)
            return
        }
        
        if Int(validCountLabel.text!) == 0 && Int(invalidCountLabel.text!) == 0 {
            Utility.showPopup(Title: App_Title, Message: "No items scanned for return.".localized(), InViewC: self)
            return
        }
        
        
        defaults.set(true, forKey: "return_2ndStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSummaryView") as! ReturnSummaryViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnGeneralInfoViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnGeneralInfoView") as! ReturnGeneralInfoViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3 {
            
            nextButtonPressed(UIButton())
            
            
        }else if sender.tag == 4 {
            if serialScanned <= 0 {
                Utility.showPopup(Title: App_Title, Message: "Please scan serial(s) first.".localized(), InViewC: self)
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnConfirmationView") as! ReturnConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
    }
    //MARK: End -
    
    //MARK: - Local Notification Receiver Method
    @objc func receiveNotificationForRefreshVerificationSTatus(_ notification: NSNotification) {
        // Take Action on Notification
        populateStatusLabel()
    }
    
    //MARK: End -
}
//MARK: - Scan Delegate
extension ReturnSerialVerificationViewController : ScanViewControllerDelegate{
    func didScanCodeForReturnSerialVerification(scannedCode: [String], condition: String) {
        debugPrint("scan code ------\(scannedCode)")
        DispatchQueue.main.async{
            // self.addUpdateSerialsForVerification(serials: scannedCode, condition: condition)
        }
    }
    
    func didScanCodeForReturnSerialVerification(scannedCode: [[String : String]]) {
        debugPrint("scan code ------\(scannedCode)")
        DispatchQueue.main.async{
            
            self.addUpdateSerialsForVerification(serials: scannedCode)
            self.callApiForGS1BarcodeLookupDetails(scannedCode: scannedCode)
        }
    }
}

extension ReturnSerialVerificationViewController : SingleScanViewControllerDelegate{
    
    func didSingleScanCodeForReturnSerialVerification(scannedCode: [String], condition: String) {
        debugPrint("scan code ------\(scannedCode)")
        
        DispatchQueue.main.async{
            //self.addUpdateSerialsForVerification(serials: scannedCode, condition: condition)
        }
    }
    
    func didSingleScanCodeForReturnSerialVerification(scannedCode: [[String : String]]) {
        debugPrint("scan code ------\(scannedCode)")
        
        DispatchQueue.main.async{
            
            self.addUpdateSerialsForVerification(serials: scannedCode)
            self.callApiForGS1BarcodeLookupDetails(scannedCode: scannedCode)
            
            //self.setUpForverifySerials()
        }
    }
}
//MARK: End -
//MARK: - For Lot Based functionality
extension ReturnSerialVerificationViewController{
    
    func callApiForGS1BarcodeLookupDetails(scannedCode: [[String : String]]){
        //        self.isVerified = false
        //        self.isLotProductScanned = false
        verifiedSerials = []
        verifiedLotSerials = []
        //Utility.removeReturnLotDB()
        self.lotCounter = 0
        //        self.allScannedSerials.append(contentsOf: scannedCode)
        //        self.allScannedSerials = Array(Set(self.allScannedSerials))
        
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
        //        let arrayRemainingLetters = allSerials.filter {
        //            !first3.contains($0)
        //        }
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode)
            self.showSpinner(onView: self.view)
        }else if duplicateSerials.count>0{
            duplicateSerials = []
            Utility.showPopup(Title: App_Title, Message: "Serial(s) already scanned.".localized(), InViewC: self)
            return
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    
    private func getGS1BarcodeLookupDetails(serials : String, scannedCode: [[String : String]]){
        
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?gs1_barcode=\(str ?? "")"
            
            Utility.GETServiceCall(type: "GS1BarcodeLookup", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                // DispatchQueue.main.async{
                if isDone! {
                    let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                    print(responseArray as NSArray)
                    if responseArray.count > 0{
                        if let serialDetailsArray = responseArray as? [[String : Any]]{
                            self.verifiedSerials.append(contentsOf: serialDetailsArray)
                            
                            //                            //Lot Based
                            //                            let lotBased = serialDetailsArray.filter({$0["status"] as? String == "LOT_FOUND"})
                            //
                            //                            self.verifiedLotSerials.append(contentsOf: lotBased)
                            
                            //print("",self.verifiedSerials)
                            //self.refreshProductView()
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
                
                let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
                
                if first.count > 0 {
                    self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode)
                }else{
                    self.removeSpinner()
                    self.updateLotBasedSerialsToDB(scannedCode: scannedCode)
                }
                // }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    //MARK: - Private Method
    private func updateLotBasedSerialsToDB(scannedCode: [[String : String]]){
        //self.addUpdateSerialsForVerification(serials: scannedCode)
        
        for data in verifiedSerials {
            
            do{
                let barcode = data["gs1_barcode"] ?? ""
                
                let predicate = NSPredicate(format:"barcode='\(barcode)'")
                let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
                
                print(serial_obj)
                
                if !serial_obj.isEmpty{
                    
                    let obj = serial_obj.first!
                    
                    ///////////////////////////////////CHECKING FOR VERIFIED SERIALS///////////////////////////////////
                    if let status = data["status"] as? String{
                        
                        obj.expiration_date = data["expiration_date"] as? String ?? ""
                        
                        _ = (data["is_available_for_sale"] as? Bool) ?? false
                        //&& is_available_for_sale
                        if status == "FOUND" {
                            
                            obj.is_lot_based = false
                            obj.is_valid = true
                            
                            let code =  obj.barcode
                            let condition = obj.condition
                            
                            if let condition = condition, condition == Return_Serials.Condition.Quarantine.rawValue, let code = code{
                                
                                //TODO: Append allQuarantineScannedSerials
                                allQuarantineScannedSerials.append(code)
                                
                            }else if let condition = condition, condition == Return_Serials.Condition.Resalable.rawValue, let code = code {
                                
                                //TODO: Append allReusableScannedSerials
                                allReusableScannedSerials.append(code)
                                
                            }else if let condition = condition, condition == Return_Serials.Condition.Destruct.rawValue, let code = code {
                                
                                //TODO: Append allDestructScannedSerials
                                allDestructScannedSerials.append(code)
                                
                            }
                            //&& is_available_for_sale
                        }else if status == "LOT_FOUND" {
                            
                            obj.is_lot_based = true
                            obj.is_valid = true
                            //obj.lot_based_qty += 1
                            
                            //let code =  obj.barcode
                            let condition = obj.condition
                            
                            if let condition = condition, condition == Return_Serials.Condition.Quarantine.rawValue{
                                
                                //TODO: Append lotQuarantineScannedSerials
                                //lotQuarantineScannedSerials.append(code)
                                obj.lot_based_qty_quarantine += 1
                                
                            }else if let condition = condition, condition == Return_Serials.Condition.Resalable.rawValue{
                                
                                //TODO: Append lotReusableScannedSerials
                                //lotReusableScannedSerials.append(code)
                                obj.lot_based_qty_reusable += 1
                                
                            }else if let condition = condition, condition == Return_Serials.Condition.Destruct.rawValue{
                                
                                //TODO: Append lotDestructScannedSerials
                                //lotDestructScannedSerials.append(code)
                                obj.lot_based_qty_desturction += 1
                            }
                            
                        }else{
                            
                            obj.is_lot_based = false
                            obj.is_valid = false
                            
                        }
                    }
                    
                }
            }catch(let error){
                print(error.localizedDescription)
            }
        }
        
        
        if let index = self.verifiedSerials.firstIndex(where: {$0["status"] as? String == "FOUND"}){
            print("Serial Based Found at index::", index)
            self.setUpForverifySerials()
        }
        if let index = self.verifiedSerials.firstIndex(where: {$0["status"] as? String == "LOT_FOUND"}){
            print("Lot Based Found at index::", index)
            self.saveLotBasedFilteredData()
        }
        //if self.verifiedSerials
        print(self.verifiedSerials)
        print(scannedCode)
        
    }
    
    
    private func saveLotBasedFilteredData() {
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return
        }
        
        do{
            let predicate = NSPredicate(format:"is_lot_based == %@", NSNumber(value: true))
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
            print(serial_obj)
            
            
            
            for item in serial_obj{
                
                do{
                    let predicate = NSPredicate(format:"lot == '\(item.lot ?? "")'")
                    
                    let fetchRequest = NSFetchRequest<Return_Lot>(entityName: "Return_Lot")
                    fetchRequest.predicate = predicate
                    
                    let serial_obj = try PersistenceService.context.fetch(fetchRequest)
                    
                    if serial_obj.isEmpty{
                        
                        let obj = Return_Lot(context: PersistenceService.context)
                        obj.return_uuid = return_uuid
                        obj.serial = item.serial
                        obj.condition = item.condition
                        obj.product_uuid = item.product_uuid
                        obj.product_name = item.product_name
                        obj.expiration_date = item.expiration_date
                        obj.lot = item.lot
                        obj.lot_based_qty_reusable = item.lot_based_qty_reusable
                        obj.lot_based_qty_desturction = item.lot_based_qty_desturction
                        obj.lot_based_qty_quarantine = item.lot_based_qty_quarantine
                        obj.quantity = obj.lot_based_qty_reusable+obj.lot_based_qty_desturction+obj.lot_based_qty_quarantine
                        
                    }else{
                        
                        let addedObj = serial_obj.first
                        
                        addedObj?.lot_based_qty_reusable = (addedObj?.lot_based_qty_reusable ?? 0)+item.lot_based_qty_reusable
                        
                        addedObj?.lot_based_qty_quarantine = (addedObj?.lot_based_qty_quarantine ?? 0)+item.lot_based_qty_quarantine
                        
                        addedObj?.lot_based_qty_desturction = (addedObj?.lot_based_qty_desturction ?? 0)+item.lot_based_qty_desturction
                        
                        addedObj?.quantity = (addedObj?.lot_based_qty_reusable ?? 0) + (addedObj?.lot_based_qty_quarantine ?? 0) + (addedObj?.lot_based_qty_desturction ?? 0)
                        
                        print("ERROR::::Product Already Added")
                    }
                    
                }catch let error{
                    print(error.localizedDescription)
                }
                
            }
            
            //self.addSerialWebServiceCall(lotItem: item, itemCount: similarProduct.count)
            PersistenceService.saveContext()
            
        }catch (let error){
            print(error.localizedDescription)
        }
        self.verifyLotBasedSerials()
        
    }
    
    private func verifyLotBasedSerials(){
        //60d22ab7-1ce7-476a-9165-b552c10dc14a
        //9fed7b94-593c-471b-be37-4254d455341e
        do{
            
            //let predicate = NSPredicate(format:"lot == '\()'")
            
            let fetchRequest = NSFetchRequest<Return_Lot>(entityName: "Return_Lot")
            //fetchRequest.predicate = predicate
            
            
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            print(serial_obj)
            
            self.addSerialWebServiceCall(lotItem: serial_obj)
            
            
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: - API CALL
    private func addSerialWebServiceCall(lotItem: [Return_Lot]){
        
        var requestDict = [String:Any]()
        
        requestDict["return_uuid"] = defaults.object(forKey: "current_returnuuid") as? String
        requestDict["format"] = "LOT_BASED"
        requestDict["action"] = "ADD"
        requestDict["serial"] = lotItem[lotCounter].serial
        requestDict["condition"] = lotItem[lotCounter].condition
        requestDict["product_uuid"] = lotItem[lotCounter].product_uuid
        requestDict["lot_number"] = lotItem[lotCounter].lot
        requestDict["quantity"] = lotItem[lotCounter].quantity
        requestDict["expiration_date"] = lotItem[lotCounter].expiration_date
        
        requestDict["is_vrs_check_enabled"] = self.isOnVRS ? "1" : "0"
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "RemoveReturnSerial", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                    
                    if let id = responseDict["return_id"] as? String{
                        
                        let lot = responseDict["lot"] as? String ?? ""
                        let is_ok = true
                        self.lotCounter += 1
                        do{
                            
                            let predicate = NSPredicate(format:"lot == '\(lot)'")
                            let fetchRequest = NSFetchRequest<Return_Serials>(entityName: "Return_Serials")
                            
                            fetchRequest.predicate = predicate
                            
                            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
                            
                            for item in serial_obj{
                                
                                self.verifiedLotSerials.append(["lot_number": item.lot ?? "","return_id": id, "is_ok": is_ok, "product_uuid" : item.product_uuid ?? "", "expiration_date" : item.expiration_date ?? "", "serial_number": item.serial ?? ""] as [String:Any])
                            }
                            
                            
                        }catch let error{
                            print(error.localizedDescription)
                        }
                        
                        if self.lotCounter < lotItem.count{
                            
                            self.addSerialWebServiceCall(lotItem: lotItem)
                            
                        }else{
                            
                            self.updateVerifiedSerialsToDB(items: self.verifiedLotSerials, isLot: true)
                        }
                        
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
            }
        }
    }
    
    private func updateCondition(returnId: String, lotItem: Return_Lot){
        
        var requestDict = [String:Any]()
        
        requestDict["return_uuid"] = defaults.object(forKey: "current_returnuuid") as? String
        requestDict["return_id"] = returnId
        requestDict["lot_based_qty_reusable"] = "\(lotItem.lot_based_qty_reusable)"
        requestDict["lot_based_qty_quarantine"] = "\(lotItem.lot_based_qty_quarantine)"
        requestDict["lot_based_qty_destruct"] = "\(lotItem.lot_based_qty_desturction)"
        
        
        self.showSpinner(onView: self.view)
        
        Utility.PUTServiceCall(type: "RemoveReturnSerial", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                    
                    if let _ = responseDict["return_id"] as? String {
                        
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
            }
        }
    }
}
