//
//  MISAddAggregationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISAddAggregationViewController: BaseViewController, SingleSelectDropdownDelegate {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var containerScanButton: UIButton!
    @IBOutlet weak var productSubView: UIView!
    @IBOutlet weak var lotSubView: UIView!
    
    
    
    @IBOutlet weak var gs1SerialTextField: UITextField!
    @IBOutlet weak var simpleSerialTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    
    @IBOutlet weak var serialScanButton: UIButton!
    @IBOutlet weak var viewSerialButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    
    @IBOutlet var containerProductButton: [UIButton]!
    
    @IBOutlet weak var scanContainerView: UIView!
    @IBOutlet weak var gs1SerialView: UIView!
    @IBOutlet weak var simpleSerialView: UIView!
    
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var lotView: UIView!
    @IBOutlet weak var lotBasedView: UIView!
    @IBOutlet weak var serialBasedView: UIView!
    
    
    var parentId:Int = 0
    var productType = ""
    var productList:Array<Any>?
    var productLotList:Array<Any>?
    var selectedProductDict:NSDictionary?
    var selectedProductLotDict:NSDictionary?
    var scanDict:NSDictionary?
    var verifiedSerials = [String]()
    var oldSerials = [String]()
    var allScannedSerials = Array<String>()
    var duplicateSerials = Array<String>()
    var serialDetailsArray : Array<Any>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createInputAccessoryView()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        mainView.setRoundCorner(cornerRadious: 10)
        
        productSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        lotSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        gs1SerialTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        simpleSerialTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quantityTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        containerScanButton.setRoundCorner(cornerRadious: containerScanButton.frame.height / 2.0)
        serialScanButton.setRoundCorner(cornerRadious: serialScanButton.frame.height / 2.0)
        viewSerialButton.setRoundCorner(cornerRadious: viewSerialButton.frame.height / 2.0)
        okButton.setRoundCorner(cornerRadious: okButton.frame.height / 2.0)
        
        scanContainerView.isHidden = true
        gs1SerialView.isHidden = true
        simpleSerialView.isHidden = true
        productView.isHidden = true
        lotView.isHidden = true
        lotBasedView.isHidden = true
        serialBasedView.isHidden = true
        
        let btn = UIButton()
        btn.tag = 1
        containerProductButtonPressed(btn)
        
       
        getProductList()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - IBAction
    @IBAction func containerProductButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        for btn in containerProductButton {
            
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
            
            if btn.isSelected && btn.tag == 1{
                productType = "container"
                
                verifiedSerials = [String]()
                
                productLabel.text = "Choose"
                productLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                selectedProductDict = nil
                
                selectedProductLotDict = nil
                lotLabel.text = "Choose"
                lotLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                quantityTextField.text = ""
                
                productView.isHidden = true
                lotView.isHidden = true
                lotBasedView.isHidden = true
                serialBasedView.isHidden = true
                
                scanContainerView.isHidden = false
                gs1SerialView.isHidden = false
                simpleSerialView.isHidden = false
            }else if btn.isSelected && btn.tag == 2{
                productType = "product"
                
                gs1SerialTextField.text = ""
                simpleSerialTextField.text = ""
                
                scanContainerView.isHidden = true
                gs1SerialView.isHidden = true
                simpleSerialView.isHidden = true
                
                productView.isHidden = false
            }
        }
    }
    
    
    @IBAction func productButtonPressed(_ sender: UIButton) {
        if productList == nil || productType != "product" {
            Utility.showPopup(Title: "", Message: "Please add product on line items.", InViewC: self)
            return
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "product_name"
        controller.listItems = productList as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Product".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func lotButtonPressed(_ sender: UIButton) {
        if productLotList == nil  {
            Utility.showPopup(Title:Warning, Message: "Lot number not added in line items.", InViewC: self)
            return
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.subKeyNameArray = [["name" : "Lot Type","key" : "lot_type"], ["name" : "Lot Number","key" : "lot_number"], ["name" : "Quantity","key" : "quantity"], ["name" : "Reference","key" : "sdi"]]
        controller.subkeyNameAddStr = ","
        controller.listItems = productLotList as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Product".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func containerScanButtonPressed(_ sender: UIButton) {
        //simpleSerialTextField.text = "123456"
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.isForManualInbound = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func serialScanButtonPressed(_ sender: UIButton) {
        //        let tempArray = ["010083491310500821105406494129277\u{1d}17230224102FE91E4D", "010083491310500821105406486179353\u{1d}172302241013C36ADA"]
        //        getScanedValue(scannedCode: tempArray)
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        controller.isForManualInbound = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        if verifiedSerials.count == 0 {
            Utility.showPopup(Title: App_Title, Message: "No scan Product serial found".localized(), InViewC: self)
        }else {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISSerialsView") as! MISSerialsViewController
            controller.serialList = verifiedSerials
            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        addAggregation()
        //        getAllAggregation()
    }
    
    //MARK: - End
    
    
    //MARK: - Private Method
    
    
    func getaggregationCount(sdi: String) -> Int{
        var count = 0
        do{
            let predicate = NSPredicate(format:"sdi = '\(sdi)' ")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for aggregation in arr {
                    if let aggregationdict = aggregation as? NSDictionary {
                        
                        var lot_based_quantity = 0
                        if let txt = aggregationdict["lot_based_quantity"] as? Int{
                            lot_based_quantity = txt
                        }
                        
                        if lot_based_quantity > 0 {
                            count = count + lot_based_quantity
                        }else{
                            count = arr.count
                            break
                        }
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
            
        }
        return count
    }
    
    func containerSerialVerify(scannedCode: [String]){
        for data in scannedCode {                            
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
                if(details.keys.contains("00")){
                    if let serial = details["00"]?["value"] as? String{
                        simpleSerialTextField.text = serial
                    }
                }
            }
        }
    }
    
    func serialVerify(scannedCode:[String]){
        
        var tempGTIN = ""
        var tempLot = ""
        var tempProductName = ""
        
        if selectedProductDict != nil{
            if let uuid = selectedProductDict?["gtin14"] as? String,!uuid.isEmpty, let productName = selectedProductDict?["product_name"] as? String,!productName.isEmpty{
                
                tempGTIN = uuid
                tempProductName = productName
            }
        }
        
        if selectedProductLotDict != nil{
            if let lot_number = selectedProductLotDict?["lot_number"] as? String,!lot_number.isEmpty {
                
                tempLot = lot_number
            }
        }
//        var isverify : Bool = false
//        for data in serialDetailsArray{
//            let dict  = data as! NSDictionary
//            if dict["type"] as! String == "PRODUCT" {
//                if (dict["product_uuid"] as! String == tempid) && (dict["lot_number"] as! String == tempLot){
//                    isverify = true
//                    verifiedSerials.append(dict["serial"] as! String)
//                }
//            }else{
//            }
//        }
//        if !isverify {
//            Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self)
//        }
//
         
        for data in scannedCode {

            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
                if(details.keys.contains("01")) && (details.keys.contains("10")) && (details.keys.contains("21")){
                    if let gtin14 = details["01"]?["value"] as? String, let lot = details["10"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
                        if gtin14 != tempGTIN {
                            Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self) //GTIN Mismatch
                            break
                        }

                        if lot != tempLot {
                           Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self) //Lot Number Mismatch
                            break
                        }

                        verifiedSerials.append(serial)
                    }
                }else{
                    if(details.keys.contains("01")) && (details.keys.contains("21")){
                        if let gtin14 = details["01"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
                            if gtin14 != tempGTIN {
                            Utility.showPopup(Title: App_Title, Message: "Mismatch between the line items and data aggregation".localized(), InViewC: self)
                                break
                            }
                            verifiedSerials.append(serial)

                        }
                    }//sometime occur else part
                }
            }

        }
    }
    func getProductList() {
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                productList = arr
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func getLotList() {
        if let productId = selectedProductDict?["id"] as? Int {
            do{
                let predicate = NSPredicate(format:"misitem_id='\(productId)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                
                
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    productLotList = arr
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return autoId
    }
    
    func addAggregation (){
        
        var gs1Serial = ""
        if let txt = gs1SerialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            gs1Serial = txt
        }
        
        var simpleSerial = ""
        if let txt = simpleSerialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            simpleSerial = txt
        }
        
        var quantity = 0
        if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
            quantity = Int(txt) ?? 0
        }
        
        var isvalidate = true
        
        if productType == "container" {
        
            var tempserialkey = ""
            
            if (gs1Serial == "" && simpleSerial == "") || (gs1Serial != "" && simpleSerial != ""){
                Utility.showPopup(Title: App_Title, Message: "Please select either GS1 Serial or Simple Serial".localized(), InViewC: self)
                isvalidate = false
            }else if gs1Serial != "" {
                tempserialkey = "gs1Serial"
            }else if simpleSerial != "" {
                tempserialkey = "simpleSerial"
            }
            
            if isvalidate {
                
                let containerobj = MISAggregation(context: PersistenceService.context)
                
                if tempserialkey == "gs1Serial" {
                    containerobj.gs1_serial = gs1Serial
                }else if tempserialkey == "simpleSerial"{
                    containerobj.serial = simpleSerial
                }
                            
                containerobj.parent_id = Int16(parentId)
                containerobj.id = getAutoIncrementId()
                containerobj.type = productType
                
                PersistenceService.saveContext()
                Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
            }
        }else if productType == "product" {
            if selectedProductDict == nil {
                Utility.showPopup(Title: App_Title, Message: "Please select Product".localized(), InViewC: self)
                isvalidate = false
            }
            
            if selectedProductLotDict == nil {
                Utility.showPopup(Title: App_Title, Message: "Please select Product Lot".localized(), InViewC: self)
                isvalidate = false
            }
            
            if let lot_type = selectedProductLotDict?["lot_type"] as? String,!lot_type.isEmpty, let sdi = selectedProductLotDict?["sdi"] as? String,!lot_type.isEmpty, let tmp_quantity = selectedProductLotDict?["quantity"] as? Int{
                
                let oldCount = getaggregationCount(sdi: sdi)
                
                //,,,sb12
                /*
                if oldCount == tmp_quantity {
                    Utility.showPopup(Title: App_Title, Message: "This Product Lot already in Aggregation".localized(), InViewC: self)
                    isvalidate = false
                }
                */
                
                let createNew = defaults.bool(forKey: "MIS_create_new")
                if createNew {
                    //Create a Purchase Order based from the Shipment
                    if oldCount == tmp_quantity {
                        Utility.showPopup(Title: App_Title, Message: "This Product Lot already in Aggregation".localized(), InViewC: self)
                        isvalidate = false
                    }
                }
                //,,,sb12
                
                if lot_type == "SERIAL_BASED" || lot_type == "FOUND" {
                    
                    if verifiedSerials.count == 0 {
                        Utility.showPopup(Title: App_Title, Message: "Please scan Product serial".localized(), InViewC: self)
                        isvalidate = false
                    }
                    
                    
                    //,,,sb12
                    /*
                    if verifiedSerials.count > (tmp_quantity - oldCount) {
                        Utility.showPopup(Title: App_Title, Message: "Serial count must not be greater than bought quantity".localized(), InViewC: self)
                        isvalidate = false
                    }
                    */
                    
                    let createNew = defaults.bool(forKey: "MIS_create_new")
                    if createNew {
                        //Create a Purchase Order based from the Shipment
                        if verifiedSerials.count > (tmp_quantity - oldCount) {
                            Utility.showPopup(Title: App_Title, Message: "Serial count must not be greater than bought quantity".localized(), InViewC: self)
                            isvalidate = false
                        }
                    }
                    //,,,sb12
                    
                    if isvalidate {
                        for serial in verifiedSerials {
                            
                            let serialProductobj = MISAggregation(context: PersistenceService.context)
                            
                            serialProductobj.parent_id = Int16(parentId)
                            serialProductobj.id = getAutoIncrementId()
                            serialProductobj.type = productType
                            serialProductobj.sdi = sdi
                            serialProductobj.serial = serial
                            
                            
                            PersistenceService.saveContext()
                            
                        }
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }else if lot_type == "LOT_BASED" || lot_type == "LOT_FOUND" {
                    
                    //,,,sb12
            //        if quantity == 0 {
                    if quantity <= 0 {
                    //,,,sb12
                            
                        Utility.showPopup(Title: App_Title, Message: "Please enter quantity.".localized(), InViewC: self)
                        isvalidate = false
                    }
                    
                    //,,,sb12
                    /*
                    if quantity > (tmp_quantity - oldCount){
                        Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
                        isvalidate = false
                    }
                    */
                    let createNew = defaults.bool(forKey: "MIS_create_new")
                    if createNew {
                        //Create a Purchase Order based from the Shipment
                        if quantity > (tmp_quantity - oldCount){
                            Utility.showPopup(Title: App_Title, Message: "Required quantity must not be greater than bought quantity.".localized(), InViewC: self)
                            isvalidate = false
                        }
                    }
                    //,,,sb12
                    
                    if isvalidate {
                        let lotProductobj = MISAggregation(context: PersistenceService.context)
                        
                        lotProductobj.parent_id = Int16(parentId)
                        lotProductobj.id = getAutoIncrementId()
                        lotProductobj.type = productType
                        lotProductobj.sdi = sdi
                        lotProductobj.lot_based_quantity = Int16(quantity)
                        
                        PersistenceService.saveContext()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
            }
        }
    }
    
    func callApiForGS1BarcodeLookupDetails(scannedCode: [String]){

        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"))
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
    func addUpdateSerialsToDB(scannedCode: [String]){
        for data in scannedCode {
            do{
                let predicate = NSPredicate(format:"gs1_barcode='\(data)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if serial_obj.isEmpty{
                    self.allScannedSerials.append(data)
                    
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
    func getGS1BarcodeLookupDetails(serials : String){
        
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?barcode=\(str ?? "")&check_inventory=true"

            Utility.GETServiceCall(type: "barcodedecoder", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{ [self] in
                    if isDone! {
                        let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                        print(responseArray as NSArray)
                        if responseArray.count > 0{
                            if let arr = responseArray as? [[String : Any]]{
                                  serialDetailsArray = arr
//                                  self.serialVerify()
                                    
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
                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"))
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
    //MARK: - End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    
    
    //MARK: - SingleSelectDropdownDelegate
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        if sender != nil && sender?.tag ?? 0 == 1 && selectedProductDict != data{
            if let name = data["product_name"] as? String{
                productLabel.text = name
                productLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                selectedProductDict = data
                getLotList()
                
                selectedProductLotDict = nil
                lotLabel.text = "Choose"
                lotLabel.textColor = Utility.hexStringToUIColor(hex: "719898")
                
                lotView.isHidden = false
                
                verifiedSerials = [String]()
                
                quantityTextField.text = ""
                serialBasedView.isHidden = true
                lotBasedView.isHidden = true
            }
        }else if sender != nil && sender?.tag ?? 0 == 2 && selectedProductLotDict != data{
            var str = ""
            if let txt = data["lot_type"] as? String{
                
                verifiedSerials = [String]()
                quantityTextField.text = ""
                lotBasedView.isHidden = true
                serialBasedView.isHidden = true
                
                if txt == "SERIAL_BASED" || txt == "FOUND" {
                    str += "Lot Type : Serial Based, "
                    serialBasedView.isHidden = false
                }else if txt == "LOT_BASED" || txt == "LOT_FOUND"{
                    str += "Lot Type : Lot Based, "
                    lotBasedView.isHidden = false
                }
            }
            if let txt = data["lot_number"] as? String{
                str += "Lot Number : " + txt + ", "
            }
            if let txt = data["quantity"] as? Int{
                str += "Quantity : \(txt), "
            }
            if let txt = data["sdi"] as? String{
                str += "Reference : " + txt
            }
            selectedProductLotDict = data
            lotLabel.text = str
            lotLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        }
    }
    
}
extension MISAddAggregationViewController : ScanViewControllerDelegate{
    
    func didScanCodeForManualInboundShipment(scannedCode: [String]) {
        //self.addUpdateSerialsToDB(scannedCode: scannedCode)
        //self.callApiForGS1BarcodeLookupDetails(scannedCode: scannedCode)
        self.serialVerify(scannedCode: scannedCode)
    }
}

extension MISAddAggregationViewController : SingleScanViewControllerDelegate{
    
    func didSingleScanCodeForManualInboundShipment(scannedCode: [String]) {
        self.containerSerialVerify(scannedCode: scannedCode)
    }
}
