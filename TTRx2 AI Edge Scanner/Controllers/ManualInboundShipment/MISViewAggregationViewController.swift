//
//  MISContainerViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 02/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISViewAggregationViewController: BaseViewController,MISAddAggregationScanViewControllerDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var addAggregationButton: UIButton!
    
    @IBOutlet weak var productAddedView : UIView!
    @IBOutlet weak var productAddedSubView : UIView!
    @IBOutlet weak var gtin14Label : UILabel!
    @IBOutlet weak var lotLabel : UILabel!
    @IBOutlet weak var serialproductaddviewLabel : UILabel!
    @IBOutlet weak var expirationDateLabel : UILabel!
    @IBOutlet weak var productNameTextFiled : UITextField!
    @IBOutlet weak var updateButton : UIButton!
    var scannedCodeDetails = [String:Any]()

    var itemsList:Array<Any>?
    var selectDict:NSDictionary?
      
    var allScannedSerials = Array<String>()
    var verifiedSerials = [String]()
    var selectedProductDict:NSDictionary?
    var duplicateSerials = Array<String>()
    var productType = ""
    var parentId :Int = 0
    var scannedCodes: Set<String> = []
    var lineitemArr:Array<Any>?

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        addAggregationButton.setRoundCorner(cornerRadious: addAggregationButton.frame.height/2.0)
        addAggregationButton.setRoundCorner(cornerRadious: addAggregationButton.frame.height/2.0)
        productAddedSubView.setRoundCorner(cornerRadious: 20)
        updateButton.setRoundCorner(cornerRadious: updateButton.frame.height/2.0)
        createInputAccessoryView()
        productNameTextFiled.inputAccessoryView = inputAccView
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUi()
        setupList()
        checkLineItemSDIExistInAggregation()//,,,sb13
    }
    //MARK: - End
    
    //MARK: - Action
    @IBAction func addAggregationButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddAggregationScanView") as! MISAddAggregationScanViewController
        if let id = selectDict?["id"] as? Int {
            controller.parentId = id
        }
        controller.isFromViewAggregation = true
        controller.delegate = self
        controller.lineItemArr = lineitemArr
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddAggregationView") as! MISAddAggregationViewController
//        if let id = selectDict?["id"] as? Int {
//            controller.parentId = id
//        }
//        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISViewAggregationView") as! MISViewAggregationViewController
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            controller.selectDict = dict
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeaggregation(data: dict)
            }            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func updateButtonPressed(_ sender:UIButton){
        if let str = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines),str.isEmpty{
            Utility.showPopup(Title: "", Message: "Enter the product name", InViewC: self)
        }else{
            self.setUpforProduct()
        }
    }
    @IBAction func cancelButtonPressed(_ sender:UIButton){
        productAddedView.isHidden = true
    }
    //MARK: - End
    
    //MARK: - Private Method
    
    func removeaggregation(data:NSDictionary){
        if let id = data["id"] as? Int{
            var allid = [Int]()
            var complete = [Int]()
            allid.append(id)
            repeat {
                for tempId in allid {
                    if !complete.contains(tempId) {
                        complete.append(tempId)
                        do{
                            let predicate = NSPredicate(format:"parent_id='\(tempId)'")
                            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                            if !serial_obj.isEmpty{
                                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                for tempSubDetails in arr {
                                    if let dict = tempSubDetails as? NSDictionary {
                                        if let subid = dict["id"] as? Int{
                                            allid.append(subid)
                                        }
                                    }
                                }
                            }
                        }catch let error{
                            print(error.localizedDescription)
                        }
                    }
                }
            }while !allid.containsSameElements(as: complete)
            
            do{
                let predicate = NSPredicate(format:"id IN %@", allid)
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    for obj in serial_obj {
                        PersistenceService.context.delete(obj)
                        PersistenceService.saveContext()
                    }
                    setupList()
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func checkLineItemSDIExistInAggregation() {
        if (itemsList != nil) {
            do{
                if let aggregationSDIArr = (itemsList! as NSArray).value(forKeyPath: "@distinctUnionOfObjects.sdi") as? [String] {
                    for i in 0..<aggregationSDIArr.count {
                        let sdi = aggregationSDIArr[i]
                        let predicate = NSPredicate(format:"sdi = '\(sdi)' ")
                        let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                        if serial_obj.isEmpty{
                            //remove
                            do{
                                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                                if !serial_obj.isEmpty{
                                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                    for dict in arr {
//                                        self.removeaggregation(data: arr[0] as! NSDictionary)
                                        self.removeaggregation(data: dict as! NSDictionary)
                                    }
                                }
                            }catch let error{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }catch let error{
                print(error.localizedDescription)

            }
        }
    }//,,,sb13
   
    
    func setupList(){
        if let id = selectDict?["id"] as? Int {
            do{
                let predicate = NSPredicate(format:"parent_id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    itemsList = arr
                    listTable.reloadData()
                }else{
                    itemsList = nil
                    listTable.reloadData()
                }
            }catch let error{
                print(error.localizedDescription)
                itemsList = nil
                listTable.reloadData()
                
            }
        }
        productAddedView.isHidden = true

    }
    
    func populateUi(){
        if let txt = selectDict?["type"] as? String,!txt.isEmpty{
            typeLabel.text = txt.capitalized
        }
        var dataStr = ""
        if let txt = selectDict?["serial"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        if let txt = selectDict?["gs1_serial"] as? String,!txt.isEmpty, dataStr == "" {
            dataStr = txt
        }
        serialLabel.text = dataStr
    }
    
    func getLotItemDetails(sdi:String) -> NSDictionary{
        //,,,sb13
//        var tempLotItemDetails:NSDictionary?
        var tempLotItemDetails:NSDictionary? = [String:Any]() as NSDictionary
        //,,,sb13
        do{
            let predicate = NSPredicate(format:"sdi='\(sdi)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let dict = arr.first as? NSDictionary {
                    tempLotItemDetails = dict
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return tempLotItemDetails!
    }
    
    func getProductName(misitem_id: Int) -> String {
        var tempProductName = ""
        do{
            let predicate = NSPredicate(format:"id='\(misitem_id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let dict = arr.first as? NSDictionary {
                    if let txt = dict["product_name"] as? String,!txt.isEmpty{
                        tempProductName = txt
                    }
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        return tempProductName
    }
    
    func clickOnCameraInviewAggregation(parentId parent_Id:Int){
        parentId = parent_Id
//        if(defaults.bool(forKey: "IsMultiScan")){
////            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
////            controller.delegate = self
////            controller.isForReceivingSerialVerificationScan = true
////            self.navigationController?.pushViewController(controller, animated: true)
//    }else{
        DispatchQueue.main.async {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
        controller.delegate = self
        controller.isFromAggregation = true
        self.navigationController?.pushViewController(controller, animated: true)
        }
//        }
    }
    
    func didClickOnSearchByManually(parentId parent_Id:Int){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAddAggregationView") as! MISAddAggregationViewController
        controller.parentId = parent_Id
        self.navigationController?.pushViewController(controller, animated: false)
    }
    func callApiForGS1BarcodeLookupDetails(scannedCode: [String],productname:String,productGtIn14:String){
       

        let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForSalesOrderByPicking)
        if first.count > 0 {
            self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode,productname: productname,productgtIn14: productGtIn14)
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
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
            do{
                let predicate = NSPredicate(format:"gs1_barcode='\(data)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                if serial_obj.isEmpty{
                   
                    //,,,sb13 temp1
//                    self.allScannedSerials.append(data)
                    
                    self.allScannedSerials = []
                    if !self.allScannedSerials.contains(data) {
                        self.allScannedSerials.append(data)
                    }
                    //,,,sb13 temp1
                    
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
    
    func getGS1BarcodeLookupDetails(serials : String,scannedCode:[String],productname:String,productgtIn14:String){
        
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?barcode=\(str ?? "")&check_inventory=true"
            
            Utility.GETServiceCall(type: "barcodedecoder", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{ [self] in
                    if isDone! {
                        let responsedict: NSDictionary = responseData as! NSDictionary //as? NSArray ?? NSArray()
                        print(responsedict as NSDictionary)
                        selectedProductDict = responsedict
                        
                        //,,,sb13
                        /*
                        let inventoryData = selectedProductDict!["inventory_data"] as! NSDictionary
                        if(inventoryData["is_serial_known"] != nil){
                            let serialKnown = inventoryData["is_serial_known"] as! Bool
                            if (serialKnown == true) {
                                Utility.showPopup(Title: App_Title, Message: "Product already exist in inventory", InViewC: self)
                                return
                            }
                        }*/
                        if let inventoryData:NSDictionary = selectedProductDict!["inventory_data"] as? NSDictionary {
                            if(inventoryData["is_serial_known"] != nil){
                                let serialKnown = inventoryData["is_serial_known"] as! Bool
                                if (serialKnown == true) {
                                    self.removeSpinner()//,,,sb13
                                    Utility.showPopup(Title: App_Title, Message: "Product already exist in inventory", InViewC: self)
                                    return
                                }
                            }
                        }
                        //,,,sb13
                        
                        if let scanProductType = selectedProductDict!["type"]as? String,!scanProductType.isEmpty {
                                if scanProductType == "PRODUCT" || scanProductType == "product"{
                                    self.serialVerify(scannedCode: scannedCode)
                                    var productName = ""
                                    if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                                        if !allproducts.isEmpty  {
                                            let filteredArray = allproducts.filter { $0["gtin14"] as? String == (selectedProductDict!["gtin14"] as! String) }
                                                    print(filteredArray as Any)
                                                    if filteredArray.count > 0 {
                                                        productName = (filteredArray.first?["name"] as? String)!
                                                    }
                                              }
                                    }
                                    self.checkingAggregation(container_content: selectedProductDict as! [String : Any],productName:productName,productGtint14: productgtIn14)
                                }else if scanProductType == "CONTAINER" || scanProductType == "container"{
                                    self.addAggregationWithContainer(containerDict: selectedProductDict)
                                }
                        }else{
                                Utility.showPopup(Title: App_Title, Message: "Something went wrong.Barcode not specify either it is container or product.".localized() , InViewC: self)
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
                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode,productname: productname,productgtIn14: productgtIn14)
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
    func serialVerify(scannedCode: [String]){
        
        var tempGTIN = ""
        var tempLot = ""
        var tempProductName = ""
        
        if selectedProductDict != nil{
            if let gtin = selectedProductDict?["gtin14"] as? String,!gtin.isEmpty, let productName = selectedProductDict?["product_name"] as? String,!productName.isEmpty{
                
                tempGTIN = gtin
                tempProductName = productName
            }
        }
        
        if selectedProductDict != nil{
            if let lot_number = selectedProductDict?["lot_number"] as? String,!lot_number.isEmpty {
                
                tempLot = lot_number
            }
        }
        
        for data in scannedCode {
            
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
                if(details.keys.contains("01")) && (details.keys.contains("10")) && (details.keys.contains("21")){
                    if let _ = details["01"]?["value"] as? String, let _ = details["10"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
//                        if gtin14 != tempGTIN {
//                            Utility.showPopup(Title: App_Title, Message: "Please scan \(tempProductName) serial".localized(), InViewC: self)
//                            break
//                        }
//
//                        if lot != tempLot {
//                            Utility.showPopup(Title: App_Title, Message: "Please scan \(tempProductName) and \(tempLot) serial".localized(), InViewC: self)
//                            break
//                        }
                        verifiedSerials = [String]()
                        verifiedSerials.append(serial)
                    }
                }else{
                    if(details.keys.contains("01")) && (details.keys.contains("21")){
                        if let _ = details["01"]?["value"] as? String, let serial = details["21"]?["value"] as? String{
                            verifiedSerials = [String]()
                            verifiedSerials.append(serial)
                        }
                    }
                }
            }
        }
    }
    func checkingAggregation(container_content:[String:Any],productName:String,productGtint14:String){
        var isexistonLineitem :Bool = false
        print(container_content as Any)
        
            if let scanProductudid = container_content["product_uuid"]as? String,!scanProductudid.isEmpty {
            do{
                 let predicate = NSPredicate(format:"product_uuid='\(scanProductudid)'")
                 let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                 if !serial_obj.isEmpty{
                    if let scanProductlotid = container_content["lot_number"]as? String,!scanProductlotid.isEmpty {
                    do{
                        let predicate = NSPredicate(format:"lot_number='\(scanProductlotid)'")
                        let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                        if !serial_obj.isEmpty{
                            let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                            isexistonLineitem = true
                            self.addAggregation(selectedProductLotDict: (container_content as NSDictionary),selectLineitem: (arr[0] as! NSDictionary))
                        }else{
                            if (defaults.object(forKey: "lineItemCheck") != nil) {
                                if((defaults.object(forKey: "lineItemCheck")) as! Int == 0){
                                    if lineitemArr?.count == nil {
                                        Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)

                                    }else{
                                        Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                                     }
                                  }
                              }
                           }
                       }
                    }else{
                        Utility.showAlertWithPopAction(Title: Warning, Message: "Product Lot number not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)

                    }
                 }else{
                    if (defaults.object(forKey: "lineItemCheck") != nil) {
                        if ((defaults.object(forKey: "lineItemCheck")) as! Int == 0) {
                            if lineitemArr?.count == nil {
                                Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                            }else{
                                Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                            }
                        }
                    }else{
                        if lineitemArr?.count == nil {
                            Utility.showAlertWithPopAction(Title: Warning, Message: "Data not present in line items".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        }
                    }
                 }
            }catch let error{
                print(error.localizedDescription)
            }
        }else{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Product UUID not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)
        }
        
        let scanProductlotid = container_content["lot_number"]as? String
        let scanProductudid = container_content["product_uuid"]as? String
        
        if scanProductudid!.isEmpty || scanProductlotid!.isEmpty{
            Utility.showAlertWithPopAction(Title: Warning, Message: "Product details or lot number not found".localized(), InViewC: self, isPop: true, isPopToRoot: false)
        }else{
            if (defaults.object(forKey: "lineItemCheck") != nil) {
                if !isexistonLineitem && (defaults.object(forKey: "lineItemCheck") ?? 1) as! Bool{
                    let quantity = 1
                    let udid = container_content["product_uuid"] as! String
                    let productname = productName
                    let gtin14 = productGtint14

                    self.addProductforLine(product_uuid: udid, product_name: productname, gtin14: gtin14 , quantity: Int16(quantity),container_content: container_content)
                }
            }
        }
    }
    func addProductforLine(product_uuid:String, product_name:String, gtin14:String, quantity:Int16,container_content:[String:Any]){
        let obj = MISItem(context: PersistenceService.context)
        obj.product_uuid = product_uuid
        obj.product_name = product_name
        obj.gtin14 = gtin14
        obj.quantity = quantity
        obj.id = getAutoIncrementId()
        PersistenceService.saveContext()
        self.addProductforLineLot(container_content:container_content)

    }
    func addProductforLineLot(container_content:[String:Any]){
//        if let misitem_id = container_content["id"] as? Int16 {
            
            let obj = MISLotItem(context: PersistenceService.context)
            
            obj.id = getAutoIncrementId()
            obj.misitem_id = obj.id
            obj.lot_number = container_content["lot_number"] as? String
            obj.best_by_date = ""
            obj.expiration_date = container_content["expiration_date"] as? String
            obj.production_date =  ""
            obj.sell_by_date = ""
            obj.quantity = 1
            obj.lot_type = container_content["product_type"] as? String
            obj.sdi = String(obj.id)
            PersistenceService.saveContext()
            self.checkingLineItemAggregation(container_content: container_content)

//            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Lot Added".localized(), InViewC: self, isPop: false, isPopToRoot: false)
            }
    func checkingLineItemAggregation(container_content:[String:Any]){
        print(container_content as Any)
        
        if let scanProductudid = container_content["product_uuid"]as? String,!scanProductudid.isEmpty {
        do{
             let predicate = NSPredicate(format:"product_uuid='\(scanProductudid)'")
             let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
             if !serial_obj.isEmpty{
                if let scanProductlotid = container_content["lot_number"]as? String,!scanProductlotid.isEmpty {
                do{
                    let predicate = NSPredicate(format:"lot_number='\(scanProductlotid)'")
                    let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                    if !serial_obj.isEmpty{
                        let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                        self.addAggregation(selectedProductLotDict: (container_content as NSDictionary),selectLineitem: (arr[0] as! NSDictionary))
                    }else{
                        if (defaults.object(forKey: "lineItemCheck") != nil) {
                            if((defaults.object(forKey: "lineItemCheck")) as! Int == 0){
                                Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation lot Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                            }
                        }
                     }
                   }
                }
             }else{
                if (defaults.object(forKey: "lineItemCheck") != nil) {
                    if ((defaults.object(forKey: "lineItemCheck")) as! Int == 0) {
                        Utility.showAlertWithPopAction(Title: Warning, Message: "Mismatch between the Line Items and the Aggregation Data".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
             }
        }catch let error{
            print(error.localizedDescription)
            }
        }
    }
        
    func addAggregationWithContainer(containerDict:NSDictionary?){
        //,,,sb13
        /*
        let gs1Serial = containerDict!["gs1_urn"] as! String
        let simpleSerial = ""
        */
        print ("containerDict...MISViewAggregationViewController",containerDict!)
        
        var gs1Serial = ""
        var simpleSerial = ""
        
        if let gs1_urn = containerDict!["gs1_urn"]as? String,!gs1_urn.isEmpty {
            gs1Serial = gs1_urn
        }
        else {
            if let serial_number = containerDict!["serial_number"]as? String,!serial_number.isEmpty {
                simpleSerial = serial_number
            }
        }
        //,,,sb13
                
//    if let txt = simpleSerialTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
//        simpleSerial = txt
//    }
//        var quantity = 0
//        if let txt = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , !txt.isEmpty {
//            quantity = Int(txt) ?? 0
//        }
    
    var isvalidate = true
    productType = containerDict!["type"] as! String
    
    if productType == "container" || productType == "CONTAINER"  {
    
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
            containerobj.type = "container"
            PersistenceService.saveContext()
            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: false, isPopToRoot: false)
            }
            self.setupList()
        }
    }
    func addAggregation (selectedProductLotDict:NSDictionary?,selectLineitem:NSDictionary?){
        var isvalidate = true
        var quantity = 0

        if let lot_type = selectLineitem?["lot_type"] as? String,!lot_type.isEmpty, let sdi = selectLineitem?["sdi"] as? String,!lot_type.isEmpty, let tmp_quantity = selectLineitem?["quantity"] as? Int{
                
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
                           // serialProductobj.gs1_barcode = (selectedProductLotDict!["gs1_barcode"] as! String)
                            if (selectedProductLotDict!["gs1_urn"] != nil){
                                serialProductobj.gs1_serial = (selectedProductLotDict!["gs1_urn"] as! String)
                            }
                            serialProductobj.parent_id = Int16(parentId)
                            serialProductobj.id = getAutoIncrementId()
                            serialProductobj.type = "product"
                            serialProductobj.sdi = sdi
                            serialProductobj.serial = serial
                            PersistenceService.saveContext()
                        }
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        self.setupList()

                    }
                }else if lot_type == "LOT_BASED" || lot_type == "LOT_FOUND" {
                    quantity = tmp_quantity
                    
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
                        
                      //  lotProductobj.gs1_barcode = (selectedProductLotDict!["gs1_barcode"] as! String)
                        lotProductobj.gs1_serial = (selectedProductLotDict!["gs1_urn"] as! String)
                        lotProductobj.parent_id = Int16(parentId)
                        lotProductobj.id = getAutoIncrementId()
                        lotProductobj.type = "product"
                        lotProductobj.sdi = sdi
                        lotProductobj.lot_based_quantity = Int16(quantity)
                        PersistenceService.saveContext()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Ok Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        self.setupList()
                    }
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
    func setUpforProduct(){
        
        let requestDict = NSMutableDictionary()
        requestDict.setValue("Pharmaceutical", forKey: "type")
        requestDict.setValue("AVAILABLE", forKey: "status")
        requestDict.setValue(true, forKey: "is_active")
        requestDict.setValue(false, forKey: "is_send_copy_outbound_shipments_to_2nd_party")
        requestDict.setValue(false, forKey: "is_override_products_packaging_type_validation")
        requestDict.setValue(gtin14Label.text, forKey: "gtin14")
        
        
        let dict = NSMutableDictionary()
        let arr = [] as NSMutableArray
        dict.setValue("en", forKey: "language_code")
        dict.setValue(productNameTextFiled.text, forKey: "name")
        dict.setValue("", forKey: "description")
        dict.setValue("", forKey: "composition")
        dict.setValue("", forKey: "product_long_name")
        arr.add(dict)
        requestDict.setValue(Utility.json(from: arr) ,forKey: "product_descriptions")
        self.productApiCall(requestDict: requestDict)
    }
    func productApiCall(requestDict : NSDictionary){
        DispatchQueue.main.async { [self] in
            productAddedView.isHidden = true
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "AddNewProduct", serviceParam: requestDict, parentViewC: self, willShowLoader: false, viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async { [self] in
                self.removeSpinner()
                if isDone! {
                scannedCodes = []
                scannedCodes.insert(scannedCodeDetails["scannedCode"] as! String)
                self.addUpdateSerialsToDB(scannedCode: Array(scannedCodes))
                DispatchQueue.main.async{
                    self.callApiForGS1BarcodeLookupDetails(scannedCode: Array(self.scannedCodes),productname: productNameTextFiled.text! as String ,productGtIn14: gtin14Label.text! as String)
                }
            
            }else{
                let dict = responseData as! NSDictionary
                let error = dict["message"] as! String
                    Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                }
            }
        }
    }
}
//MARK: - End

//MARK: - Tableview Delegate and Datasource
extension MISViewAggregationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "MISAggregationViewCell") as! MISAggregationViewCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        cell.typeView.isHidden = true
        cell.arrowButton.isHidden = true
        cell.serialView.isHidden = true
        
        if let dict = self.itemsList![indexPath.row] as? NSDictionary {
            
            var dataStr = ""
            if let txt = dict["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            if let txt = dict["gs1_serial"] as? String,!txt.isEmpty, dataStr == "" {
                dataStr = txt
            }
            cell.serialLabel.text = dataStr
            
            if let type = dict["type"] as? String,!type.isEmpty{
                if type == "product" || type == "PRODUCT"{
                    cell.typeView.isHidden = false
                    cell.titleButton.isSelected = false
                    if let txt = dict["sdi"] as? String,!txt.isEmpty{
                        cell.referenceLabel.text = txt
                        
                        let tempLotDetails = getLotItemDetails(sdi: txt)
                        
                        if let lot_type = tempLotDetails["lot_type"] as? String,!txt.isEmpty{
                            
                            if lot_type == "SERIAL_BASED" {
                                cell.typeLabel.text = "Serial Based"
                                cell.serialView.isHidden = false
                            }else if lot_type == "LOT_BASED" {
                                cell.typeLabel.text = "Lot Based"
                            }
                            
                            dataStr = ""
                            if let txt = tempLotDetails["lot_number"] as? String,!txt.isEmpty{
                                dataStr = txt
                            }
                            cell.lotLabel.text = dataStr
                            
                            dataStr = ""
                            if let misitem_id = tempLotDetails["misitem_id"] as? Int{
                                dataStr = getProductName(misitem_id: misitem_id)
                            }
                            cell.titleLabel.text = dataStr
                        }
                        else {
                            cell.typeLabel.text = ""
                            cell.lotLabel.text = ""
                            cell.titleLabel.text = ""
                            cell.referenceLabel.text = ""
                        }//,,,sb13
                    }
                    
                    
                } else if type == "container" || type == "CONTAINER"{
                    cell.serialView.isHidden = false
                    cell.titleButton.isSelected = true
                    cell.arrowButton.isHidden = false
                    cell.titleLabel.text = "Container".localized()
                }
            }
        }
        
        cell.arrowButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
}

//MARK: - End



//MARK: - Tableview Cell
class MISAggregationViewCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
  
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var serialLabel: UILabel!
    
    @IBOutlet weak var serialView: UIView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - SingleScanDelegate Method

extension MISViewAggregationViewController : SingleScanViewControllerDelegate{
    internal func didSingleScanCodeForScanAggreation(codeDetails: [String : Any],productName:String,productGtIn14:String,lotnumber:String,serialnumber:String,expirationdate:String){
        
        
        self.dismiss(animated: true, completion:{ [self] in
            
            //,,,sb13
            var scanProductType = ""
            if let scannedCode = codeDetails["scannedCode"] as? String, !scannedCode.isEmpty {
                let productTypeNumber = scannedCode.prefix(2)
                if (productTypeNumber == "00") {
                    scanProductType =  "CONTAINER"
                }
                else if (productTypeNumber == "01") {
                    scanProductType =  "PRODUCT"
                }
            }
            //,,,sb13
            
            
            //,,,sb13
    //        if productName.isEmpty {
             if scanProductType == "PRODUCT" && productName.isEmpty {
            //,,,sb13
                
                productAddedView.isHidden = false

                if !productGtIn14.isEmpty{
                    gtin14Label.text = productGtIn14
                }
                if !lotnumber.isEmpty {
                    lotLabel.text = lotnumber
                }
                if !serialnumber.isEmpty {
                    serialproductaddviewLabel.text = serialnumber
                }
                if !expirationdate.isEmpty{
                    let arr =  expirationdate.split(separator: "T")
                    if arr.count>0{
                        expirationDateLabel.text = String(arr[0])
                    }
                }
                scannedCodeDetails = codeDetails
                productNameTextFiled.text = ""

            }
            else{
                productAddedView.isHidden = true

                scannedCodes = []
                scannedCodes.insert(codeDetails["scannedCode"] as! String)
                self.addUpdateSerialsToDB(scannedCode: Array(scannedCodes))
                DispatchQueue.main.async{
                    self.callApiForGS1BarcodeLookupDetails(scannedCode: Array(self.scannedCodes),productname: productName ,productGtIn14: productGtIn14)
                }
            }
       })
    }
}
//MARK: - End
