//
//  MWReceivingSummaryOfMappedLotsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 14/09/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

class MWReceivingSummaryOfMappedLotsViewController: BaseViewController {
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var poNumberButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var selectedPuchaseOrderDict: MWPuchaseOrderModel?
    var selectedLineItemsListArray : [MWViewItemsModel] = []
    var selectedItemsListArray : [[MWReceivingManuallyLotOrScanSerialBaseModel]] = []

    //MARK: - IBAction
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        self.showConfirmationViewController(confirmationMsg: "Are you sure to submit?".localized(), alertStatus: "Alert1")
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is MWPuchaseOrderListViewController {
                    self.navigationController?.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
    }
    //MARK: - End
    
    //MARK: - IBAction
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        cancelButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "276A44"), cornerRadious: cancelButton.frame.height/2)
        submitButton.setBorder(width: 1, borderColor: UIColor.white, cornerRadious: submitButton.frame.height/2)

        poNumberButton.backgroundColor = UIColor.clear
        poNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
        poNumberButton.setTitle("PO: \(selectedPuchaseOrderDict?.poNumber ?? "")", for: UIControl.State.normal)
        
        // NON EDITED
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format: "erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == false")
            let predicate = NSPredicate(format: "po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == false")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if !fetchRequestResultArray.isEmpty {
                fetchRequestResultArray.forEach({ (cdModel) in
                    selectedLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }else{
                selectedLineItemsListArray = []
            }
        }catch let error{
            print(error.localizedDescription)
            selectedLineItemsListArray = []
        }
        
        /**=============================================================**/
        
        
        //SERIAL
        var selectedSerialLineItemsListArray : [MWViewItemsModel] = []
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format: "erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='serial'")
            let predicate = NSPredicate(format: "po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='serial'")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if !fetchRequestResultArray.isEmpty {
                fetchRequestResultArray.forEach({ (cdModel) in
                    selectedSerialLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }else{
                selectedSerialLineItemsListArray = []
            }
        }catch let error{
            print(error.localizedDescription)
            selectedSerialLineItemsListArray = []
        }
        
        var filterSerialItemsListArray : [[MWReceivingManuallyLotOrScanSerialBaseModel]] = []//,,,sbm2
        for lineItemModel in selectedSerialLineItemsListArray {
            var arr : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format: "erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='serial' and product_code='\(lineItemModel.productCode!)'")
                let predicate = NSPredicate(format: "po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='serial' and product_code='\(lineItemModel.productCode!)'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if !fetchRequestResultArray.isEmpty {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        arr.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                    })
                }else{
                    arr = []
                }
            }catch let error{
                print(error.localizedDescription)
                arr = []
            }
            
            filterSerialItemsListArray.append(arr)
        }
        
        /**=============================================================**/
        
        
        //LOT
        var selectedLotLineItemsListArray : [MWViewItemsModel] = []
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format: "erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='lot'")
            let predicate = NSPredicate(format: "po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='lot'")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if !fetchRequestResultArray.isEmpty {
                fetchRequestResultArray.forEach({ (cdModel) in
                    selectedLotLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }else{
                selectedLotLineItemsListArray = []
            }
        }catch let error{
            print(error.localizedDescription)
            selectedLotLineItemsListArray = []
        }
        
        var filterLotItemsListArray : [[MWReceivingManuallyLotOrScanSerialBaseModel]] = []//,,,sbm2
        for lineItemModel in selectedLotLineItemsListArray {
            var arr : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format: "erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='lot' and product_code='\(lineItemModel.productCode!)'")
                let predicate = NSPredicate(format: "po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited == true and product_tracking='lot' and product_code='\(lineItemModel.productCode!)'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if !fetchRequestResultArray.isEmpty {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        arr.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                    })
                }else{
                    arr = []
                }
            }catch let error{
                print(error.localizedDescription)
                arr = []
            }
            
            filterLotItemsListArray.append(arr)
        }
        
        /**=============================================================**/
                
        var productTrackingArray:[String] = []
        for i in 0..<filterSerialItemsListArray.count {
            let productsModelArray = filterSerialItemsListArray[i]
            if productsModelArray.count > 0 {
                productTrackingArray.append("serial")
                selectedItemsListArray.append(productsModelArray)
            }
        }
        
        for i in 0..<filterLotItemsListArray.count {
            let productsModelArray = filterLotItemsListArray[i]
            if productsModelArray.count > 0 {
                productTrackingArray.append("lot")
                selectedItemsListArray.append(productsModelArray)
            }
        }
        
        if productTrackingArray.contains("lot") && productTrackingArray.contains("serial") {
            headerButton.setTitle("Summary Of Mapped Lots and Serials".localized(), for: UIControl.State.normal)
        }else if productTrackingArray.contains("lot") {
            headerButton.setTitle("Summary Of Mapped Lots".localized(), for: UIControl.State.normal)
        }else if productTrackingArray.contains("serial") {
            headerButton.setTitle("Summary Of Mapped Serials".localized(), for: UIControl.State.normal)
        }
        
        
        let headerNib = UINib.init(nibName: "MWReceivingSummaryLotHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "MWReceivingSummaryLotHeaderView")
        listTable.reloadData()
    }
    //MARK: - End
    
    //MARK: - Webservice call
    func purchaseOrderReceivingWebServiceCall() {
        /*
         Receiving By Purchase Order
         185eb551-cb71-4d11-bfa3-31693d06163f
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/purchase-order-receiving
         
        POST
         {
                 "action_uuid": "185eb551-cb71-4d11-bfa3-31693d06163f",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_name": "P00176",
                 "po_id": "184",
                 "line_items": "[{\"product_code\": \"1000000005\", \"product_name\": \"SEP05 LOT Product 4\", \"product_id\": \"1403\", \"product_tracking\": \"lot\", \"ordered_qty\": 5, \"quantity\": 3, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-15\", \"quantity\": 3, \"is_container\": false, \"c_serial\": \"\", \"c_gs1_serial\": \"\", \"c_gs1_barcode\": \"\", \"p_serials\": [], \"p_gs1_serials\": [], \"p_gs1_barcodes\": []}]}, {\"product_code\": \"1000000006\", \"product_name\": \"SEP05 SERIAL Product 4\", \"product_id\": \"1404\", \"product_tracking\": \"serial\", \"ordered_qty\": 5, \"quantity\": 2, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-16\", \"quantity\": 2, \"is_container\": false, \"c_serial\": \"\", \"c_gs1_serial\": \"\", \"c_gs1_barcode\": \"\", \"p_serials\": [\"SEP05-SERIAL-P2-15\", \"SEP05-SERIAL-P2-16\"], \"p_gs1_serials\": [], \"p_gs1_barcodes\": []}]}]"
         }
        */
        
        
        /*
         new
         {
                 "action_uuid": "185eb551-cb71-4d11-bfa3-31693d06163f",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_name": "P00176",
                 "po_id": "184",
                 "line_items": "[{\"product_code\": \"1000000005\", \"product_name\": \"SEP05 LOT Product 4\", \"product_id\": \"1403\", \"product_tracking\": \"lot\", \"ordered_qty\": 5, \"quantity\": 3, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-15\", \"quantity\": 3, \"is_container\": false, \"c_serial\": \"\", \"c_gtin\": \"\" \"p_serials\": [], \"p_gtins\": []}]}, {\"product_code\": \"1000000006\", \"product_name\": \"SEP05 SERIAL Product 4\", \"product_id\": \"1404\", \"product_tracking\": \"serial\", \"ordered_qty\": 5, \"quantity\": 2, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-16\", \"quantity\": 2, \"is_container\": false, \"c_serial\": \"\", \"c_gtin\": \"\", \"p_serials\": [\"SEP05-SERIAL-P2-15\", \"SEP05-SERIAL-P2-16\"], \"p_gtins\": []}]}]"
         }
         
         */
        
        
        /*
         latest
         {
                 "action_uuid": "185eb551-cb71-4d11-bfa3-31693d06163f",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_name": "P00176",
                 "po_id": "184",
                 "line_items": "[{\"product_code\": \"1000000005\", \"product_name\": \"SEP05 LOT Product 4\", \"product_id\": \"1403\", \"product_tracking\": \"lot\", \"ordered_qty\": 5, \"quantity\": 3, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-15\", \"quantity\": 3, \"is_container\": false, \"c_serial\": \"\", \"c_gtin\": \"\" \"p_serials\": []}]}, {\"product_code\": \"1000000006\", \"product_name\": \"SEP05 SERIAL Product 4\", \"product_id\": \"1404\", \"product_tracking\": \"serial\", \"ordered_qty\": 5, \"quantity\": 2, \"lots\": [{\"lot_number\": \"SEP05-LOT-P2-16\", \"quantity\": 2, \"is_container\": false, \"c_serial\": \"\", \"c_gtin\": \"\", \"p_serials\": [\"SEP05-SERIAL-P2-15\", \"SEP05-SERIAL-P2-16\"]}]}]"
         }
         */
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"purchaseOrderReceiving")
        requestDict["sub"] = defaults.object(forKey:"sub")
        if selectedItemsListArray.count > 0 {
            var arr = [[String:Any]]()
            for i in 0..<selectedItemsListArray.count {
                let productsModelArray = selectedItemsListArray[i]
                
                var dict1:[String:Any] = [:]
                var arr1 = [[String:Any]]()
                
                for j in 0..<productsModelArray.count {
                    let productsModel = productsModelArray[j]
                    if i == 0 && j == 0 {
                        if let erpUUID = productsModel.erpUUID {
                            requestDict["source_erp"] = erpUUID
                        }
                        if let poNumber = productsModel.poNumber {
                            requestDict["po_name"] = poNumber
                        }
                        if let poUniqueID = productsModel.poUniqueID {
                            requestDict["po_id"] = poUniqueID
                        }
                    }
                    
                    let productTracking = productsModel.productTracking
                    if productTracking == "lot" {
                        if j == 0 {
                            if productsModelArray.count > 0 {
                                if let productCode = productsModel.productCode {
                                    dict1["product_code"] = productCode
                                }
                                if let productName = productsModel.productName {
                                    dict1["product_name"] = productName
                                }
                                if let productUniqueID = productsModel.productUniqueID {
                                    dict1["product_id"] = productUniqueID
                                }
                                if let productTracking = productsModel.productTracking {
                                    dict1["product_tracking"] = productTracking
                                }
                                if let productDemandQuantity = productsModel.productDemandQuantity {
                                    dict1["ordered_qty"] = productDemandQuantity
                                }
                                let qtyArray = productsModelArray.map { $0.quantity }
                                var qtyAmount:Int = 0
                                for qty in qtyArray {
                                    if let qtyStr = qty {
                                        qtyAmount = qtyAmount + (Int(qtyStr) ?? 0)
                                    }
                                }
                                dict1["quantity"] = String(qtyAmount)
                            }
                        }
                       
                        var dict2:[String:Any] = [:]
                        if let lotNumber = productsModel.lotNumber {
                            dict2["lot_number"] = lotNumber
                        }
                        if let quantity = productsModel.quantity {
                            if quantity == "" {
                                dict2["quantity"] = "0"
                            }else {
                                dict2["quantity"] = quantity
                            }
                        }
                        if let isContainer = productsModel.isContainer {
                            dict2["is_container"] = isContainer
                        }
                        if let cSerial = productsModel.cSerial {
                            dict2["c_serial"] = cSerial
                        }
                        if let cGtin = productsModel.cGtin {
                            dict2["c_gtin"] = cGtin
                        }
                        if let pSerials = productsModel.pSerials {
                            dict2["p_serials"] = pSerials
                        }
                        arr1.append(dict2)
                    }
                    else {
                        //serial
                        if !arr1.contains(where: {$0["lot_number"] as? String == productsModel.lotNumber}) {
                            
                            if j == 0 {
                                if productsModelArray.count > 0 {
                                    if let productCode = productsModel.productCode {
                                        dict1["product_code"] = productCode
                                    }
                                    if let productName = productsModel.productName {
                                        dict1["product_name"] = productName
                                    }
                                    if let productUniqueID = productsModel.productUniqueID {
                                        dict1["product_id"] = productUniqueID
                                    }
                                    if let productTracking = productsModel.productTracking {
                                        dict1["product_tracking"] = productTracking
                                    }
                                    if let productDemandQuantity = productsModel.productDemandQuantity {
                                        dict1["ordered_qty"] = productDemandQuantity
                                    }
                                    
                                    let serialNumberArray = productsModelArray.map { $0.serialNumber }
                                    let qtyAmount:Int = serialNumberArray.count
                                    dict1["quantity"] = String(qtyAmount)
                                }
                            }
                           
                            var dict2:[String:Any] = [:]
                            var lotNo = ""
                            if let lotNumber = productsModel.lotNumber {
                                dict2["lot_number"] = lotNumber
                                lotNo = lotNumber
                            }
                            let lotNumberFilteredArray = productsModelArray.filter { $0.lotNumber!.localizedCaseInsensitiveContains(lotNo) }
                            let lotserialNumberArray = lotNumberFilteredArray.map { $0.serialNumber }
                            
                            dict2["p_serials"] = lotserialNumberArray
                            dict2["quantity"] = String(lotNumberFilteredArray.count)

                            if let isContainer = productsModel.isContainer {
                                dict2["is_container"] = isContainer
                            }
                            if let cSerial = productsModel.cSerial {
                                dict2["c_serial"] = cSerial
                            }
                            if let cGtin = productsModel.cGtin {
                                dict2["c_gtin"] = cGtin
                            }
                            arr1.append(dict2)
                        }
                    }
                }
                
                dict1["lots"] = arr1
                arr.append(dict1)
            }
//            print("arr...",arr)
            
            for i in 0..<selectedLineItemsListArray.count {
                let lineItemModel = selectedLineItemsListArray[i]
                let productCode = lineItemModel.productCode
                let productName = lineItemModel.productName
                let productUniqueID = lineItemModel.productUniqueID
                let productTracking = lineItemModel.productTracking
                
                let filteredArray = arr.filter { $0["product_code"] as? String == productCode && $0["product_id"] as? String == productUniqueID && $0["product_tracking"] as? String == productTracking && $0["product_name"] as? String == productName}
                if filteredArray.count == 0 {
                    var dict1:[String:Any] = [:]
                    var arr1 = [[String:Any]]()
                    if let productCode = lineItemModel.productCode {
                        dict1["product_code"] = productCode
                    }
                    if let productName = lineItemModel.productName {
                        dict1["product_name"] = productName
                    }
                    if let productUniqueID = lineItemModel.productUniqueID {
                        dict1["product_id"] = productUniqueID
                    }
                    if let productTracking = lineItemModel.productTracking {
                        dict1["product_tracking"] = productTracking
                    }
                    if let productDemandQuantity = lineItemModel.productDemandQuantity {
                        dict1["ordered_qty"] = productDemandQuantity
                    }
                    dict1["quantity"] = "0"
                    
                    var dict2:[String:Any] = [:]
                    dict2["lot_number"] = ""
                    dict2["quantity"] = "0"
                    dict2["c_serial"] = ""
                    dict2["c_gtin"] = ""
                    dict2["p_serials"] = []
                    dict2["is_container"] = false
                    arr1.append(dict2)
                    dict1["lots"] = arr1
                    arr.append(dict1)
                }
            }
            requestDict["line_items"] = Utility.json(from: arr)
        }
        
        print("requestDict...",requestDict)
        
        //,,,sbm2-2
        /*
        //old response
        {
                "status_code": 1,
                "status": "success",
                "message": "Middleware execution successful.",
                "data": "{\"f6cd53e9-ebc6-4aad-820d-117c52cec266\": {\"status_code\": 1, \"status\": \"success\", \"message\": \"Successfully executed.\", \"data\": {}}, \"41afff72-2eac-4f2e-ab2f-9adab4323d0d\": {\"status_code\": 1, \"status\": \"success\", \"message\": \"Successfully executed.\", \"data\": {\"uuid\": \"7a7c0322-cffd-4e9b-9403-77a277273815\", \"queue_url\": \"https://api.pre-test.tracktraceweb.com/2.0/queue/946b9e4a-972a-4487-a3a2-095810da6b4c\", \"queue_uuid\": \"946b9e4a-972a-4487-a3a2-095810da6b4c\"}}}"
        }
        
        //new response
        Response Data: Optional({
            data = "{\"tracking_uuid\": \"fd0f33e4-faa2-4580-b50c-ae6e9d8ccd4a\"}";
            message = "The execution is in progress! You need to check the status later.";
            status = success;
            "status_code" = 1;
        })
        */
        //,,,sbm2-2
        
        //,,,sbm0 temp
    
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "PurchaseOrderReceiving", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        if statusCode! {
                            
                            //,,,sbm2-2
                            //######//
                            let message = responseDict["message"] as! String
                            Utility.showPopupWithAction(Title: Success_Title, Message: message, InViewC: self, action:{
                                if let viewControllers = self.navigationController?.viewControllers {
                                    for viewController in viewControllers {
                                        if viewController is DashboardViewController {
                                             MWReceiving.removeAllMW_ReceivingEntityDataFromDB()//,,,sbm2
                                            self.navigationController?.popToViewController(viewController, animated: true)
                                            return
                                        }
                                    }
                                }
                            })
                            //######//
                            
                            
                            
                            /*
                            if let dataDict = Utility.convertToDictionary(text: responseDict["data"] as! String) {
//                                print("dataDict.....?????",dataDict)
                                
                                let erpUUID = MWStaticData.ERP_UUID.odoo.rawValue //odoo
                                if let erpDict = dataDict [erpUUID] as? NSDictionary {
                                    let status_Code = erpDict["status_code"] as? Bool
                                    if status_Code! {
                                        
                                        //######//
                                        let message = erpDict["message"] as! String
                                        Utility.showPopupWithAction(Title: Success_Title, Message: message, InViewC: self, action:{
                                            if let viewControllers = self.navigationController?.viewControllers {
                                                for viewController in viewControllers {
                                                    if viewController is DashboardViewController {
                                                         MWReceiving.removeAllMW_ReceivingEntityDataFromDB()//,,,sbm2
                                                        self.navigationController?.popToViewController(viewController, animated: true)
                                                        return
                                                    }
                                                }
                                            }
                                        })
                                        //######//
                                    }
                                    else {
                                        if let errorMsg = erpDict["message"] as? String {
                                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                                        }
                                        else {
                                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                                        }
                                    }
                                }
                            }
                            else {
                                Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }*/
                            //,,,sbm2-2
                        }else {
                            if let errorMsg = responseDict["message"] as? String {
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            }
                            else {
                                Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }
                        }
                    }else {
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }else {
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                    }
                    else {
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
       
        //,,,sbm0 temp
    }
    //MARK: - End
}

