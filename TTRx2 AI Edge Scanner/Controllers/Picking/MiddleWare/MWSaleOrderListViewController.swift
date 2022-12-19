//
//  MWSaleOrderListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 01/11/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm3

import UIKit

class MWSaleOrderListViewController: BaseViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchCloseButton: UIButton!
    @IBOutlet weak var clearSearchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var saleOrderListTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var erpUUID = ""
    var erpName = ""
    var itemsListArray : [MWSaleOrderModel] = []
    var filterItemsListArray : [MWSaleOrderModel] = []
    var selectedSaleOrderDict: MWSaleOrderModel?
    
    //,,,sbm2-2
    var loadMoreButton = UIButton()
    var loadMoreActive = false
    var currentPage = 1
    var totalResult = 0
    //,,,sbm2-2

    //MARK: - IBAction
    @IBAction func clearSearchButtonPressed(_ sender: UIButton) {
        if searchTextField.text != "" {
            clearSearchButton.isHidden = true
            searchTextField.text = ""
            filterItemsListArray = itemsListArray
            saleOrderListTableView.reloadData()
        }
    }
    @IBAction func searchCloseButtonPressed(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        topView.isHidden = false
        searchView.isHidden = true
        
        self.clearSearchButtonPressed(clearSearchButton)
        
        //,,,sbm2-2
        if loadMoreActive {
            loadMoreButton.isHidden = false
        }else {
            loadMoreButton.isHidden = true
        }
        //,,,sbm2-2
    }
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.becomeFirstResponder()
        topView.isHidden = true
        searchView.isHidden = false
        clearSearchButton.isHidden = true
        
        loadMoreButton.isHidden = true //,,,sbm2-2
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if selectedSaleOrderDict != nil {
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSelectionViewController") as! MWPickingSelectionViewController
            controller.delegate = self
            controller.previousController = "MWSaleOrderListViewController"
            controller.modalTransitionStyle = .flipHorizontal
            self.present(controller, animated: true, completion: nil)
        }
        else {
            Utility.showPopup(Title: Warning, Message: "Please select sale order".localized(), InViewC: self)
        }
    }
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        if let item = filterItemsListArray[sender.tag] as MWSaleOrderModel? {
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingViewItemsViewController") as! MWPickingViewItemsViewController
            controller.erpUUID = erpUUID
            controller.erpName = erpName
            controller.soNumber = item.soNumber!
            controller.soUniqueID = item.uniqueID!
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK: - End
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        loadMoreFooterView()//,,,sbm2-2
        self.createInputAccessoryViewCustom()
        topView.isHidden = false
        searchView.isHidden = true
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search SO#".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        self.erpActionWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Privae method
    func loadMoreFooterView() {
        loadMoreButton = UIButton(frame: CGRect(x: 0, y: -20, width: self.saleOrderListTableView.frame.width, height: 50))
        //UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.listTable.frame.width, height: 40)))
        loadMoreButton.titleLabel?.textAlignment = .center
        loadMoreButton.setTitleColor(#colorLiteral(red: 0.02745098039, green: 0.1294117647, blue: 0.2666666667, alpha: 1), for: .normal)
        loadMoreButton.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 16.0)
        loadMoreButton.setTitle("Load more".localized(), for: .normal)
        loadMoreButton.backgroundColor = .clear
        self.saleOrderListTableView.tableFooterView?.backgroundColor = .clear
        loadMoreButton.addTarget(self, action:#selector(loadMoreButtonPressed), for: .touchUpInside)
        self.saleOrderListTableView.tableFooterView = loadMoreButton
    }//,,,sbm2-2
    @objc func loadMoreButtonPressed(sender: UIButton){
        currentPage += 1
        sender.isUserInteractionEnabled = false
        self.listSaleOrdersWebServiceCall(callType: "loadMore")
    }//,,,sbm2-2
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
                                    //,,,sbm0 temp
                                    self.erpUUID = source_erp
//                                    self.erpUUID = MWStaticData.ERP_UUID.odoo.rawValue
//                                    self.erpName = "odoo"
                                    //,,,sbm0 temp

                                    
                                    if let target_erps = dataDict ["target_erps"] as? [[String:Any]] {
                                        let filteredArray = target_erps.filter { $0["erp_uuid"] as? String == self.erpUUID }
                                         if filteredArray.count > 0 {
                                             let dict = filteredArray.first
                                             self.erpName = dict!["erp_name"] as? String ?? ""
                                             self.headerTitleButton.setTitle("Select SO".localized(), for: UIControl.State.normal)
                                         }
                                    }
                            
                                    self.listSaleOrdersWebServiceCall(callType: "firstLoad") //,,,sbm2-2
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
    
    func listSaleOrdersWebServiceCall(callType:String) { //,,,sbm2-2
        /*
        List Sale Orders
         293b88e0-8a91-48c2-884b-8d56b5d2d57c
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-sale-orders
        POST
         {
                 "action_uuid": "293b88e0-8a91-48c2-884b-8d56b5d2d57c",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266"
         }
         
         //,,,sbm2-2
         New POST
         {
                 "action_uuid": "293b88e0-8a91-48c2-884b-8d56b5d2d57c",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "page": 1
         }
         //,,,sbm2-2
        */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listSaleOrders")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = erpUUID
        requestDict["page"] = currentPage //,,,sbm2-2

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListSaleOrders", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                self.loadMoreButton.isUserInteractionEnabled = true //,,,sbm2-2
                
                if isDone! {
                    
                    //,,,sbm0 temp
                    
                    //API
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                //,,,sbm2-2
                                if dataArr.count <= 10 {
                                    self.loadMoreButton.isHidden = true
                                    self.loadMoreActive = false
                                }else {
                                    self.loadMoreButton.isHidden = false
                                    self.loadMoreActive = true
                                }
                                //,,,sbm2-2
                     
                                let dataArray = dataArr as! [[String:Any]]
//                                if self.erpName == "odoo" { //,,,sbm5
                                    for dict in dataArray {
                                        var uniqueID = ""
//                                        if let value = dict["id"] as? Int {
                                        if let value = dict["id"] as? String {
//                                            uniqueID = String(value)
                                            uniqueID = value
                                        }
                                        var soNumber = ""
                                        if let value = dict["name"] as? String {
                                            soNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        var customer = ""
                                        if let value = dict["customer"] as? String {
                                            customer = value
                                        }
                                        var location = ""
                                        if let value = dict["location"] as? String {
                                            location = value
                                        }
                                        
                                        let mwSaleOrderModel = MWSaleOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      soNumber: soNumber,
                                                                                      createdOn: createdOn,
                                                                                      customer: customer,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwSaleOrderModel)
                                        self.filterItemsListArray.append(mwSaleOrderModel)
                                    }
                                //,,,sbm5
                                /*
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                         var uniqueID = ""
                    //                                        if let value = dict["id"] as? Int {
                                         if let value = dict["id"] as? String {
                    //                                            uniqueID = String(value)
                                             uniqueID = value
                                         }
                                         var soNumber = ""
                                         if let value = dict["name"] as? String {
                                             soNumber = value
                                         }
                                         var createdOn = ""
                                         if let value = dict["created_on"] as? String {
                                             createdOn = value
                                         }
                                         var customer = ""
                                         if let value = dict["customer"] as? String {
                                             customer = value
                                         }
                                         var location = ""
                                         if let value = dict["location"] as? String {
                                             location = value
                                         }
                                        
                                        let mwSaleOrderModel = MWSaleOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      soNumber: soNumber,
                                                                                      createdOn: createdOn,
                                                                                      customer: customer,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwSaleOrderModel)
                                        self.filterItemsListArray.append(mwSaleOrderModel)
                                    }
                                }*/
                                //,,,sbm5
//                                                self.populateSelectedSO()
                                self.saleOrderListTableView.reloadData()
                            }
                            else {
                                self.loadMoreButton.isHidden = true
                                self.loadMoreActive = false
                            }//,,,sbm2-2
                        }else {
                            self.currentPage -= 1 //,,,sbm2-2
                         
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
                //,,,sbm5
                /*
                 var path = ""
                 if self.erpUUID == "41afff72-2eac-4f2e-ab2f-9adab4323d0d" {
                    //TTRx
                    path = Bundle.main.path(forResource: "MWListSaleOrders_ttrx", ofType: "json")!
                 }else {
                    path = Bundle.main.path(forResource: "MW_list-sale-orders_odoo", ofType: "json")!
                 }
                */
                    
                let path = Bundle.main.path(forResource: "MW_list-sale-orders_odoo", ofType: "json")!
                //,,,sbm5
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    if let responseDict: NSDictionary = jsonResult as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                let dataArray = dataArr as! [[String:Any]]
                                    
//                                if self.erpName == "odoo" { //,,,sbm5
                                    for dict in dataArray {
                                        var uniqueID = ""
//                                        if let value = dict["id"] as? Int {
                                        if let value = dict["id"] as? String {
//                                            uniqueID = String(value)
                                            uniqueID = value
                                        }
                                        var soNumber = ""
                                        if let value = dict["name"] as? String {
                                            soNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        var customer = ""
                                        if let value = dict["customer"] as? String {
                                            customer = value
                                        }
                                        var location = ""
                                        if let value = dict["location"] as? String {
                                            location = value
                                        }
                                        
                                        let mwSaleOrderModel = MWSaleOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      soNumber: soNumber,
                                                                                      createdOn: createdOn,
                                                                                      customer: customer,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwSaleOrderModel)
                                        self.filterItemsListArray.append(mwSaleOrderModel)
                                    }
                                    
                                    //,,,sbm5
                                    /*
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var uniqueID = ""
//                                        if let value = dict["id"] as? Int {
                                        if let value = dict["id"] as? String {
//                                            uniqueID = String(value)
                                            uniqueID = value
                                        }
                                        var soNumber = ""
                                        if let value = dict["name"] as? String {
                                            soNumber = value
                                        }
                                        var createdOn = ""
                                        if let value = dict["created_on"] as? String {
                                            createdOn = value
                                        }
                                        var customer = ""
                                        if let value = dict["customer"] as? String {
                                            customer = value
                                        }
                                        var location = ""
                                        if let value = dict["location"] as? String {
                                            location = value
                                        }
                                        
                                        let mwSaleOrderModel = MWSaleOrderModel(erpUUID: self.erpUUID,
                                                                                      erpName: self.erpName,
                                                                                      uniqueID: uniqueID,
                                                                                      soNumber: soNumber,
                                                                                      createdOn: createdOn,
                                                                                      customer: customer,
                                                                                      location: location)
                                        
                                        self.itemsListArray.append(mwSaleOrderModel)
                                        self.filterItemsListArray.append(mwSaleOrderModel)
                                    }
                                }*/
                                //,,,sbm5
    //                                                self.populateSelectedSO()
                                self.saleOrderListTableView.reloadData()
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
                self.currentPage -= 1 //,,,sbm2-2
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
        
        let filteredArray = self.itemsListArray.filter { $0.soNumber!.localizedCaseInsensitiveContains(searchStr!) }
        if filteredArray.count>0 {
            filterItemsListArray = filteredArray
        }
        else {
            filterItemsListArray = []
            if searchStr == "" {
                filterItemsListArray = itemsListArray
            }
        }
        saleOrderListTableView.reloadData()
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

//MARK: - MWPickingSelectionViewControllerDelegate
extension MWSaleOrderListViewController: MWPickingSelectionViewControllerDelegate {
    func didClickOnCamera(){
        //,,,sbm2 temp
        /*
        if(defaults.bool(forKey: "IsMultiScan")){
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWMultiScanViewController") as! MWMultiScanViewController
            controller.isForPickingSerialVerificationScan = true
            controller.isForPickingScanOption = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWSingleScanViewController") as! MWSingleScanViewController
            controller.delegate = self
            controller.isForPickingSerialVerificationScan = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        */
        
        self.didSingleScanCodeForReceiveSerialVerification(scannedCode: [])
        //,,,sbm2 temp
    }
    
    func didClickManually(){
        let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingManuallyViewController") as! MWPickingManuallyViewController
        controller.flowType = "directManualLot"
        controller.selectedSaleOrderDict = self.selectedSaleOrderDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func didClickCrossButton() {
    }
}
//MARK: - End


//MARK: - MWMultiScanViewControllerDelegate
extension MWSaleOrderListViewController : MWMultiScanViewControllerDelegate {
    
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
extension MWSaleOrderListViewController : MWSingleScanViewControllerDelegate {
    
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
        
        //,,,sbm2 temp
        
        //Local Data
        //,,,sbm5
        var scanProductArray:[[String: Any]] = []
        if self.selectedSaleOrderDict?.erpName == "odoo" {
             scanProductArray = Utility.createSampleScanProduct()//,,,sbm2 temp
        }else {
             scanProductArray = Utility.createSampleScanProduct_TTRX()//,,,sbm2 temp
        }
        //,,,sbm5
        
        //,,,sbm4
        for scanProductDict in scanProductArray {
            var gtin = ""
            var indicator = ""
            var serial = ""
            var lot = ""
            var year = ""
            var day = ""
            var month = ""
            
            if (scanProductDict.keys.contains("00")) {
                /*if let cSerial = scanProductDict["00"]?["value"] as? String{
                    //containerSerialNumber = cSerial
                }else if let cSerial = scanProductDict["00"]?["value"] as? NSNumber{
                    //containerSerialNumber = "\(cSerial)"
                }*/
            }
            else {
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
                
                //,,,sbm2-1
                var product_tracking = "serial"
                if serial == "" {
                    product_tracking = "lot"
                }
                //,,,sbm2-1
                
                //,,,sbm2-1
                if product_tracking == "serial" {
                    do{
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
                        let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
                        //,,,sbm5

                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
                            let obj = MW_PickingScanProduct(context: PersistenceService.context)
                            obj.id = MWPickingScanProduct.getAutoIncrementId()
                            obj.erp_uuid = self.selectedSaleOrderDict?.erpUUID
                            obj.erp_name = self.selectedSaleOrderDict?.erpName
                            obj.so_number = self.selectedSaleOrderDict?.soNumber
                            obj.so_unique_id = self.selectedSaleOrderDict?.uniqueID
                            obj.gtin = gtin
                            obj.indicator = indicator
                            obj.serial_number = serial
                            obj.day = day
                            obj.month = month
                            obj.year = year
                            obj.lot_number = lot
                            obj.product_tracking = product_tracking //,,,sbm2-1
                            obj.quantity = "1" //,,,sbm2-1
                            PersistenceService.saveContext()
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }
                else {
                    do{
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        //,,,sbm5

                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
                            let obj = MW_PickingScanProduct(context: PersistenceService.context)
                            obj.id = MWPickingScanProduct.getAutoIncrementId()
                            obj.erp_uuid = self.selectedSaleOrderDict?.erpUUID
                            obj.erp_name = self.selectedSaleOrderDict?.erpName
                            obj.so_number = self.selectedSaleOrderDict?.soNumber
                            obj.so_unique_id = self.selectedSaleOrderDict?.uniqueID
                            obj.gtin = gtin
                            obj.indicator = indicator
                            obj.serial_number = serial
                            obj.day = day
                            obj.month = month
                            obj.year = year
                            obj.lot_number = lot
                            obj.product_tracking = product_tracking //,,,sbm2-1
                            obj.quantity = "1" //,,,sbm2-1
                            PersistenceService.saveContext()
                        }
                        else {
                            if let obj = fetchRequestResultArray.first {
                                let qtyInt = Int(obj.quantity!)
                                obj.quantity = String(qtyInt! + 1)
                                PersistenceService.saveContext()
                            } //,,,sbm2-1
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }
                //,,,sbm2-1
            }
        }
        //,,,sbm4
        
        if scanProductArray.count > 0 {
            let storyboard = UIStoryboard(name: "MWPicking", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSerialListViewController") as! MWPickingSerialListViewController
            controller.flowType = "directSerialScan"
            controller.selectedSaleOrderDict = self.selectedSaleOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func backFromSingleScan() {
    }
}
//MARK: - End

//MARK: - Tableview Delegate and Datasource
extension MWSaleOrderListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterItemsListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaleOrderListTableCell") as! SaleOrderListTableCell
        
        cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "959596"), cornerRadious: 0)
        cell.viewItemsButton.setBorder(width: 1, borderColor: (cell.viewItemsButton.titleLabel?.textColor)!, cornerRadious: 2)
        
        if let item = filterItemsListArray[indexPath.section] as MWSaleOrderModel? {

            cell.checkUncheckRadioButton.isSelected = false
            if selectedSaleOrderDict != nil {
                if let uuid = selectedSaleOrderDict?.uniqueID as? String , !uuid.isEmpty {
                    if uuid == item.uniqueID {
                        cell.checkUncheckRadioButton.isSelected = true
                    }
                }
            }
          
            cell.soNbrLabel.text = item.soNumber
            cell.customerLabel.text = item.customer
            cell.locationLabel.text = item.location
            
            if self.erpName == "odoo" {
                cell.createdOnLabel.text = item.createdOn
            }
            else if self.erpName == "ttrx" {
//                if let date = item.createdOn {
//                    if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd HH:mm:ss.SSSSSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: date){
//                        cell.createdOnLabel.text = formattedDate
//                    }
//                }
                cell.createdOnLabel.text = item.createdOn
            }
        }
        
        cell.viewItemsButton.tag = indexPath.section
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedSaleOrderDict = filterItemsListArray[indexPath.section]
        saleOrderListTableView.reloadData()

        MWPicking.removeAllMW_PickingEntityDataFromDB()//,,,sbm4
    }
}
//MARK: - End

//MARK: - Tableview Cell
class SaleOrderListTableCell: UITableViewCell {
    @IBOutlet weak var soNbrLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var checkUncheckRadioButton: UIButton!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        soNbrLabel.text = ""
        createdOnLabel.text = ""
        customerLabel.text = ""
        locationLabel.text = ""
        
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End

//MARK: - Model
struct MWSaleOrderModel {
    var erpUUID : String!
    var erpName : String!
    
    var uniqueID: String!
    var soNumber: String!
    var createdOn: String!
    var customer: String!
    var location: String!
}

struct MWPickingScanProductModel {
    var primaryID : Int16!
    var erpUUID : String!
    var erpName : String!
    var soUniqueID: String!
    var soNumber : String!
    
    var GTIN: String!
    var indicator: String!
    var serialNumber: String!
    var day: String!
    var month: String!
    var year: String!
    var lotNumber: String!
    var productTracking: String!//,,,sbm2-1
    var quantity: String!//,,,sbm2-1
}
//MARK: - End
