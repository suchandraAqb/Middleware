//
//  PickingScanItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 12/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingScanItemsViewController: BaseViewController {
    
    var allScannedSerials = Array<String>()
    var scannedCodeArr = Array<String>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var verifiedAlertSerials = Array<Dictionary<String,Any>>()
    
    var failedSerials = Array<Dictionary<String,Any>>()
    var failedAlertSerials = Array<Dictionary<String,Any>>()
    var lotBasedProducts = Array<Dictionary<String,Any>>()
    var triggerScanEnable : Bool = false

    @IBOutlet weak var itemsVerificationView: UIView!
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var addLotbaseButton: UIButton!
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var triggerSwitch:UISwitch!
    @IBOutlet weak var failedItemsButton:UIButton!
    @IBOutlet weak var failedItemsDot:UIButton!
    //MARK: - End
    
    var isVerified = false
    var scanLotbasedArray:Array<Any>?
    var isTriggerEnableErrorpopupText : String = ""
    var isPickingLotAdded : Bool = false

    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        itemsVerificationView.setRoundCorner(cornerRadious: 10)
        cameraView.setRoundCorner(cornerRadious: 10)
        addLotbaseButton.setBorder(width: 1.0, borderColor: Utility.hexStringToUIColor(hex: "719898"), cornerRadious: addLotbaseButton.frame.size.height/2.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        self.multiButton.isSelected = singleMultiScanButton.isSelected
        self.multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        self.singleButton.isSelected = !multiButton.isSelected
        self.singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        if let tempVerifiedSerials = Utility.getObjectFromDefauls(key: "VerifiedSalesOrderByPickingArray") as? [[String : Any]]{
            self.verifiedSerials = tempVerifiedSerials
            print(self.verifiedSerials as NSArray)
        }else{
            self.verifiedSerials = Array<Dictionary<String,Any>>()
        }
        if let tempFailedSerials = Utility.getObjectFromDefauls(key: "FailedSalesOrderByPickingArray") as? [[String : Any]]{
            self.failedSerials = tempFailedSerials
            print(self.failedSerials as NSArray)
        }else{
            self.failedSerials = Array<Dictionary<String,Any>>()
        }
        if isPickingLotAdded && triggerScanEnable{
            isPickingLotAdded = false
            self.nextButtonPressed(UIButton())
        }
        self.checkNewfailedItems()
        self.refreshProductView()
        self.setup_stepview()
       
    }
    //MARK: - End
    
    //MARK: - Private Method
    func callApiForSalesOrderByPicking(scannedCode: [String]){
        self.isVerified = false
        self.lotBasedProducts = Array<Dictionary<String,Any>>()
        allScannedSerials = Array<String>()
        self.allScannedSerials.append(contentsOf: scannedCode)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        //        let arrayRemainingLetters = allSerials.filter {
        //            !first3.contains($0)
        //        }
        if first.count > 0 {
            self.salesOrderByPicking(serials: first.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    
    func refreshProductView(){
        var product = "0"
        var serial = "0"
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            let arr = exProducts as NSArray?
            if let uniqueArr = arr?.value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                product = "\(uniqueArr.count)"
            }
            
        }
        serial = "\(String(describing: self.verifiedSerials.count))"
        populateProductandItemsCount(product: product, items: serial)
        
    }
    func setuplotDetails(){
//        do{
//            let serial_obj = try PersistenceService.context.fetch(LotbasedTriggerscan.fetchRequest())
//
//            if !serial_obj.isEmpty{
//                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj) as NSArray?
//                scanLotbasedArray = arr as? Array<Any>
//            }
//        }catch let error{
//            print(error.localizedDescription)
//        }
        if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
            
            if scanLotbasedArray != nil {
                let exProd = exProducts as NSArray?
                let arr = NSMutableArray(array: exProd!)
                
                for data in scanLotbasedArray! {
                    
                        let lot = (data as! ProductListModel).lotNumber
                        let productGtin14 = (data as! ProductListModel).productGtin14
                        let predicate = NSPredicate(format:"lot == '\(lot ?? "")' and gtin14 == '\(productGtin14 ?? "")'")
                            if let filterArray = exProd?.filtered(using: predicate){
                                if filterArray.count > 0 {
                                    let firstObj = filterArray.first as? NSDictionary ?? NSDictionary()
                                    let objectIdx = exProd?.index(of: firstObj)
                                    let modDict = NSMutableDictionary(dictionary: firstObj)
                                    let qty1 = (data as! ProductListModel).productCount!
                                   // let qty2 = modDict["quantity"] as! Int
                                    modDict["prev_quantity"] = firstObj["quantity"]
                                    modDict["quantity"] = qty1
                                    arr.replaceObject(at: objectIdx!, with: modDict)
                                    Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr)
                                }
                            }
                }
                if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
                    let arr1 = NSMutableArray()
                    for data in exProducts {
                        let dict  = data as? NSDictionary
                        if (dict!["prev_quantity"] != nil){
                            arr1.add(dict! as NSDictionary)
                        }
                    }
                    Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: arr1)

                }
                if let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any> {
                        for data in exProducts {
                              let dict  = data as? NSDictionary
                              if (dict!["prev_quantity"] != nil){
                                  let totalQuantity = dict!["quantity"] as! Int
                                    
                                    var isAdd = false
                                    var prvQuan = 0
                                    let curQuantity = totalQuantity
                                    if ((dict!["prev_quantity"] as! Int) >= 0 ){
                                         prvQuan = dict!["prev_quantity"] as! Int
                                    }
                                    var newQuantity = 0
                                    if curQuantity > prvQuan {
                                        isAdd = true
                                        newQuantity = Int(curQuantity - prvQuan)
                                    }else{
                                        isAdd = false
                                        newQuantity = Int(prvQuan - curQuantity)
                                    }
                                    self.addProduct(quantity: "\(newQuantity)", isAdd: isAdd, totalQuantity: "\(totalQuantity)",  product: dict!)
                                    }
                                }
                            }
                        }
                scanLotbasedArray = nil
        }else{
            if scanLotbasedArray != nil {
                Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: scanLotbasedArray!)
                scanLotbasedArray = nil
            }
        }
    }
    func addProduct(quantity:String, isAdd:Bool , totalQuantity:String, product:NSDictionary){
        
        var requestDict = [String:Any]()
        requestDict["type"] = "sales_order_by_picking"
        requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
        requestDict["product_uuid"] = product["product_uuid"] ?? ""
        requestDict["lot_number"] = product["lot"] ?? ""
        requestDict["quantity"] = quantity
        if isAdd{
            requestDict["action"] = "ADD"
        }else{
            requestDict["action"] = "REMOVE"
        }
        
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "AddPickingLotBasedProduct", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
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
    func salesOrderByPicking(serials : String){
        if !serials.isEmpty{
            var requestDict = [String:Any]()
            requestDict["type"] = "sales_order_by_picking"
            requestDict["serials_list"] = serials
            requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id")
            requestDict["action"] = "ADD"
            requestDict["is_search_on_lot_based_if_not_found"] = true
            
            Utility.POSTServiceCall(type: "SalesOrderByPickingMultipleGS1", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                
                DispatchQueue.main.async{
                    if isDone! {
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                var isLocationCalled = false
                                for serialDetails in serialDetailsArray {
                                    if let result = serialDetails["is_ok"] as? Bool{
                                        if result {
                                            
                                            if let isLotBased = serialDetails["type"] as? String,isLotBased == "LOT"{
                                                
                                                if !(self.lotBasedProducts as NSArray).contains(serialDetails){
                                                    self.lotBasedProducts.append(serialDetails)
                                                }
                                                
                                            }else{
                                                self.verifiedAlertSerials.append(serialDetails)
                                                if !(self.verifiedSerials as NSArray).contains(serialDetails){
                                                    self.verifiedSerials.append(serialDetails)
                                                    
                                                    
                                                    self.isVerified = true
                                                    if !isLocationCalled{
                                                        let serialArr = serials.components(separatedBy: "\\n")
                                                        self.getSerialLocation(serial: serialArr.first!)
                                                        isLocationCalled = true
                                                    }
                                                }
                                            }
                                        }else{
                                            if let isLotBased = serialDetails["type"] as? String,isLotBased == "LOT"{
                                                if let isok = serialDetails["is_ok"] as? Bool{
                                                    if !isok{
                                                        let errormsg = serialDetails["error"] as! String
                                                        if errormsg != "The quantity is not available."{
                                                            if !(self.failedAlertSerials as NSArray).contains(serialDetails){
                                                                 self.failedAlertSerials.append(serialDetails)
                                                            }
                                                            if !(self.failedSerials as NSArray).contains(serialDetails){
                                                                self.failedSerials.append(serialDetails)
                                                            }
                                                        }
                                                    }
                                                }
                                            }else{
                                                if !(self.failedAlertSerials as NSArray).contains(serialDetails){
                                                     self.failedAlertSerials.append(serialDetails)
                                                }
                                                if !(self.failedSerials as NSArray).contains(serialDetails){
                                                    self.failedSerials.append(serialDetails)
                                                }
                                            }
                                               
                                            
                                        }
                                    }
                                }
                                print(self.verifiedSerials as NSArray)
                                Utility.saveObjectTodefaults(key: "VerifiedSalesOrderByPickingArray", dataObject: self.verifiedSerials)
                                print(self.failedSerials as NSArray)
                                Utility.saveObjectTodefaults(key: "FailedSalesOrderByPickingArray", dataObject: self.failedSerials)
                                self.refreshProductView()
                                
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
                          //  Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    //        let arrayRemainingLetters = allSerials.filter {
                    //            !first3.contains($0)
                    //        }
                    if first.count > 0 {
                        self.salesOrderByPicking(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                        self.checkNewfailedItems()
                        
                        if self.lotBasedProducts.count>0 {
//                            if  self.triggerScanEnable {
//                                if !(self.failedAlertSerials.count > 0) {
//                                    Utility.saveObjectTodefaults(key: "picking_lot_products", dataObject: self.lotBasedProducts)
//                                    self.setuplotDetails()
//                                    self.nextButtonPressed(UIButton())
//                                }
//                            }else{
                                    self.moveToLotBasedView()
//                                }
                        }else{
                            if self.failedAlertSerials.count > 0 {
                                let arr1 = self.failedAlertSerials as NSArray
                                let predicate = NSPredicate(format: "error CONTAINS[c] '\("Item is already picked")'")
                                let arr = arr1.filtered(using: predicate)

                            if (arr.count == self.scannedCodeArr.count) {
                                Utility.showAlertDefault(Title: App_Title, Message: "Item is already picked".localized(), InViewC: self, action:{
//                                    self.failedAlertSerials = Array<Dictionary<String,Any>>()
                                    let controller = self.navigationController?.visibleViewController
                                    if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                                    self.navigationController?.popViewController(animated: false)
                                    }
                                })
                            }else{
                                var failedSavedItem = Array<Dictionary<String,Any>>()
                                if let scanFailedArr = Utility.getObjectFromDefauls(key: "ScanFailedItemsArray") as? [[String:Any]],!scanFailedArr.isEmpty{
                                    failedSavedItem = scanFailedArr
                                }
                                if (failedSavedItem as NSArray).isEqual(to: self.failedSerials) {
                                        Utility.showPopup(Title: App_Title, Message: "Serial(s) already scanned", InViewC: self)
                                    }else{
                                        Utility.showAlertDefault(Title: App_Title, Message: "\(self.failedAlertSerials.count) " + "Serial(s) Failed to Verify.".localized(), InViewC: self, action: {
                                          if self.failedAlertSerials.count > 0 {
                                              self.verifiedAlertSerials = Array<Dictionary<String,Any>>()
      //                                        self.failedAlertSerials = Array<Dictionary<String,Any>>()
                                              
                                              let controller = self.navigationController?.visibleViewController
                                              if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                                              self.navigationController?.popViewController(animated: false)
                                              }
                                            }
                                         })
                                        }
                                    }
                            }else{
                                if !self.triggerScanEnable {
                                    if self.verifiedAlertSerials.count > 0 {
                                        Utility.showAlertDefault(Title: Success_Title, Message: "\(self.verifiedAlertSerials.count) " + "Serial(s) Verified Successfully.".localized(), InViewC: self)
                                    }
                                }
                            }
                           }
                       }
                   }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    func getSerialLocation(serial:String){
        
        if let _ = defaults.object(forKey: "selectedLocation") as? String{
            if !(self.failedAlertSerials.count > 0) && self.triggerScanEnable {
                self.nextButtonPressed(UIButton())
            }
            return
        }
        let str = serial.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let appendStr = "serial_type=GS1_BARCODE&serial=\(str ?? "")"
        //self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetSerialDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                // self.removeSpinner()
                if isDone! {
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                        if let location_uuid = responseDict["location_uuid"] as? String{
                            
                            if let allLocations = UserInfosModel.getLocations(){
                                
                                if let _ = allLocations[location_uuid] as? NSDictionary{
                                    defaults.set(location_uuid, forKey: "selectedLocation")
                                    if !(self.failedAlertSerials.count > 0) && self.triggerScanEnable {
                                        self.nextButtonPressed(UIButton())
                                    }
                                }
                            }
                        }
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                      //  Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
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
        
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" Lot Products".localized() : " Lot Product".localized())", attributes: custTypeAttributes)
        //let itemStr = NSAttributedString(string: " Serials", attributes: custTypeAttributes)
        let itemStr = NSAttributedString(string: "\(Int(items!)!>1 ?" Serials".localized() : " Serial".localized())", attributes: custTypeAttributes)
        
        productString.append(productStr)
        itemsString.append(itemStr)
        
        productCountLabel.attributedText = productString
        itemsCountLabel.attributedText = itemsString
        //itemsCountLabel.textAlignment = .right
        //        productCountLabel.attributedText = itemsString
        //        itemsCountLabel.attributedText = NSAttributedString(string: "", attributes: custTypeAttributes)
    }
    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "pic_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "pic_2ndStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted {
            
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
        }
        if defaults.bool(forKey: "trigger_Scan"){
            let triggerValue = defaults.bool(forKey: "trigger_Scan")
            if triggerValue {
                triggerSwitch.isOn = true
            }else{
                triggerSwitch.isOn = false
            }
        }else{
            triggerSwitch.isOn = false
        }
        if !isTriggerEnableErrorpopupText.isEmpty && isTriggerEnableErrorpopupText != ""{
            DispatchQueue.main.async {
                let msg = self.isTriggerEnableErrorpopupText
                self.isTriggerEnableErrorpopupText = ""
                Utility.showPopup(Title: App_Title, Message: msg, InViewC: self)
            }
        }
        self.triggerScanEnableSwitch(triggerSwitch)
    }
    func moveToLotBasedView(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingLotBasedView") as! PickingLotBasedViewController
        controller.isFromScan = true
        controller.scanLotbasedArray = lotBasedProducts
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func checkNewfailedItems(){
        failedItemsDot.layer.cornerRadius = failedItemsDot.layer.frame.height/2
        failedItemsDot.layer.masksToBounds = true
        failedItemsDot.backgroundColor = Utility.hexStringToUIColor(hex: "ff7c7c")
        
        
        var failedSavedItem = Array<Dictionary<String,Any>>()
        if let scanFailedArr = Utility.getObjectFromDefauls(key: "ScanFailedItemsArray") as? [[String:Any]],!scanFailedArr.isEmpty{
            failedSavedItem = scanFailedArr
        }
            if (failedSavedItem as NSArray).isEqual(to: failedSerials) {
                failedItemsDot.isHidden = true
                failedItemsButton.isSelected = false
                failedItemsButton.setTitleColor(Utility.hexStringToUIColor(hex: "809c94"), for: .normal)
                failedItemsButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 13)

            }else{
                failedItemsDot.isHidden = false
                failedItemsButton.isSelected = true
                failedItemsButton.setTitleColor(Utility.hexStringToUIColor(hex: "08acf4"), for: .normal)
                failedItemsButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 13)

            }
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func toggleSingleMultiScan(_ sender: UIButton) {
        sender.isSelected.toggle()
        defaults.set(sender.isSelected, forKey: "IsMultiScan")
        multiButton.isSelected = sender.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        //00AFEF
    }
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            if(defaults.bool(forKey: "IsMultiScan")){
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                if self.triggerScanEnable {
                    controller.isForBottomSheetScan = true
                }else{
                    controller.isForReceivingSerialVerificationScan = true
                    controller.isForPickingScanOption = true
                }

                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                if self.triggerScanEnable {
                    controller.isForBottomSheetScan = true
                }else{
                    controller.isForReceivingSerialVerificationScan = true
                    controller.isForPickingScanOption = true

                }
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let exProducts = Utility.getObjectFromDefauls(key: "picking_lot_products") as? Array<Any>
        if(self.verifiedSerials.count > 0 || (exProducts != nil && exProducts?.count ?? 0 > 0)){
            defaults.set(true, forKey: "pic_2ndStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingConfirmationView") as! PickingConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please scan serials before proceeding.".localized(), InViewC: self)
        }
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: SelectCustomerViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectCustomerView") as! SelectCustomerViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3 {
            nextButtonPressed(UIButton())
        }
        
    }
    
    @IBAction func addLotBasedButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingLotBasedView") as! PickingLotBasedViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func viewScannedSerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingSerialListViewController") as! PickingSerialListViewController
        controller.serialList = verifiedSerials
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func triggerScanEnableSwitch(_ sender: UISwitch){
        if sender.isOn{
            triggerScanEnable = true
        }else{
            triggerScanEnable = false
        }
        defaults.set(sender.isOn, forKey: "trigger_Scan")
    }
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingItemsView") as! PickingItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func viewFailedItemsButtonPressed(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FailedItemsView") as! FailedItemsViewController
        controller.itemList = failedSerials
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: - End
}