// MARK: - MWConfirmationView
extension MWReceivingSummaryOfMappedLotsViewController: MWConfirmationViewDelegate {
    func showConfirmationViewController(confirmationMsg:String, alertStatus:String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MWConfirmationViewController") as! MWConfirmationViewController
        controller.confirmationMsg = confirmationMsg
        controller.alertStatus = alertStatus
        controller.isCancelButtonShow = true

        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - MWConfirmationViewDelegate
    func doneButtonPressed(alertStatus:String) {
        self.purchaseOrderReceivingWebServiceCall()
    }
    func cancelButtonPressed(alertStatus:String) {
    }
    //MARK: - End
}
// MARK: - End

extension MWReceivingSummaryOfMappedLotsViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 92
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MWReceivingSummaryLotHeaderView") as! MWReceivingSummaryLotHeaderView
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = 15
        headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        let backgroundView = UIView(frame: headerView.bounds)
        backgroundView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
        headerView.backgroundView = backgroundView
        
        let productsModelArray = selectedItemsListArray[section]
        if productsModelArray.count > 0 {
            let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[0]
            
            headerView.productNameLabel.text = ""
            if let productName = productsModel.productName {
                headerView.productNameLabel.text = productName
            }
            
            headerView.productTrackingLabel.text = ""
            if let productTracking = productsModel.productTracking {
                headerView.productTrackingLabel.text = "Type:".localized() + "  " + productTracking
            }
                    
            var demandQty = 0
            var productDemandQuantityStr = ""
            if let val = productsModel.productDemandQuantity {
                productDemandQuantityStr = val
            }

            if productDemandQuantityStr.contains(".") {
                if let demandQtyDouble = Double(productDemandQuantityStr) {
                    demandQty = Int(demandQtyDouble)
                }
            }else {
                if let demandQtyInt = Int(productDemandQuantityStr) {
                    demandQty = demandQtyInt
                }
            }
            headerView.demandQuantityLabel.text = "Demand Qty:".localized() + "  " + String(demandQty)
            
            var productReceivedQty = 0
            var productReceivedQuantityStr = ""
            if let val = productsModel.productReceivedQuantity {
                productReceivedQuantityStr = val
            }

            if productReceivedQuantityStr.contains(".") {
                if let productReceivedQtyDouble = Double(productReceivedQuantityStr) {
                    productReceivedQty = Int(productReceivedQtyDouble)
                }
            }else {
                if let productReceivedQtyInt = Int(productReceivedQuantityStr) {
                    productReceivedQty = productReceivedQtyInt
                }
            }
            headerView.alreadyReceivedQuantityLabel.text = "Already Received Qty:".localized() + "  " + String(productReceivedQty)
            
            let quantityToReceive = demandQty - productReceivedQty
            headerView.quantityToReceiveLabel.text = "Qty to be Received:".localized() + "  " + String(quantityToReceive)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return selectedItemsListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productsModelArray = selectedItemsListArray[section]
        return productsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productsModelArray = selectedItemsListArray[indexPath.section]
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[indexPath.row]
        
        var productTracking = ""
        if let val = productsModel.productTracking {
            productTracking = val
        }
        
        if productTracking == "lot" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MWReceivingSummaryLotTableViewCell") as! MWReceivingSummaryLotTableViewCell
            cell.bulletButton.setBorder(width: 1, borderColor: cell.bulletButton.backgroundColor!, cornerRadious: cell.bulletButton.frame.height/2)
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") //E8EEE6
            
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 0
            
            if let lotNumber = productsModel.lotNumber {
                cell.lotNumberLabel.text = "Lot #:".localized() + " " + lotNumber
            }
            if let quantity = productsModel.quantity {
                cell.quantityLabel.text = "Qty:".localized() + " " + quantity
            }
            
            if indexPath.row == productsModelArray.count-1 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MWReceivingSummaryTableViewCell") as! MWReceivingSummaryTableViewCell
            cell.bulletButton.setBorder(width: 1, borderColor: cell.bulletButton.backgroundColor!, cornerRadious: cell.bulletButton.frame.height/2)
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") //E8EEE6
            
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 0
            
            if let serialNO = productsModel.serialNumber {
                cell.serialNumberLabel.text = "Serial #:".localized() + " " + serialNO
            }
            if let lotNumber = productsModel.lotNumber {
                cell.lotNumberLabel.text = "Lot #:".localized() + " " + lotNumber
            }
            
            if indexPath.row == productsModelArray.count-1 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }
    }
    //MARK: - End
}

class MWReceivingSummaryLotTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bulletButton: UIButton!
    @IBOutlet weak var lotNumberLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class MWReceivingSummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bulletButton: UIButton!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var lotNumberLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
