//
//  MWPuchaseOrderListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 18/07/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

/*
protocol MWPuchaseOrderListViewControllerDelegate: AnyObject {
    func didSelectMWPuchaseOrder(detailsDict:MWPuchaseOrderModel?, erpUUID:String)
}
*/

class MWPuchaseOrderListViewController: BaseViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var clearSearchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var purchaseOrderListTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
//    weak var delegate: MWPuchaseOrderListViewControllerDelegate?
//    var erpDict = [String: Any]()
    var erpUUID = ""
    var erpName = ""
    var itemsListArray : [MWPuchaseOrderModel] = []
    var filterItemsListArray : [MWPuchaseOrderModel] = []
    var selectedPuchaseOrderDict: MWPuchaseOrderModel?

    //MARK: - IBAction
    @IBAction func clearSearchButtonPressed(_ sender: UIButton) {
        if searchTextField.text != "" {
            clearSearchButton.isHidden = true
            searchTextField.text = ""
            filterItemsListArray = itemsListArray
            purchaseOrderListTableView.reloadData()
        }
    }
    @IBAction func searchCloseButtonPressed(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        topView.isHidden = false
        searchView.isHidden = true
        
        self.clearSearchButtonPressed(clearSearchButton)
    }
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.becomeFirstResponder()
        topView.isHidden = true
        searchView.isHidden = false
        clearSearchButton.isHidden = true
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        /*
        if selectedPuchaseOrderDict != nil {
            self.navigationController?.popViewController(animated: true)
            
            self.delegate?.didSelectMWPuchaseOrder(detailsDict: selectedPuchaseOrderDict, erpUUID:erpUUID)
        }
        else {
            Utility.showPopup(Title: App_Title, Message: "Please select purchase order".localized(), InViewC: self)
        }
        */
        
        if selectedPuchaseOrderDict != nil {
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSelectionViewController") as! MWReceivingSelectionViewController
            controller.delegate = self
            controller.previousController = "MWPuchaseOrderListViewController"
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        else {
            Utility.showPopup(Title: Warning, Message: "Please select purchase order".localized(), InViewC: self)
        }
    }
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        if let item = filterItemsListArray[sender.tag] as MWPuchaseOrderModel? {
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWViewItemsViewController") as! MWViewItemsViewController
            controller.erpUUID = erpUUID
            controller.erpName = erpName
            controller.poNumber = item.poNumber!
            controller.poUniqueID = item.uniqueID!
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK: - End
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        self.createInputAccessoryViewCustom()
        topView.isHidden = false
        searchView.isHidden = true
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search PO#".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        /*
        if let erp_uuid = erpDict["erp_uuid"] as? String , !erp_uuid.isEmpty {
            erpUUID = erp_uuid
        }

        if let erp_name = erpDict["erp_name"] as? String , !erp_name.isEmpty {
            erpName = erp_name
        }
        headerTitleButton.setTitle("Select PO for".localized() + " " + erpName, for: UIControl.State.normal)

        self.listPurchaseOrdersWebServiceCall()
        */
        
        self.erpActionWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Webservice call
    func erpActionWebServiceCall() {
        /*
        Get Action Erps
        18a6c216-5320-4ab8-bec7-61a4eb2a9997
        https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/get-erps-in-action
        POST
        {
          "action_uuid": "18a6c216-5320-4ab8-bec7-61a4eb2a9997",
          "target_action": "185eb551-cb71-4d11-bfa3-31693d06163f",
          "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43"
        }
        */
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"erpAction")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["target_action"] = Utility.getActionId(type: "erpTargetAction")

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ErpAction", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                
                if isDone! {
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                       let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            if let dataDict = Utility.convertToDictionary(text: responseDict["data"] as! String) {
//                                print("dataDict.....?????",dataDict)
                                if let source_erp = dataDict ["source_erp"] as? String {
                                    //,,,sbm1 temp
//                                    self.erpUUID = source_erp
                                    self.erpUUID = MWStaticData.ERP_UUID.odoo.rawValue
                                    let barcodeType = dataDict["barcode_format"] as? String
                                    defaults.setValue("GS1", forKey: "barcode_format")
                                    //,,,sbm1 temp

                                    
                                    if let target_erps = dataDict ["target_erps"] as? [[String:Any]] {
                                        let filteredArray = target_erps.filter { $0["erp_uuid"] as? String == self.erpUUID }
                                         if filteredArray.count > 0 {
                                             let dict = filteredArray.first
                                             self.erpName = dict!["erp_name"] as? String ?? ""
//                                             self.headerTitleButton.setTitle("Select PO for".localized() + " " + self.erpName, for: UIControl.State.normal)
                                             self.headerTitleButton.setTitle("Select PO".localized(), for: UIControl.State.normal)
                                         }
                                    }
                            
                                    self.listPurchaseOrdersWebServiceCall()
                                }
                            }
                        }else {
                            if responseData != nil {
                                let responseDict: NSDictionary = responseData as! NSDictionary
                                let errorMsg = responseDict["message"] as! String
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                            }else {
                                Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }
                        }
                    }
                }else {
                    if responseData != nil {
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else {
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    func listPurchaseOrdersWebServiceCall() {
        /*
        List Purchase Orders
        ae4d2fcb-e77c-4c65-814f-2c8000bc6e1a
        https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-purchase-orders
        POST
         {
                 "action_uuid": "ae4d2fcb-e77c-4c65-814f-2c8000bc6e1a",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266"
         }
        */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listPurchaseOrdersAction")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = erpUUID

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListPurchaseOrders", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                
                if isDone! {
                    //,,,sbm0 temp
                    
                    //API
               
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                let dataArray = dataArr as! [[String:Any]]
                                
                                if self.erpName == "odoo" {
                                    for dict in dataArray {
                                        var uniqueID = ""
//                                        if let value = dict["id"] as? Int {
                                        if let value = dict["id"] as? String {
//                                            uniqueID = String(value)
                                            uniqueID = value
                                        }
                                        var poNumber = ""
                                        if let value = dict["name"] as? String {
                                            poNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        var vendor = ""
                                        if let value = dict["vendor"] as? String {
                                            vendor = value
                                        }
                                        var location = ""
                                        if let value = dict["location"] as? String {
                                            location = value
                                        }
                                        
                                        let mwPuchaseOrderModel = MWPuchaseOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      poNumber: poNumber,
                                                                                      createdOn: createdOn,
                                                                                      vendor: vendor,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwPuchaseOrderModel)
                                        self.filterItemsListArray.append(mwPuchaseOrderModel)
                                    }
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var uniqueID = ""
                                        if let value = dict["uuid"] as? String {
                                            uniqueID = value
                                        }
                                        var poNumber = ""
                                        if let value = dict["po_nbr"] as? String {
                                            poNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        
                                        let mwPuchaseOrderModel = MWPuchaseOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      poNumber: poNumber,
                                                                                      createdOn: createdOn,
                                                                                      vendor: "",
                                                                                      location: "")
                                        
                                        self.itemsListArray.append(mwPuchaseOrderModel)
                                        self.filterItemsListArray.append(mwPuchaseOrderModel)
                                    }
                                }
//                                                self.populateSelectedPO()
                                self.purchaseOrderListTableView.reloadData()
                            }
                        }else {
                            if responseData != nil {
                                let responseDict: NSDictionary = responseData as! NSDictionary
                                let errorMsg = responseDict["message"] as! String
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                            }else {
                                Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }
                        }
                    }
               
                    
                    
                    
                        
            /*
                //Local File
                var path = ""
                if self.erpUUID == "41afff72-2eac-4f2e-ab2f-9adab4323d0d" {
                    //TTRx
                    path = Bundle.main.path(forResource: "MWListPurchaseOrders_ttrx", ofType: "json")!
                }else {
                    path = Bundle.main.path(forResource: "MW_list-purchase-orders_odoo", ofType: "json")!
                }
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    if let responseDict: NSDictionary = jsonResult as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                let dataArray = dataArr as! [[String:Any]]
                                    
                                if self.erpName == "odoo" {
                                    for dict in dataArray {
                                        var uniqueID = ""
//                                        if let value = dict["id"] as? Int {
                                        if let value = dict["id"] as? String {
//                                            uniqueID = String(value)
                                            uniqueID = value
                                        }
                                        var poNumber = ""
                                        if let value = dict["name"] as? String {
                                            poNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        var vendor = ""
                                        if let value = dict["vendor"] as? String {
                                            vendor = value
                                        }
                                        var location = ""
                                        if let value = dict["location"] as? String {
                                            location = value
                                        }
                                        
                                        let mwPuchaseOrderModel = MWPuchaseOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      poNumber: poNumber,
                                                                                      createdOn: createdOn,
                                                                                      vendor: vendor,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwPuchaseOrderModel)
                                        self.filterItemsListArray.append(mwPuchaseOrderModel)
                                    }
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var uniqueID = ""
                                        if let value = dict["uuid"] as? String {
                                            uniqueID = value
                                        }
                                        var poNumber = ""
                                        if let value = dict["po_nbr"] as? String {
                                            poNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        
                                        let mwPuchaseOrderModel = MWPuchaseOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      poNumber: poNumber,
                                                                                      createdOn: createdOn,
                                                                                      vendor: "",
                                                                                      location: "")
                                        
                                        self.itemsListArray.append(mwPuchaseOrderModel)
                                        self.filterItemsListArray.append(mwPuchaseOrderModel)
                                    }
                                }
    //                                                self.populateSelectedPO()
                                self.purchaseOrderListTableView.reloadData()
                            }
                        }else {
                            if responseData != nil {
                                let responseDict: NSDictionary = responseData as! NSDictionary
                                let errorMsg = responseDict["message"] as! String
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                            }else {
                                Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }
                        }
                    }
                } catch {
                   print("JSON parsing Error")
                }
               */
                //,,,sbm0 temp
                    
            }else {
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
    //MARK: - End
    
    //MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        self.autoCompleteWithStr(searchStr: updatedText)
        
        return true
    }
    func autoCompleteWithStr(searchStr:String?) {
        if searchStr == "" {
            clearSearchButton.isHidden = true
        }else {
            clearSearchButton.isHidden = false
        }
        
        let filteredArray = self.itemsListArray.filter { $0.poNumber!.localizedCaseInsensitiveContains(searchStr!) }
        if filteredArray.count>0 {
            filterItemsListArray = filteredArray
        }
        else {
            filterItemsListArray = []
            if searchStr == "" {
                filterItemsListArray = itemsListArray
            }
        }
        purchaseOrderListTableView.reloadData()
    }
    //MARK: - End
    
    //MARK: - Defined Methods For Input Accessory view[Done]
    func createInputAccessoryViewCustom() {
        inputAccView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 40.0))
        inputAccView?.backgroundColor = UIColor.init(red: 198/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        let btnDone: UIButton = UIButton(type: .custom)
        btnDone.frame = CGRect(x: (UIScreen.main.bounds.size.width - 80.0), y: 0.0, width: 80.0, height: 40.0)
        btnDone.setTitle("Done".localized(), for: UIControl.State())
        btnDone.setTitleColor(UIColor.black, for: UIControl.State())
        btnDone.addTarget(self, action: #selector(doneTypingCustom), for: .touchUpInside)
        inputAccView!.addSubview(btnDone)
                
        let btnCancel: UIButton = UIButton(type: .custom)
        btnCancel.frame = CGRect(x: 0, y: 0.0, width: 80.0, height: 40.0)//(UIScreen.main.bounds.size.width - 300.0)
        btnCancel.setTitle("Cancel".localized(), for: UIControl.State())
        btnCancel.setTitleColor(UIColor.black, for: UIControl.State())
        btnCancel.addTarget(self, action: #selector(cancelTypingCustom), for: .touchUpInside)
        inputAccView!.addSubview(btnCancel)
    }
    @objc func doneTypingCustom() {
        self.view.endEditing(true)
    }
    @objc func cancelTypingCustom() {
        self.view.endEditing(true)
    }
    //MARK: - End
}

//MARK: - MWReceivingSelectionViewControllerDelegate
extension MWPuchaseOrderListViewController: MWReceivingSelectionViewControllerDelegate {
    func didClickOnCamera(){
        //,,,sbm2 temp
        
        if(defaults.bool(forKey: "IsMultiScan")){
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWMultiScanViewController") as! MWMultiScanViewController
            controller.isForReceivingSerialVerificationScan = true
            controller.isForPickingScanOption = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWSingleScanViewController") as! MWSingleScanViewController
            controller.delegate = self
            controller.isForReceivingSerialVerificationScan = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    
        
//        self.didSingleScanCodeForReceiveSerialVerification(scannedCode: [])
        //,,,sbm2 temp
    }
    
    func didClickManually(){
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingManuallyViewController") as! MWReceivingManuallyViewController
        controller.flowType = "directManualLot"
        controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func didClickCrossButton() {
    }
}
//MARK: - End

//MARK: - MWMultiScanViewControllerDelegate
extension MWPuchaseOrderListViewController : MWMultiScanViewControllerDelegate {
    
    func didScanCodeForReceiveSerialVerification(scannedCode:[String]) {
        print("didScanCodeForReceiveSerialVerification....>>",scannedCode)
        
        if scannedCode.count > 0 {
            self.didSingleScanCodeForReceiveSerialVerification(scannedCode: scannedCode)
        }
    }
    func backFromMultiScan() {
    }
}
//MARK: - End

//MARK: - MWSingleScanViewControllerDelegate
extension MWPuchaseOrderListViewController : MWSingleScanViewControllerDelegate {
    
    func didSingleScanCodeForReceiveSerialVerification(scannedCode:[String]) {
        print("didSingleScanCodeForReceiveSerialVerification....>>",scannedCode)
        
        /*
        01: {
            GTIN = 070707001010;
            indicator = 1;
        }
        21: 220508383877299
        17: {
            day = 25;
            month = 7;
            year = 2024;
        }
        10: 0F147660
        */
        
        for code in scannedCode{
            let details = UtilityScanning(with:code).decoded_info
            if details.count > 0 {
                var gtin = ""
                var indicator = ""
                var serial = ""
                var lot = ""
                var year = ""
                var day = ""
                var month = ""
                
                if(details.keys.contains("00")){
                    if let cSerial = details["00"]?["value"] as? String{
                        //containerSerialNumber = cSerial
                    }else if let cSerial = details["00"]?["value"] as? NSNumber{
                        //containerSerialNumber = "\(cSerial)"
                    }
                }else{
                    if(details.keys.contains("01")){
                        if let gtin14Value = details["01"]?["value"] as? String{
                            gtin = gtin14Value
                        }
                    }
                    if(details.keys.contains("10")){
                        if let lotdetails = details["10"]?["value"] as? String{
                            lot = lotdetails
                        }
                    }
                    if(details.keys.contains("21")){
                        if let serialdetails = details["21"]?["value"] as? String{
                            serial = serialdetails
                        }
                    }
                    if (details.keys.contains("17")) {
                        if let expiration = details["17"]?["value"] as? String{
                            let splitarr = expiration.split(separator: "T")
                            if splitarr.count>0{
                               let expirationDate = String(splitarr[0])
                                let arr = expirationDate.components(separatedBy: "-")
                                year = arr[0]
                                month = arr[1]
                                day = arr[2]
                            }
                        }
                    }
                    //,,,sbm2-1
                                var product_tracking = "serial"
                                if serial == "" {
                                    product_tracking = "lot"
                                }
                                //,,,sbm2-1
                    
                        do{
                            let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                            if fetchRequestResultArray.isEmpty {
                                let obj = MW_ReceivingScanProduct(context: PersistenceService.context)
                                obj.id = MWReceivingScanProduct.getAutoIncrementId()
                                obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                                obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                                obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                                obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                                obj.gtin = gtin
                                obj.indicator = indicator
                                obj.serial_number = serial
                                obj.day = day
                                obj.month = month
                                obj.year = year
                                obj.lot_number = lot
                                obj.product_tracking = product_tracking //,,,sbm2-1
                                PersistenceService.saveContext()
                            }
                        }catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        /*
        let scanProductArray = Utility.createSampleScanProduct()//,,,sbm2 temp//
        
        //,,,sbm2
        for scanProductDict in scanProductArray {
            var gtin = ""
            var indicator = ""
            var serial = ""
            var lot = ""
            var year = ""
            var day = ""
            var month = ""
            
            if let gtinDict = scanProductDict["01"] as? [String:Any] {
                if let GTIN = gtinDict["GTIN"] as? String {
                    gtin = GTIN
                }
                if let INDICATOR = gtinDict["indicator"] as? String {
                    indicator = INDICATOR
                }
            }
            if let serialNumber = scanProductDict["21"] as? String {
                serial = serialNumber
            }
            if let lotNumber = scanProductDict["10"] as? String {
                lot = lotNumber
            }
            if let dateDict = scanProductDict["17"] as? [String:Any] {
                if let YEAR = dateDict["year"] as? String {
                    year = YEAR
                }
                if let DAY = dateDict["day"] as? String {
                    day = DAY
                }
                if let MONTH = dateDict["month"] as? String {
                    month = MONTH
                }
            }
            
            do{
                let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    let obj = MW_ReceivingScanProduct(context: PersistenceService.context)
                    obj.id = MWReceivingScanProduct.getAutoIncrementId()
                    obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                    obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                    obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                    obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                    obj.gtin = gtin
                    obj.indicator = indicator
                    obj.serial_number = serial
                    obj.day = day
                    obj.month = month
                    obj.year = year
                    obj.lot_number = lot
                    PersistenceService.saveContext()
                }
            }catch let error {
                print(error.localizedDescription)
            }
        }
        //,,,sbm2
        */
        if scannedCode.count > 0 {
            let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
            controller.flowType = "directSerialScan"
            controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func backFromSingleScan() {
    }
}
//MARK: - End

//MARK: - Tableview Delegate and Datasource
extension MWPuchaseOrderListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterItemsListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseOrderListTableCell") as! PurchaseOrderListTableCell
        
        cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "959596"), cornerRadious: 0)
        cell.viewItemsButton.setBorder(width: 1, borderColor: (cell.viewItemsButton.titleLabel?.textColor)!, cornerRadious: 2)
        
        if let item = filterItemsListArray[indexPath.section] as MWPuchaseOrderModel? {

            cell.checkUncheckRadioButton.isSelected = false
            if selectedPuchaseOrderDict != nil {
                if let uuid = selectedPuchaseOrderDict?.uniqueID as? String , !uuid.isEmpty {
                    if uuid == item.uniqueID {
                        cell.checkUncheckRadioButton.isSelected = true
                    }
                }
            }
          
            cell.poNbrLabel.text = item.poNumber
            cell.vendorLabel.text = item.vendor
            cell.locationLabel.text = item.location
            
            if self.erpName == "odoo" {
                cell.createdOnLabel.text = item.createdOn
            }
            else if self.erpName == "ttrx" {
                if let date = item.createdOn {
                    if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: date){
                        cell.createdOnLabel.text = formattedDate
                    }
                }
            }
        }
        
        cell.viewItemsButton.tag = indexPath.section
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedPuchaseOrderDict = filterItemsListArray[indexPath.section]
        purchaseOrderListTableView.reloadData()

        MWReceiving.removeAllMW_ReceivingEntityDataFromDB()//,,,sbm2
    }
}
//MARK: - End

//MARK: - Tableview Cell
class PurchaseOrderListTableCell: UITableViewCell {
    @IBOutlet weak var poNbrLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var checkUncheckRadioButton: UIButton!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        poNbrLabel.text = ""
        createdOnLabel.text = ""
        vendorLabel.text = ""
        locationLabel.text = ""
        
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End

//MARK: - Model
struct MWPuchaseOrderModel {
    var erpUUID : String!
    var erpName : String!
    
    var uniqueID: String!
    var poNumber: String!
    var createdOn: String!
    var vendor: String!
    var location: String!
}

struct MWReceivingScanProductModel {
    var primaryID : Int16!
    var erpUUID : String!
    var erpName : String!
    var poUniqueID: String!
    var poNumber : String!
    
    var GTIN: String!
    var indicator: String!
    var serialNumber: String!
    var day: String!
    var month: String!
    var year: String!
    var lotNumber: String!
    var productTracking: String!//,,,sbm2-1
}
//MARK: - End
