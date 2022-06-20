//
//  DirectPickingScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 27/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class DirectPickingScanViewController: BaseViewController {
    
    var allScannedSerials = Array<String>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    var failedSerials = Array<Dictionary<String,Any>>()
    var duplicateSerials = Array<String>()
    var tempSerials = Array<Dictionary<String,Any>>()

    @IBOutlet weak var viewPickedItemsButton: UIButton!
    
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
    @IBOutlet weak var pickedItemsCount:UIButton!

    //MARK: - End
    
    var isVerified = false
    var isLotProductScanned = false
    var productCount = 0
    var serialCount = 0
    var isDirectPickingLotAdded : Bool = false
    var triggerScanEnable: Bool = false
    var scanLotbasedArray:Array<Any>?
    var isTriggerEnableErrorpopupText : String = ""
    var pickedArr = NSArray()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        itemsVerificationView.setRoundCorner(cornerRadious: 10)
        cameraView.setRoundCorner(cornerRadious: 10)
        viewPickedItemsButton.setRoundCorner(cornerRadious: viewPickedItemsButton.frame.size.height/2.0)
        addLotbaseButton.setBorder(width: 1.0, borderColor: Utility.hexStringToUIColor(hex: "719898"), cornerRadious: addLotbaseButton.frame.size.height/2.0)
        self.pickedItemsCount.isHidden = true
        self.checkItemsPicked()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        pickedItemsCount.isHidden = true
        pickedItemsCount.setRoundCorner(cornerRadious: pickedItemsCount.frame.size.height/2)
        
        
        if isDirectPickingLotAdded && triggerScanEnable {
            isDirectPickingLotAdded = false
            self.nextButtonPressed(UIButton())
        }
        failedItemsDot.isHidden = true
        failedItemsButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 13)
        
        if let arr = Utility.getObjectFromDefauls(key: "PickedItemCount"){
            pickedArr = arr as! NSArray
            if pickedArr.count > 0 {
                self.pickedItemsCount.isHidden = false
                self.pickedItemsCount.setTitle("\(self.pickedArr.count)", for: .normal)
            }else{
                self.pickedItemsCount.isHidden = true
            }
        }else{
            self.pickedItemsCount.isHidden = true
        }
        self.checkNewfailedItems()
        self.refreshProductView()
        self.getShipmentItemDetails()
        setup_stepview()
    }
    //MARK: - End
    //MARK: - Private Method
    func updateVerifiedSerialsToDB(){
        
        for data in verifiedSerials {
            
            do{
                let barcode = data["gs1_barcode"] ?? ""
                let predicate = NSPredicate(format:"barcode='\(barcode)'")
                let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                
                
                if !serial_obj.isEmpty{
                    
                    let obj = serial_obj.first!
                    obj.is_send_for_verification = true
                    
                    if let status = data["status"] as? String{
                        
                        let is_available_for_sale = (data["is_available_for_sale"] as? Bool) ?? false
                        
                        if status == "FOUND" && is_available_for_sale{
                            self.isVerified = true
                            obj.is_lot_based = false
                            obj.is_valid = true
                            
                        }else if status == "LOT_FOUND" && is_available_for_sale{
                            self.isVerified = true
                            self.isLotProductScanned = true
                            obj.is_lot_based = true
                            obj.is_valid = true
                        }else{
                            obj.is_lot_based = false
                            obj.is_valid = false
                            
                        }
                        
                    }
                    
                    if let txt = data["serial"] as? String{
                        obj.serial = txt
                    }
                    
                    if let txt = data["gs1_serial"] as? String{
                        obj.gs1_serial = txt
                    }
                    
                    if let txt = data["product_uuid"] as? String{
                        obj.product_uuid = txt
                    }
                    
                    if let txt = data["lot_number"] as? String{
                        obj.lot_no = txt
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
        
        refreshProductView()
        if self.isLotProductScanned{
            self.isLotProductScanned = false
         if triggerScanEnable{
            let controller = self.navigationController?.visibleViewController
            if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                self.navigationController?.popViewController(animated: false)
              }
            }
            if triggerScanEnable {
                for product in scanLotbasedArray!{
                    let quantity = (product as! ProductListModel).productCount
                    let uuid:String = (product as! ProductListModel).uuid!
                    let lotNumber:String = (product as! ProductListModel).lotNumber!
                    self.addProduct(quantity:"\(quantity ?? 0)", product_uuid: uuid, lot_no: lotNumber)
                }
            }
            self.moveToLotBasedView()
        }else{
           // let uniqueArr = (verifiedSerials as NSArray).value(forKeyPath: "@distinctUnionOfObjects.serial")
            let gs1SerialArr = (verifiedSerials as NSArray).value(forKeyPath: "@distinctUnionOfObjects.gs1_serial")
            if (gs1SerialArr as! NSArray).count > 0 {
                self.serialBasedOrLotBasedItemsAdd(gs1Serial: gs1SerialArr as! NSArray)
            }
            
            /*
            //            if self.isVerified{
            //                self.isVerified = false
            //                Utility.showPopup(Title: Success_Title, Message: "Serial(s) Verified Successfully.".localized() , InViewC: self)
            //            }
            /////////////////////////////////////////// ALERT FOR VERIFED AND UNVERIFIED SERIALS ///////////////////////////////////
            
            let verified = self.verifiedSerials.filter({$0["status"] as? String  == "FOUND" && $0["is_available_for_sale"] as? Bool == true })
            
            var failed = 0
            if self.verifiedSerials.count>0{
                failed = self.verifiedSerials.count-verified.count
            }else{
                failed = self.verifiedSerials.count
            }
            if failed > 0 {
            print("Verifed Serials::",verified.count)
            print("Unverifed Serials::",failed)
                Utility.showAlertDefault(Title: App_Title, Message: "\(failed) " + "Serial(s) Failed to Verify.".localized() , InViewC: self, action: {
                    if self.triggerScanEnable{
                      self.dismiss(animated: false){
                        let controller = self.navigationController?.visibleViewController
                        if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                        self.navigationController?.popViewController(animated: false)
                      }
                     }
                    }
                })//\(verified.count) " + "Serial(s) Verified Successfully.".localized() + "\n" +
            }else{
                if triggerScanEnable{
                    self.nextButtonPressed(UIButton())
                }else{
                    if self.isVerified {
                        if verified.count > 0 {
                            Utility.showPopup(Title: Success_Title, Message: "Serial(s) Verified Successfully.".localized(), InViewC: self)
                        }
                    }
                }
            }
             */
        }
        self.checkNewfailedItems()
    }
    func addProduct(quantity:String, product_uuid:String , lot_no : String){
        do{
            let predicate = NSPredicate(format:"product_uuid='\(product_uuid)' and lot_no = '\(lot_no)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                for obj in serial_obj {
                    obj.quantity = 0
                    PersistenceService.saveContext()
                }
                
                serial_obj.first?.quantity = Int16(quantity)!
                PersistenceService.saveContext()
                
            }
            
        }catch let error{
            print(error.localizedDescription)
        }
    }
    func addUpdateSerialsToDB(scannedCode: [String]){
        
        for data in scannedCode {
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
            do{
                let predicate = NSPredicate(format:"barcode='\(data)'")
                let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                
                
                if serial_obj.isEmpty{
                    self.allScannedSerials.append(data)
                    let obj = DirectPicking(context: PersistenceService.context)
                    obj.barcode = data
                    obj.is_send_for_verification = false
                    obj.is_lot_based = false
                    obj.is_valid = false
                    obj.quantity = 1
                    obj.lot_max_quantity = 1
                    obj.gs1_serial = ""
                    obj.is_container = false
                    obj.identifier_type = "NDC"
                    
                    var product_name = ""
                    var lotNumber = ""
                    var product_uuid = ""
                    var gtin = ""
                    var serialNumber = ""
                    
                    var idValue = ""
                    
                    let details = UtilityScanning(with:data).decoded_info
                    if details.count > 0 {
                        
                        if(details.keys.contains("00")){
                            obj.is_container = true
                            
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
                            if(details.keys.contains("21")){
                                if let serial = details["21"]?["value"] as? String{
                                    serialNumber = serial
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                    obj.identifier_value = idValue
                    obj.product_name = product_name
                    obj.product_uuid = product_uuid
                    obj.lot_no = lotNumber
                    obj.gtin = gtin
                    obj.serial = serialNumber
                    obj.location_uuid = ""
                    obj.storage_uuid = ""
                    obj.shelf_uuid = ""
                    
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
        }
        
    }
    func callApiForGS1BarcodeLookupDetails(scannedCode: [String]){
        self.isVerified = false
        self.isLotProductScanned = false
        verifiedSerials = []
        //self.allScannedSerials.append(contentsOf: scannedCode)
        //self.allScannedSerials = Array(Set(self.allScannedSerials))
        
        allScannedSerials = Array<String>()
        self.allScannedSerials.append(contentsOf: scannedCode)
        self.allScannedSerials = Array(Set(self.allScannedSerials))
        
        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"))
            self.showSpinner(onView: self.view)
        }else if duplicateSerials.count>0{
            duplicateSerials = []
            if triggerScanEnable{
                self.dismiss(animated: false) {
                let controller = self.navigationController?.visibleViewController
                    if controller!.isKind(of: ScanViewController.self) || controller!.isKind(of: SingleScanViewController.self){
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            }
            Utility.showPopup(Title: App_Title, Message: "Serial(s) already scanned.".localized(), InViewC: self)
            return
        }
        else{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
    }
    func refreshProductView(){
        
        if let data = Utility.getObjectFromDefauls(key: "DirectPickingData") as? NSDictionary{
        let itemsArr = data["items"] as! NSArray
        
        var totalQuantity = 0
        var product = "0"
        var serial = "0"
        var newArr = NSMutableArray()
        newArr = itemsArr.mutableCopy() as! NSMutableArray

        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arrDetails = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj) as NSArray
                let uniqueArr = (arrDetails as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid")as! NSArray
                product = "\((uniqueArr as? Array<Any>)?.count ?? 0)"
                productCount = (uniqueArr as? Array<Any>)?.count ?? 0
                    
                    if let uniqueProductArr = (arrDetails as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                        
                        for product_uuid in uniqueProductArr {
                            
                            do{
                                let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and is_container = false")
                                let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                                if !serial_obj.isEmpty{
                                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                    if let uniqueLotArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>{
                                        totalQuantity = 0
                                        for lot_no in uniqueLotArr {
                                            
                                            do{
                                                let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and lot_no='\(lot_no)' and is_container = false")
                                                let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                                                
                                                if !serial_obj.isEmpty{
                                                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)as NSArray
                                                    for dict in arr {
                                                        let qtyDict = dict as! NSDictionary
                                                        totalQuantity = totalQuantity + (qtyDict["quantity"] as! Int)

                                                    }
                                                }
                                            }catch let error{
                                                productCount = 0
                                                print(error.localizedDescription)
                                            }
                                        }
                                        var newdict = NSMutableDictionary()
                                            if totalQuantity>0 {
                                                let predicate = NSPredicate(format:"product_uuid == '\(product_uuid)'")
                                                let arr = itemsArr.filtered(using: predicate) as NSArray
                                                if arr.count>0 {
                                                    let dict = arr[0] as! NSDictionary
                                                       let index = itemsArr.index(of: dict)
                                                       newdict = dict.mutableCopy() as! NSMutableDictionary
                                                       newdict.setValue(totalQuantity, forKey: "qty_picked")
                                                       newArr.replaceObject(at: index, with: newdict)
                                                        
                                                }
                                            }
                                        }
                                }else{
                                    productCount = 0
                                }
                            }catch let error{
                                productCount = 0
                                print(error.localizedDescription)
                                }
                        }
                        
                        let dictmut : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
                        dictmut.removeObject(forKey: "items")
                        dictmut.setValue(newArr, forKey: "items")
                        Utility.saveObjectTodefaults(key: "DirectPickingData", dataObject: dictmut)
                    }
                }
            }catch let error{
                productCount = 0
                print(error.localizedDescription)
            }
            
        var newSerialArr = NSMutableArray()
        newSerialArr = itemsArr.mutableCopy() as! NSMutableArray

        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj) as NSArray
                
                serial = "\(arr.count)"
                serialCount = arr.count
                
                for dict in arr {
                    let dic = dict as! NSDictionary
                    let udid = dic["product_uuid"] as! String
                    let product_Name = dic["product_name"] as! String
                    let predicate = NSPredicate(format:"product_uuid == '\(udid)'")
                    let filterarr = itemsArr.filtered(using: predicate) as NSArray
                    let predicateByname = NSPredicate(format:"product_name == '\(product_Name)'")
                    let filterarrByName = arr.filtered(using: predicateByname) as NSArray
                    var newdict = NSMutableDictionary()
                    if filterarr.count>0 {
                        let dict = filterarr[0] as! NSDictionary
                        let index = itemsArr.index(of: dict)
                        newdict = dict.mutableCopy() as! NSMutableDictionary
                        newdict.setValue(filterarrByName.count, forKey: "qty_picked")
                        newSerialArr.replaceObject(at: index, with: newdict)
                    }
                }
                let dictmutSerial : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
                dictmutSerial.removeObject(forKey: "items")
                dictmutSerial.setValue(newSerialArr, forKey: "items")
                Utility.saveObjectTodefaults(key: "DirectPickingData", dataObject: dictmutSerial)

            }else{
                serialCount = 0
            }
        }catch let error{
            serialCount = 0
            print(error.localizedDescription)
        }
        
        populateProductandItemsCount(product: product, items: serial)
    }
}

    func serialBasedOrLotBasedItemsAdd(gs1Serial:NSArray){
        
        let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items"
        var requestDict = [String:Any]()
            requestDict["picking_type"] = "GS1_SERIAL_BASED"
            requestDict["quantity"] = 0
            let str = gs1Serial.componentsJoined(by: "\n")
            requestDict["serials"] = str
       
        //requestDict["product_shipment_line_item_uuid"] = "44983987-b838-4ba9-a9c0-3ca2c2c0434e"
        requestDict["product_sku"] = ""
        requestDict["product_upc"] = ""
        requestDict["product_identfier_code"] = ""
        requestDict["product_identfier_value"] = ""
       // requestDict["lot_number"] = "5FF56144"
//        requestDict["storage_area_uuid"] = storageAreaButton.accessibilityHint
//        requestDict["storage_area_shelf_uuid"] = storageshelfButton.accessibilityHint
        requestDict["is_remove_item_if_already_found"] = false
        requestDict["is_remove_from_parent_container"] = true
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "PickNewItem", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseArray: NSArray = responseData as? NSArray{
                        if responseArray.count > 0 {
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Product Added".localized(), InViewC: self, isPop: false, isPopToRoot: false)
                            self.getShipmentItemDetails()
                            self.checkItemsPicked()
                        }
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
    
    func getGS1BarcodeLookupDetails(serials : String){
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?gs1_barcode=\(str ?? "")"
            
            Utility.GETServiceCall(type: "GS1BarcodeLookup", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    if isDone! {
                        let responseArray: NSArray = responseData as! NSArray
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let serialDetailsArray = responseArray as? [[String : Any]]{
                                self.verifiedSerials.append(contentsOf: serialDetailsArray)
                                //self.refreshProductView()
                                if !self.verifiedSerials.isEmpty{
                                        var defaultData = Array<Dictionary<String,Any>>()
                                        if let arr = Utility.getObjectFromDefauls(key: "SalesByPickingVerifiedArray"){
                                            defaultData = arr as! [[String : Any]]
                                        }
                                        for verifieditems in self.verifiedSerials {
                                            if !(defaultData as NSArray).contains(verifieditems){
                                                defaultData.append(verifieditems)
                                            }
                                        }

                                        Utility.saveObjectTodefaults(key: "SalesByPickingVerifiedArray", dataObject: defaultData)
                                }
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
                           // Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                    }
                    
                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                    
                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
                    
                    if first.count > 0 {
                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"))
                    }else{
                        self.removeSpinner()
                        self.updateVerifiedSerialsToDB()
                    }
                }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
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
        
        let productStr = NSAttributedString(string: "\(Int(product!)!>1 ?" Lot Products" : " Lot Product")", attributes: custTypeAttributes)
        //let itemStr = NSAttributedString(string: " Serials", attributes: custTypeAttributes)
        let itemStr = NSAttributedString(string: "\(Int(items!)!>1 ?" Serials" : " Serial")", attributes: custTypeAttributes)
        
        productString.append(productStr)
        itemsString.append(itemStr)
        
        productCountLabel.attributedText = productString
        itemsCountLabel.attributedText = itemsString
        //itemsCountLabel.textAlignment = .right
        //        productCountLabel.attributedText = itemsString
        //        itemsCountLabel.attributedText = NSAttributedString(string: "", attributes: custTypeAttributes)
        
    
    }
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "picSO_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "picSO_2ndStep")
        
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
        triggerSwitch.isOn = false
        self.triggerScanEnableSwitch(triggerSwitch)

    }
    func failedItemsDetails(){
        failedSerials = Array<Dictionary<String,Any>>()
        var defaultData = Array<Dictionary<String,Any>>()
        
        if let arr = Utility.getObjectFromDefauls(key: "SalesByPickingVerifiedArray"){
            defaultData = arr as! [[String : Any]]
        }
        
        let failed1Default = defaultData.filter({$0["status"] as? String == "FOUND" && $0["is_available_for_sale"] as? Bool == false})
        let failed2Default = defaultData.filter({$0["status"] as? String == "LOT_FOUND" && $0["is_available_for_sale"] as? Bool == false})

        let failed3Default = defaultData.filter({$0["status"] as? String == "NOT_FOUND"})

        if failed1Default.count>0 {
            failedSerials.append(contentsOf: failed1Default)
        }
        if failed2Default.count>0 {
            failedSerials.append(contentsOf: failed2Default)
        }
        if failed3Default.count>0 {
            failedSerials.append(contentsOf: failed3Default)
        }
     
    }
    func moveToLotBasedView(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPLotBasedView") as! DPLotBasedViewController
        controller.isFromScan = true
        controller.delegate = self
        controller.dpProductList = Utility.getObjectFromDefauls(key: "items_to_pick") as? Array<Any>
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func checkNewfailedItems(){
        self.failedItemsDetails()
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
    func checkItemsPicked(){
        pickedArr = []
        self.showSpinner(onView: self.view)
        UserInfosModel.UserInfoShared.serialBasedOrLotBasedItemsGetApiCall(ServiceCompletion:{ isDone, itemArr in
            self.removeSpinner()
            if itemArr != nil && !(itemArr?.isEmpty ?? false) {
                self.pickedArr = itemArr! as NSArray
               
            }else{
                self.pickedArr = []
            }
            Utility.saveObjectTodefaults(key: "PickedItemCount", dataObject: self.pickedArr)
            if self.pickedArr.count>0 {
                self.pickedItemsCount.isHidden = false
                self.pickedItemsCount.setTitle("\(self.pickedArr.count)", for: .normal)
            }else{
                self.pickedItemsCount.isHidden = true
            }
        })
    }
    func getShipmentItemDetails(){
        let shipmentId = defaults.object(forKey: "outboundShipemntuuid")
        let appendStr = "to_pick/\(shipmentId ?? "")?is_open_picking_session=false"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                  
                        if let items = responseDict["items_to_pick"] as? Array<Any> {
                            Utility.saveObjectTodefaults(key: "items_to_pick", dataObject: items)
                        }
                    }
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                       Utility.showAlertWithPopAction(Title: App_Title, Message: message, InViewC: self, isPop: true, isPopToRoot: false)
                   }
                       
                       
                }
                  
            }
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
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPMultipleScanViewController") as! DPMultipleScanViewController
            controller.isForReceivingSerialVerificationScan = true
            controller.dpProductList = Utility.getObjectFromDefauls(key: "items_to_pick") as? Array<Any>
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            
//            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
////            if self.triggerScanEnable {
////                controller.isForBottomSheetScan = true
////            }else{
////                controller.isForReceivingSerialVerificationScan = true
////            }
//            controller.dpProductList = Utility.getObjectFromDefauls(key: "items_to_pick") as? Array<Any>
//            controller.isproductMatchInDpItems = true
//            controller.delegate = self
//            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            self.pickUsingListscan(UIButton())
//            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
////            if self.triggerScanEnable {
////                controller.isForBottomSheetScan = true
////            }else{
////                controller.isForReceivingSerialVerificationScan = true
////            }
//            controller.dpProductList = Utility.getObjectFromDefauls(key: "items_to_pick") as? Array<Any>
//            controller.isproductMatchInDpItems = true
//            controller.delegate = self
//            self.navigationController?.pushViewController(controller, animated: true)
          }
        }
    }
    @IBAction func pickUsingListscan(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPSingleScanViewController") as! DPSingleScanViewController
        controller.isForReceivingSerialVerificationScan = true
        controller.dpProductList = Utility.getObjectFromDefauls(key: "items_to_pick") as? Array<Any>
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
      DispatchQueue.main.async {
          if !(self.pickedArr.count>0){//if(productCount == 0 && serialCount == 0){
              Utility.showPopup(Title: App_Title, Message: "Please scan serials or pick items manually before proceed.".localized(), InViewC: self)
              return
          }
        
          defaults.set(true, forKey: "picSO_2ndStep")
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPConfirmationView") as! DPConfirmationViewController
          self.navigationController?.pushViewController(controller, animated: false)
        }
        
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: PickingDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingDetailsView") as! PickingDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 3 {
            nextButtonPressed(UIButton())
        }
    }
    
    @IBAction func addLotBasedButtonPressed(_ sender: UIButton) {
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPLotBasedView") as! DPLotBasedViewController
//        self.navigationController?.pushViewController(controller, animated: true)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingManuallySOItemsView") as! PickingManuallySOItemsViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewScannedSerialsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPViewPickedItems") as! DPViewPickedItemsViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
        
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DirectPickingScannedSerialsView") as! DirectPickingScannedSerialsViewController
//        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPViewItemsView") as! DPViewItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func viewPickedItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingSOItemsView") as! PickingSOItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func triggerScanEnableSwitch(_ sender: UISwitch){
        if sender.isOn{
            triggerScanEnable = true
        }else{
            triggerScanEnable = false
        }
        defaults.set(triggerScanEnable, forKey: "trigger_Scan")
    }
    @IBAction func viewFailedItemsButtonPressed(_ sender:UIButton){
        self.failedItemsDetails()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FailedItemsView") as! FailedItemsViewController
        controller.itemList = failedSerials
        controller.isFromGs1BacodeApi = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: - End
}

extension DirectPickingScanViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        self.addUpdateSerialsToDB(scannedCode: scannedCode)
        DispatchQueue.main.async{
            self.callApiForGS1BarcodeLookupDetails(scannedCode: scannedCode)
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
            self.failedItemsDetails()
            for faileditems in failedArr {
                if !(failedSerials as NSArray).contains(faileditems){
                    failedSerials.append(faileditems)
                    Utility.saveObjectTodefaults(key: "SalesByPickingVerifiedArray", dataObject: self.failedSerials)
                    self.checkNewfailedItems()
                }
            }
        }
    }
}