extension PickingScanItemsViewController : ScanViewControllerDelegate{
    
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{ [self] in
            scannedCodeArr = Array<String>()
            self.failedAlertSerials = Array<Dictionary<String,Any>>()
            scannedCodeArr.append(contentsOf: scannedCode)
            self.callApiForSalesOrderByPicking(scannedCode: scannedCode)
        }
    }
     func didLotBasedTriggerScanDetailsForLotBased(arr : NSArray){
        scanLotbasedArray = arr.mutableCopy() as? Array<Any>
    }
    func didScanErrorMsgInTrigger(msg: String) {
        let controller = self.navigationController?.visibleViewController
        if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
            self.navigationController?.popViewController(animated: false)
            isTriggerEnableErrorpopupText = msg
        }
    }
    func triggerScanFailedArray(failedArr : [[String:Any]]){
      if failedArr.count > 0 {
          for faileditems in failedArr {
              if !(failedSerials as NSArray).contains(faileditems){
                  failedSerials.append(faileditems)
                  Utility.saveObjectTodefaults(key: "FailedSalesOrderByPickingArray", dataObject: self.failedSerials)
                  self.checkNewfailedItems()

              }
          }
         
      }
    }
}

extension PickingScanItemsViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{ [self] in
            scannedCodeArr = Array<String>()
            self.failedAlertSerials = Array<Dictionary<String,Any>>()
            scannedCodeArr.append(contentsOf: scannedCode)
            self.callApiForSalesOrderByPicking(scannedCode: scannedCode)
        }
    }
     func didLotBasedTriggerScanDetails(arr : NSArray){
         scanLotbasedArray = arr.mutableCopy() as? Array<Any>
     }
    func didScanErrorMsgInTrigger_singlescan(msg: String) {
        let controller = self.navigationController?.visibleViewController
        if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
            self.navigationController?.popViewController(animated: false)
            isTriggerEnableErrorpopupText = msg

        }
        
    }
    func triggerScanFailedForSingleScan(failedArr : [[String:Any]]){
      if failedArr.count > 0 {
          for faileditems in failedArr {
              if !(failedSerials as NSArray).contains(faileditems){
                  failedSerials.append(faileditems)
                  Utility.saveObjectTodefaults(key: "FailedSalesOrderByPickingArray", dataObject: self.failedSerials)
                  self.checkNewfailedItems()

              }
          }
      }
    }
}
   
extension PickingScanItemsViewController : PickingLotBasedViewDelegate {
    func didAddedLotBasedProduct() {
        isPickingLotAdded = true
    }
}
extension PickingScanItemsViewController : FailedItemsViewDelegate{
     func failedProductDetails(itemArr : Array<Any>){
        Utility.saveObjectTodefaults(key: "ScanFailedItemsArray", dataObject: itemArr)
        Utility.saveObjectTodefaults(key: "FailedSalesOrderByPickingArray", dataObject: itemArr)
    }
}