extension DirectPickingScanViewController : SingleScanViewControllerDelegate{
    
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        self.addUpdateSerialsToDB(scannedCode: scannedCode)
        DispatchQueue.main.async{
            self.callApiForGS1BarcodeLookupDetails(scannedCode: scannedCode)
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
            self.failedItemsDetails()
            for faileditems in failedArr {
                if !(failedSerials as NSArray).contains(faileditems){
                    failedSerials.append(faileditems)
                    Utility.saveObjectTodefaults(key: "SalesByPickingVerifiedArray", dataObject: self.failedSerials)
                    self.checkNewfailedItems()
                }
            }
        }
    }
    
}
extension DirectPickingScanViewController : DPLotBasedViewControllerDelegate {
    func didAddedLotBasedProduct() {
        self.checkItemsPicked()
    }
}
extension DirectPickingScanViewController : FailedItemsViewDelegate{
     func failedProductDetails(itemArr : Array<Any>){
        Utility.saveObjectTodefaults(key: "ScanFailedItemsArray", dataObject: itemArr)
        Utility.saveObjectTodefaults(key: "SalesByPickingVerifiedArray", dataObject: itemArr)
    }
}
extension DirectPickingScanViewController : PickingManuallySOItemsViewDelegate{
    func reloadItems() {
        self.checkItemsPicked()
    }
}
extension DirectPickingScanViewController : DPViewPickedItemsViewDelegate{
    func reloadPickedItemsApi(){
        self.checkItemsPicked()
    }
}
extension DirectPickingScanViewController : DPSingleScanViewControllerDelegate{
    func dpSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        self.addUpdateSerialsToDB(scannedCode: scannedCode)
        DispatchQueue.main.async {
            self.callApiForGS1BarcodeLookupDetails(scannedCode : scannedCode)
        }
    }
}
extension DirectPickingScanViewController : DPMultipleScanViewControllerDelegate{
    func dpMultipleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        self.addUpdateSerialsToDB(scannedCode: scannedCode)
        DispatchQueue.main.async {
            self.callApiForGS1BarcodeLookupDetails(scannedCode : scannedCode)
        }
    }
}
