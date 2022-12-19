//
//  MWReceivingManuallyViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 18/08/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1 unused

import UIKit

class MWReceivingManuallyViewController: BaseViewController {
    @IBOutlet weak var poNumberButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var serialExistLabel: UILabel!
    
    var flowType: String = "" //"directManualLot", "viaSerialScan"

    var selectedPuchaseOrderDict: MWPuchaseOrderModel?
    var selectedLineItemsListArray : [MWViewItemsModel] = []
    
    var filterLotHeaderListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
    var filterLotItemsListArray : [[MWReceivingManuallyLotOrScanSerialBaseModel]] = []
    
    var filterSerialLineItemsArray : [MWViewItemsModel] = [] //,,,sbm2

    var showSerialAlert = true

    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        self.createInputAccessoryView()

        poNumberButton.backgroundColor = UIColor.clear
        poNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
        poNumberButton.setTitle("PO: \(selectedPuchaseOrderDict?.poNumber ?? "")", for: UIControl.State.normal)
        
        let headerNib = UINib.init(nibName: "MWReceivingManuallyHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "MWReceivingManuallyHeaderView")
        
        serialExistLabel.isHidden = true
        self.listLineItemsByPurchaseOrderWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func getDBData() {
        //,,,sbm2
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                selectedLineItemsListArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    selectedLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            selectedLineItemsListArray = []
        }
        //,,,sbm2
        
        
        
        
        for model in selectedLineItemsListArray {
            var productsModelArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
            
            var erpUUID = ""
            if let val = model.erpUUID {
                erpUUID = val
            }
            var erpName = ""
            if let val = model.erpName {
                erpName = val
            }
            var poNumber = ""
            if let val = model.poNumber {
                poNumber = val
            }
            var poUniqueID = ""
            if let val = model.poUniqueID {
                poUniqueID = val
            }
            var productUniqueID = ""
            if let val = model.productUniqueID {
                productUniqueID = val
            }
            var productName = ""
            if let val = model.productName {
                productName = val
            }
            var productCode = ""
            if let val = model.productCode {
                productCode = val
            }
            var productReceivedQuantity = ""
            if let val = model.productReceivedQuantity {
                productReceivedQuantity = val
            }
            var productDemandQuantity = ""
            if let val = model.productDemandQuantity {
                productDemandQuantity = val
            }
            var productQtyToReceive = ""
            if let val = model.productQtyToReceive {
                productQtyToReceive = val
            }
            var productTracking = ""
            if let val = model.productTracking {
                productTracking = val
            }
            var productUomID = ""
            if let val = model.productUomID {
                productUomID = val
            }
            
            let mwReceivingManuallyLotOrScanSerialBaseModel = MWReceivingManuallyLotOrScanSerialBaseModel(erpUUID: erpUUID,
                                                                                  erpName: erpName,
                                                                                  poNumber: poNumber,
                                                                                  poUniqueID: poUniqueID,
                                                                                  productUniqueID: productUniqueID,
                                                                                  productName: productName,
                                                                                  productCode: productCode,
                                                                                  productReceivedQuantity: productReceivedQuantity,
                                                                                  productDemandQuantity: productDemandQuantity,
                                                                                  productQtyToReceive: productQtyToReceive,
                                                                                  productTracking: productTracking,
                                                                                  productUomID: productUomID,
                                                                                  lotNumber: "",
                                                                                  quantity: "",
                                                                                  isContainer: false,
                                                                                  cSerial: "",
                                                                                  cGtin: "",
                                                                                  pSerials: [],
                                                                                  pGtins: [],
                                                                                  serialNumber: "",
                                                                                  isEdited: false)
            productsModelArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
            
            if productTracking == "lot" {
                //,,,sbm2
                do{
                    let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(productCode)' and product_tracking='lot'")
                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                    if fetchRequestResultArray.isEmpty {
                        let obj = MW_ReceivingManualLotOrScanSerial(context: PersistenceService.context)
                        obj.id = MWReceivingManualLotOrScanSerial.getAutoIncrementId()
                        obj.erp_uuid = erpUUID
                        obj.erp_name = erpName
                        obj.po_number = poNumber
                        obj.po_unique_id = poUniqueID
                        obj.product_unique_id = productUniqueID
                        obj.product_name = productName
                        obj.product_code = productCode
                        obj.product_received_qty = productReceivedQuantity
                        obj.product_demand_qty = productDemandQuantity
                        obj.product_qty_to_receive = productQtyToReceive
                        obj.product_tracking = productTracking
                        obj.product_uom_id = productUomID
                        obj.lot_number = ""
                        obj.quantity = ""
                        obj.is_container = false
                        obj.c_serial = ""
                        obj.c_gtin = ""
                        obj.p_serials = Utility.json(from: [])
                        obj.p_gtins = Utility.json(from: [])
                        obj.serial_number = ""
                        obj.is_edited = false
                        
                        PersistenceService.saveContext()
                        
                        filterLotHeaderListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
                        filterLotItemsListArray.append([])
                    }
                    else {
                        filterLotHeaderListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
                        
                        var arr : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
                        fetchRequestResultArray.forEach({ (cdModel) in
                            if cdModel.is_edited == true {
                                arr.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                            }
                        })
                        filterLotItemsListArray.append(arr)
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                //,,,sbm2
            }else if productTracking == "serial" {
            }
        }
        
        if flowType == "directManualLot" {
            //,,,sbm2
            serialExistLabel.isHidden = true
            do{
                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='serial'")

                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                if !fetchRequestResultArray.isEmpty {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        filterSerialLineItemsArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                    })
                    
                    serialExistLabel.isHidden = false
                    serialExistLabel.text = "\(fetchRequestResultArray.count) serial exist in this Purchase Order"
                }
            }catch let error{
                print(error.localizedDescription)
            }
            //,,,sbm2
        }else {
            serialExistLabel.isHidden = true
        }
        
        
        listTable.reloadData()
    }
    //MARK: - End
    
    //MARK: - WebserviceCall
    /*
    func listLineItemsByPurchaseOrderWebServiceCall(via:String) {
        /*
         List Line Items By Purchase Order
         4032b2bb-3b29-4fe1-b384-4a76b30101eb
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-line-items-by-purchase-order
         
        POST
         {
                 "action_uuid": "4032b2bb-3b29-4fe1-b384-4a76b30101eb",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_id": "184"
         }
        */
        
        /*
         Response Data: Optional({
             data = "[{\"product_id\": \"1405\", \"product_code\": \"00303160123016\", \"product_name\": \"00303160123016 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1406\", \"product_code\": \"00303160123801\", \"product_name\": \"00303160123801 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1403\", \"product_code\": \"00349908118142\", \"product_name\": \"00349908118142 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1404\", \"product_code\": \"10349908118149\", \"product_name\": \"10349908118149 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}]";
             message = "Successfully executed.";
             status = success;
             "status_code" = 1;
         })
         */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsByPurchaseOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = erpUUID
        
        if self.erpName == "odoo" {
            requestDict["po_id"] = selectedPuchaseOrderDict?.uniqueID
        }
        else if self.erpName == "ttrx" {
            //requestDict["po_uuid"] = selectedPuchaseOrderDict?.uniqueID
            requestDict["po_id"] = selectedPuchaseOrderDict?.uniqueID

        }

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListLineItemsByPurchaseOrder", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
//                var selectedLineItemsListArray : [MWViewItemsModel] = [] //,,,sbm2
                
                if isDone! {
                    //,,,sbm0 temp
                    /*
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        if statusCode! {
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                let dataArray = dataArr as! [[String:Any]]
                                //                                                print("dataArray....>>>>>",dataArray)
                                if self.erpName == "odoo" {
                                    for dict in dataArray {
                                        var product_id = ""
//                                        if let value = dict["product_id"] as? Int {
                                        if let value = dict["product_id"] as? String {
//                                            product_id = String(value)
                                            product_id = value
                                        }
                                        var product_demand_quantity = ""
//                                        if let value = dict["product_demand_quantity"] as? Int {
                                        if let value = dict["product_demand_quantity"] as? String {
//                                            product_demand_quantity = String(value)
                                            product_demand_quantity = value
                                        }
                                        var product_received_quantity = ""
//                                        if let value = dict["product_received_quantity"] as? Int {
                                        if let value = dict["product_received_quantity"] as? String {
//                                            product_received_quantity = String(value)
                                            product_received_quantity = value
                                        }
                                        var product_qty_to_receive = ""
//                                        if let value = dict["product_qty_to_receive"] as? Int {
                                        if let value = dict["product_qty_to_receive"] as? String {
//                                            product_qty_to_receive = String(value)
                                            product_qty_to_receive = value
                                        }
                                        var product_code = ""
                                        if let value = dict["product_code"] as? String {
                                            product_code = value
                                        }
                                        var product_name = ""
                                        if let value = dict["product_name"] as? String {
                                            product_name = value
                                        }
                                        var product_tracking = ""
                                        if let value = dict["product_tracking"] as? String {
                                            product_tracking = value
                                        }
                                        
                                        var product_uom_id = ""
//                                        if let value = dict["product_uom_id"] as? Int {
                                        if let value = dict["product_uom_id"] as? String {
//                                            product_uom_id = String(value)
                                            product_uom_id = value
                                        }
                                        
                                        //,,,sbm2
                                        /*
                                        let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                poNumber: self.selectedPuchaseOrderDict?.poNumber,
                                                                                poUniqueID: self.selectedPuchaseOrderDict?.uniqueID,
                                                                                productUniqueID: product_id,
                                                                                productName: product_name,
                                                                                productCode: product_code,
                                                                                productReceivedQuantity: product_received_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToReceive: product_qty_to_receive,
                                                                                productTracking: product_tracking,
                                                                                lineItemUUID: "",
                                                                                productUomID: product_uom_id)
                                        selectedLineItemsListArray.append(mwViewItemsModel)
                                        */
                     
                                        do{
                                            let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                obj.erpUUID = self.erpUUID
                                                obj.erpName = self.erpName
                                                obj.poNumber = self.selectedPuchaseOrderDict?.poNumber
                                                obj.poUniqueID = self.selectedPuchaseOrderDict?.uniqueID
                                                obj.productUniqueID = product_id
                                                obj.productName = product_name
                                                obj.productCode = product_code
                                                obj.productReceivedQuantity = product_received_quantity
                                                obj.productDemandQuantity = product_demand_quantity
                                                obj.productQtyToReceive = product_qty_to_receive
                                                obj.productTracking = product_tracking
                                                obj.lineItemUUID = ""
                                                obj.productUomID = product_uom_id
                                                obj.isEdited = false
                                                if via == "Manually" {
                                                    obj.productFlowType = "directManualLotEntry"
                                                }
                                                else {
                                                    obj.productFlowType = "directSerialScanEntry"
                                                }
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.productReceivedQuantity = product_received_quantity
                                                    obj.productDemandQuantity = product_demand_quantity
                                                    obj.productQtyToReceive = product_qty_to_receive
                                                    if via == "Manually" {
                                                        obj.productFlowType = "directManualLotEntry"
                                                    }
                                                    else {
                                                        obj.productFlowType = "directSerialScanEntry"
                                                    }
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var product_uuid = ""
                                        if let value = dict["product_uuid"] as? String {
                                            product_uuid = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_received_quantity = ""
                                        if let value = dict["product_received_quantity"] as? String {
                                            product_received_quantity = value
                                        }
                                        var product_qty_to_receive = ""
                                        if let value = dict["product_qty_to_receive"] as? Int {
                                            product_qty_to_receive = String(value)
                                        }
                                        var product_code = ""
                                        if let value = dict["product_code"] as? String {
                                            product_code = value
                                        }
                                        var product_name = ""
                                        if let value = dict["product_name"] as? String {
                                            product_name = value
                                        }
                                        var product_tracking = ""
                                        if let value = dict["product_tracking"] as? String {
                                            product_tracking = value
                                        }
                                        
                                        var line_item_uuid = ""
                                        if let value = dict["line_item_uuid"] as? String {
                                            line_item_uuid = value
                                        }
                                        
                                        //,,,sbm2
                                        /*
                                        let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                poNumber: self.selectedPuchaseOrderDict?.poNumber,
                                                                                poUniqueID: self.selectedPuchaseOrderDict?.uniqueID,
                                                                                productUniqueID: product_uuid,
                                                                                productName: product_name,
                                                                                productCode:product_code,
                                                                                productReceivedQuantity: product_received_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToReceive: product_qty_to_receive,
                                                                                productTracking: product_tracking,
                                                                                lineItemUUID: line_item_uuid,
                                                                                productUomID: "")
                                        
                                        selectedLineItemsListArray.append(mwViewItemsModel)
                                        */
                                                                                    
                                        
                                        do{
                                            let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.ttrx.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                obj.erpUUID = self.erpUUID
                                                obj.erpName = self.erpName
                                                obj.poNumber = self.selectedPuchaseOrderDict?.poNumber
                                                obj.poUniqueID = self.selectedPuchaseOrderDict?.uniqueID
                                                obj.productUniqueID = product_uuid
                                                obj.productName = product_name
                                                obj.productCode = product_code
                                                obj.productReceivedQuantity = product_received_quantity
                                                obj.productDemandQuantity = product_demand_quantity
                                                obj.productQtyToReceive = product_qty_to_receive
                                                obj.productTracking = product_tracking
                                                obj.lineItemUUID = line_item_uuid
                                                obj.productUomID = ""
                                                obj.isEdited = false
                                                if via == "Manually" {
                                                    obj.productFlowType = "directManualLotEntry"
                                                }
                                                else {
                                                    obj.productFlowType = "directSerialScanEntry"
                                                }
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.productReceivedQuantity = product_received_quantity
                                                    obj.productDemandQuantity = product_demand_quantity
                                                    obj.productQtyToReceive = product_qty_to_receive
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                }
                                
                                if via == "Manually" {
                                    let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingManuallyViewController") as! MWReceivingManuallyViewController
                                    controller.flowType = "directManualLot"
                                    // controller.selectedLineItemsListArray = selectedLineItemsListArray //,,,sbm2
                                    controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
                     
                                    // controller.filterSerialHeaderListArray = [] //,,,sbm2
                                    // controller.filterSerialItemsListArray = [] //,,,sbm2
                     
                                    self.navigationController?.pushViewController(controller, animated: true)
                                }
                                else {
                                    let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
                                     controller.flowType = "directSerialScan"
                                     controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
                                    // controller.selectedLineItemsListArray = selectedLineItemsListArray //,,,sbm2
                                    //controller.scanProductArray = self.scanProductArray
                                    // controller.filterLotHeaderListArray = [] //,,,sbm2
                                    // controller.filterLotItemsListArray = [] //,,,sbm2
                     
                                    self.navigationController?.pushViewController(controller, animated: true)
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
                    */
                    
                    
                    
                    
                    
                    var path = ""
                    if self.erpUUID == "41afff72-2eac-4f2e-ab2f-9adab4323d0d" {
                        //TTRx
                        path = Bundle.main.path(forResource: "MWListPurchaseOrders_ttrx", ofType: "json")!
                    }else {
//                        path = Bundle.main.path(forResource: "MW_list-line-items-by-purchase-order_odoo", ofType: "json")!
                        path = Bundle.main.path(forResource: "MW_list-line-items-by-purchase-order_odoo_Serial", ofType: "json")!
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
//                                                print("dataArray....>>>>>",dataArray)
                                    if self.erpName == "odoo" {
                                        for dict in dataArray {
                                            var product_id = ""
//                                        if let value = dict["product_id"] as? Int {
                                            if let value = dict["product_id"] as? String {
//                                            product_id = String(value)
                                                product_id = value
                                            }
                                            var product_demand_quantity = ""
                                            if let value = dict["product_demand_quantity"] as? String {
                                                product_demand_quantity = value
                                            }
                                            var product_received_quantity = ""
                                            if let value = dict["product_received_quantity"] as? String {
                                                product_received_quantity = value
                                            }
                                            var product_qty_to_receive = ""
                                            if let value = dict["product_qty_to_receive"] as? String {
                                                product_qty_to_receive = value
                                            }
                                            var product_code = ""
                                            if let value = dict["product_code"] as? String {
                                                product_code = value
                                            }
                                            var product_name = ""
                                            if let value = dict["product_name"] as? String {
                                                product_name = value
                                            }
                                            var product_tracking = ""
                                            if let value = dict["product_tracking"] as? String {
                                                product_tracking = value
                                            }
                                            var product_uom_id = ""
                                            if let value = dict["product_uom_id"] as? String {
                                                product_uom_id = value
                                            }
                                            
                                            //,,,sbm2
                                            /*
                                            let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                    erpName: self.erpName,
                                                                                    poNumber: self.selectedPuchaseOrderDict?.poNumber,
                                                                                    poUniqueID: self.selectedPuchaseOrderDict?.uniqueID,
                                                                                    productUniqueID: product_id,
                                                                                    productName: product_name,
                                                                                    productCode: product_code,
                                                                                    productReceivedQuantity: product_received_quantity,
                                                                                    productDemandQuantity: product_demand_quantity,
                                                                                    productQtyToReceive: product_qty_to_receive,
                                                                                    productTracking: product_tracking,
                                                                                    lineItemUUID: "",
                                                                                    productUomID: product_uom_id)
                                            selectedLineItemsListArray.append(mwViewItemsModel)
                                            */
                                            
                                            
                                            do{
                                                let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                    obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                    obj.erpUUID = self.erpUUID
                                                    obj.erpName = self.erpName
                                                    obj.poNumber = self.selectedPuchaseOrderDict?.poNumber
                                                    obj.poUniqueID = self.selectedPuchaseOrderDict?.uniqueID
                                                    obj.productUniqueID = product_id
                                                    obj.productName = product_name
                                                    obj.productCode = product_code
                                                    obj.productReceivedQuantity = product_received_quantity
                                                    obj.productDemandQuantity = product_demand_quantity
                                                    obj.productQtyToReceive = product_qty_to_receive
                                                    obj.productTracking = product_tracking
                                                    obj.lineItemUUID = ""
                                                    obj.productUomID = product_uom_id
                                                    obj.isEdited = false
                                                    if via == "Manually" {
                                                        obj.productFlowType = "directManualLotEntry"
                                                    }
                                                    else {
                                                        obj.productFlowType = "directSerialScanEntry"
                                                    }
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.productReceivedQuantity = product_received_quantity
                                                        obj.productDemandQuantity = product_demand_quantity
                                                        obj.productQtyToReceive = product_qty_to_receive
                                                        if via == "Manually" {
                                                            obj.productFlowType = "directManualLotEntry"
                                                        }
                                                        else {
                                                            obj.productFlowType = "directSerialScanEntry"
                                                        }
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    }
                                    else if self.erpName == "ttrx" {
                                        for dict in dataArray {
                                            var product_uuid = ""
                                            if let value = dict["product_uuid"] as? String {
                                                product_uuid = value
                                            }
                                            var product_demand_quantity = ""
                                            if let value = dict["product_demand_quantity"] as? String {
                                                product_demand_quantity = value
                                            }
                                            var product_received_quantity = ""
                                            if let value = dict["product_received_quantity"] as? String {
                                                product_received_quantity = value
                                            }
                                            var product_qty_to_receive = ""
                                            if let value = dict["product_qty_to_receive"] as? Int {
                                                product_qty_to_receive = String(value)
                                            }
                                            var product_code = ""
                                            if let value = dict["product_code"] as? String {
                                                product_code = value
                                            }
                                            var product_name = ""
                                            if let value = dict["product_name"] as? String {
                                                product_name = value
                                            }
                                            var product_tracking = ""
                                            if let value = dict["product_tracking"] as? String {
                                                product_tracking = value
                                            }
                                            
                                            var line_item_uuid = ""
                                            if let value = dict["line_item_uuid"] as? String {
                                                line_item_uuid = value
                                            }
                                            
                                            //,,,sbm2
                                            /*
                                            let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                    erpName: self.erpName,
                                                                                    poNumber: self.selectedPuchaseOrderDict?.poNumber,
                                                                                    poUniqueID: self.selectedPuchaseOrderDict?.uniqueID,
                                                                                    productUniqueID: product_uuid,
                                                                                    productName: product_name,
                                                                                    productCode:product_code,
                                                                                    productReceivedQuantity: product_received_quantity,
                                                                                    productDemandQuantity: product_demand_quantity,
                                                                                    productQtyToReceive: product_qty_to_receive,
                                                                                    productTracking: product_tracking,
                                                                                    lineItemUUID: line_item_uuid,
                                                                                    productUomID: "")
                                            
                                            selectedLineItemsListArray.append(mwViewItemsModel)
                                            */
                                                                                        
                                            
                                            do{
                                                let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.ttrx.rawValue)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                    obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                    obj.erpUUID = self.erpUUID
                                                    obj.erpName = self.erpName
                                                    obj.poNumber = self.selectedPuchaseOrderDict?.poNumber
                                                    obj.poUniqueID = self.selectedPuchaseOrderDict?.uniqueID
                                                    obj.productUniqueID = product_uuid
                                                    obj.productName = product_name
                                                    obj.productCode = product_code
                                                    obj.productReceivedQuantity = product_received_quantity
                                                    obj.productDemandQuantity = product_demand_quantity
                                                    obj.productQtyToReceive = product_qty_to_receive
                                                    obj.productTracking = product_tracking
                                                    obj.lineItemUUID = line_item_uuid
                                                    obj.productUomID = ""
                                                    obj.isEdited = false
                                                    if via == "Manually" {
                                                        obj.productFlowType = "directManualLotEntry"
                                                    }
                                                    else {
                                                        obj.productFlowType = "directSerialScanEntry"
                                                    }
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.productReceivedQuantity = product_received_quantity
                                                        obj.productDemandQuantity = product_demand_quantity
                                                        obj.productQtyToReceive = product_qty_to_receive
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    }
                                    
                                    if via == "Manually" {
                                        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                                        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingManuallyViewController") as! MWReceivingManuallyViewController
                                        controller.flowType = "directManualLot"
//                                        controller.selectedLineItemsListArray = selectedLineItemsListArray //,,,sbm2
                                        controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
                                        
//                                        controller.filterSerialHeaderListArray = [] //,,,sbm2
//                                        controller.filterSerialItemsListArray = [] //,,,sbm2
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                    else {
                                        let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
                                        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
                                        controller.flowType = "directSerialScan"
                                        controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
//                                        controller.selectedLineItemsListArray = selectedLineItemsListArray //,,,sbm2
//                                        controller.scanProductArray = self.scanProductArray
//                                        controller.filterLotHeaderListArray = [] //,,,sbm2
//                                        controller.filterLotItemsListArray = [] //,,,sbm2
                                        self.navigationController?.pushViewController(controller, animated: true)
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
                    } catch {
                       print("JSON parsing Error")
                    }
                    
                    //,,,sbm0 temp
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
    }*///,,,unused
    func listLineItemsByPurchaseOrderWebServiceCall() {
        /*
         List Line Items By Purchase Order
         4032b2bb-3b29-4fe1-b384-4a76b30101eb
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-line-items-by-purchase-order
         
        POST
         {
                 "action_uuid": "4032b2bb-3b29-4fe1-b384-4a76b30101eb",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_id": "184"
         }
        */
        
        /*
         Response Data: Optional({
             data = "[{\"product_id\": \"1405\", \"product_code\": \"00303160123016\", \"product_name\": \"00303160123016 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1406\", \"product_code\": \"00303160123801\", \"product_name\": \"00303160123801 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1403\", \"product_code\": \"00349908118142\", \"product_name\": \"00349908118142 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}, {\"product_id\": \"1404\", \"product_code\": \"10349908118149\", \"product_name\": \"10349908118149 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_received_quantity\": \"0.0\", \"product_qty_to_receive\": \"100.0\"}]";
             message = "Successfully executed.";
             status = success;
             "status_code" = 1;
         })
         */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsByPurchaseOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = self.selectedPuchaseOrderDict?.erpUUID
        
        if self.selectedPuchaseOrderDict?.erpName == "odoo" {
            requestDict["po_id"] = selectedPuchaseOrderDict?.uniqueID
        }
        else if self.selectedPuchaseOrderDict?.erpName == "ttrx" {
//            requestDict["po_uuid"] = selectedPuchaseOrderDict?.uniqueID
            requestDict["po_id"] = selectedPuchaseOrderDict?.uniqueID

        }

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListLineItemsByPurchaseOrder", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
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
                                //                                                print("dataArray....>>>>>",dataArray)
                                if self.selectedPuchaseOrderDict?.erpName == "odoo" {
                                    for dict in dataArray {
                                        var product_id = ""
//                                        if let value = dict["product_id"] as? Int {
                                        if let value = dict["product_id"] as? String {
//                                            product_id = String(value)
                                            product_id = value
                                        }
                                        var product_demand_quantity = ""
//                                        if let value = dict["product_demand_quantity"] as? Int {
                                        if let value = dict["product_demand_quantity"] as? String {
//                                            product_demand_quantity = String(value)
                                            product_demand_quantity = value
                                        }
                                        var product_received_quantity = ""
//                                        if let value = dict["product_received_quantity"] as? Int {
                                        if let value = dict["product_received_quantity"] as? String {
//                                            product_received_quantity = String(value)
                                            product_received_quantity = value
                                        }
                                        var product_qty_to_receive = ""
//                                        if let value = dict["product_qty_to_receive"] as? Int {
                                        if let value = dict["product_qty_to_receive"] as? String {
//                                            product_qty_to_receive = String(value)
                                            product_qty_to_receive = value
                                        }
                                        var product_code = ""
                                        if let value = dict["product_code"] as? String {
                                            product_code = value
                                        }
                                        var product_name = ""
                                        if let value = dict["product_name"] as? String {
                                            product_name = value
                                        }
                                        var product_tracking = ""
                                        if let value = dict["product_tracking"] as? String {
                                            product_tracking = value
                                        }
                                        
                                        var product_uom_id = ""
//                                        if let value = dict["product_uom_id"] as? Int {
                                        if let value = dict["product_uom_id"] as? String {
//                                            product_uom_id = String(value)
                                            product_uom_id = value
                                        }
                                        
                                        //,,,sbm2
                                        do{
                                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                                                obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                                                obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                                                obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                                                obj.product_unique_id = product_id
                                                obj.product_name = product_name
                                                obj.product_code = product_code
                                                obj.product_received_qty = product_received_quantity
                                                obj.product_demand_qty = product_demand_quantity
                                                obj.product_qty_to_receive = product_qty_to_receive
                                                obj.product_tracking = product_tracking
                                                obj.line_item_uuid = ""
                                                obj.product_uom_id = product_uom_id
                                                obj.is_edited = false
                                                obj.product_flow_type = "directManualLotEntry"
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.product_received_qty = product_received_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_receive = product_qty_to_receive
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                }
                                else if self.selectedPuchaseOrderDict?.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var product_uuid = ""
                                        if let value = dict["product_uuid"] as? String {
                                            product_uuid = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_received_quantity = ""
                                        if let value = dict["product_received_quantity"] as? String {
                                            product_received_quantity = value
                                        }
                                        var product_qty_to_receive = ""
                                        if let value = dict["product_qty_to_receive"] as? Int {
                                            product_qty_to_receive = String(value)
                                        }
                                        var product_code = ""
                                        if let value = dict["product_code"] as? String {
                                            product_code = value
                                        }
                                        var product_name = ""
                                        if let value = dict["product_name"] as? String {
                                            product_name = value
                                        }
                                        var product_tracking = ""
                                        if let value = dict["product_tracking"] as? String {
                                            product_tracking = value
                                        }
                                        
                                        var line_item_uuid = ""
                                        if let value = dict["line_item_uuid"] as? String {
                                            line_item_uuid = value
                                        }
                                        
                                        //,,,sbm2
                                        do{
                                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                                                obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                                                obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                                                obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                                                obj.product_unique_id = product_uuid
                                                obj.product_name = product_name
                                                obj.product_code = product_code
                                                obj.product_received_qty = product_received_quantity
                                                obj.product_demand_qty = product_demand_quantity
                                                obj.product_qty_to_receive = product_qty_to_receive
                                                obj.product_tracking = product_tracking
                                                obj.line_item_uuid = line_item_uuid
                                                obj.product_uom_id = ""
                                                obj.is_edited = false
                                                obj.product_flow_type = "directManualLotEntry"
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.product_received_qty = product_received_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_receive = product_qty_to_receive
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                }
                                                     
                                self.getDBData()
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
                    if self.selectedPuchaseOrderDict?.erpUUID == "41afff72-2eac-4f2e-ab2f-9adab4323d0d" {
                        //TTRx
                        path = Bundle.main.path(forResource: "MWListPurchaseOrders_ttrx", ofType: "json")!
                    }else {
//                        path = Bundle.main.path(forResource: "MW_list-line-items-by-purchase-order_odoo", ofType: "json")!
                        path = Bundle.main.path(forResource: "MW_list-line-items-by-purchase-order_odoo_Serial", ofType: "json")!
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
//                                                print("dataArray....>>>>>",dataArray)
                                    if self.selectedPuchaseOrderDict?.erpName == "odoo" {
                                        for dict in dataArray {
                                            var product_id = ""
//                                        if let value = dict["product_id"] as? Int {
                                            if let value = dict["product_id"] as? String {
//                                            product_id = String(value)
                                                product_id = value
                                            }
                                            var product_demand_quantity = ""
                                            if let value = dict["product_demand_quantity"] as? String {
                                                product_demand_quantity = value
                                            }
                                            var product_received_quantity = ""
                                            if let value = dict["product_received_quantity"] as? String {
                                                product_received_quantity = value
                                            }
                                            var product_qty_to_receive = ""
                                            if let value = dict["product_qty_to_receive"] as? String {
                                                product_qty_to_receive = value
                                            }
                                            var product_code = ""
                                            if let value = dict["product_code"] as? String {
                                                product_code = value
                                            }
                                            var product_name = ""
                                            if let value = dict["product_name"] as? String {
                                                product_name = value
                                            }
                                            var product_tracking = ""
                                            if let value = dict["product_tracking"] as? String {
                                                product_tracking = value
                                            }
                                            var product_uom_id = ""
                                            if let value = dict["product_uom_id"] as? String {
                                                product_uom_id = value
                                            }
                                            
                                            //,,,sbm2
                                            do{
                                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                    obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                    obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                                                    obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                                                    obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                                                    obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                                                    obj.product_unique_id = product_id
                                                    obj.product_name = product_name
                                                    obj.product_code = product_code
                                                    obj.product_received_qty = product_received_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_receive = product_qty_to_receive
                                                    obj.product_tracking = product_tracking
                                                    obj.line_item_uuid = ""
                                                    obj.product_uom_id = product_uom_id
                                                    obj.is_edited = false
                                                    obj.product_flow_type = "directManualLotEntry"
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.product_received_qty = product_received_quantity
                                                        obj.product_demand_qty = product_demand_quantity
                                                        obj.product_qty_to_receive = product_qty_to_receive
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    }
                                    else if self.selectedPuchaseOrderDict?.erpName == "ttrx" {
                                        for dict in dataArray {
                                            var product_uuid = ""
                                            if let value = dict["product_uuid"] as? String {
                                                product_uuid = value
                                            }
                                            var product_demand_quantity = ""
                                            if let value = dict["product_demand_quantity"] as? String {
                                                product_demand_quantity = value
                                            }
                                            var product_received_quantity = ""
                                            if let value = dict["product_received_quantity"] as? String {
                                                product_received_quantity = value
                                            }
                                            var product_qty_to_receive = ""
                                            if let value = dict["product_qty_to_receive"] as? Int {
                                                product_qty_to_receive = String(value)
                                            }
                                            var product_code = ""
                                            if let value = dict["product_code"] as? String {
                                                product_code = value
                                            }
                                            var product_name = ""
                                            if let value = dict["product_name"] as? String {
                                                product_name = value
                                            }
                                            var product_tracking = ""
                                            if let value = dict["product_tracking"] as? String {
                                                product_tracking = value
                                            }
                                            
                                            var line_item_uuid = ""
                                            if let value = dict["line_item_uuid"] as? String {
                                                line_item_uuid = value
                                            }
                                            
                                            //,,,sbm2
                                            do{
                                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_ReceivingLineItem(context: PersistenceService.context)
                                                    obj.id = MWReceivingLineItem.getAutoIncrementId()
                                                    obj.erp_uuid = self.selectedPuchaseOrderDict?.erpUUID
                                                    obj.erp_name = self.selectedPuchaseOrderDict?.erpName
                                                    obj.po_number = self.selectedPuchaseOrderDict?.poNumber
                                                    obj.po_unique_id = self.selectedPuchaseOrderDict?.uniqueID
                                                    obj.product_unique_id = product_uuid
                                                    obj.product_name = product_name
                                                    obj.product_code = product_code
                                                    obj.product_received_qty = product_received_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_receive = product_qty_to_receive
                                                    obj.product_tracking = product_tracking
                                                    obj.line_item_uuid = line_item_uuid
                                                    obj.product_uom_id = ""
                                                    obj.is_edited = false
                                                    obj.product_flow_type = "directManualLotEntry"
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.product_received_qty = product_received_quantity
                                                        obj.product_demand_qty = product_demand_quantity
                                                        obj.product_qty_to_receive = product_qty_to_receive
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    }
                                    
                                    self.getDBData()
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
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count-2 >= 0 {
                if viewControllers[viewControllers.count-2] is MWPuchaseOrderListViewController ||  viewControllers[viewControllers.count-2] is DashboardViewController {
                    
                    var count = 0
                    do{
                        let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited=true")
                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                        count = fetchRequestResultArray.count
                    }catch let error {
                        print(error.localizedDescription)
                    }
                    
                    
                    if count > 0 {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MWReceivingCancelViewController") as! MWReceivingCancelViewController
                        self.navigationController?.pushViewController(controller, animated: false)
                    }
                    else {
                        MWReceiving.removeAllMW_ReceivingEntityDataFromDB()//,,,sbm2
                        navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }//,,,sbm2
    
    
    @IBAction func addLotButtonPressed(_ sender: UIButton) {
        if (textFieldTobeField != nil) {
            textFieldTobeField.resignFirstResponder()
        }
        
        let section = Int(sender.accessibilityValue!)
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = filterLotHeaderListArray[section!]
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
        
        let quantityToReceive = demandQty - productReceivedQty
        
        
        
        var productsModelArray = filterLotItemsListArray[section!]
        if productsModelArray.count > 0 {
            let qtyArray = productsModelArray.map { $0.quantity }
            var qtyAmount:Int = 0
            for qty in qtyArray {
                if let qtyStr = qty {
                    qtyAmount = qtyAmount + (Int(qtyStr) ?? 0)
                }
            }
            
            if qtyAmount < quantityToReceive {
                let mwReceivingManuallyLotOrScanSerialBaseModel = MWReceivingManuallyLotOrScanSerialBaseModel(erpUUID: productsModel.erpUUID,
                                                                                      erpName: productsModel.erpName,
                                                                                      poNumber: productsModel.poNumber,
                                                                                      poUniqueID: productsModel.poUniqueID,
                                                                                      productUniqueID: productsModel.productUniqueID,
                                                                                      productName: productsModel.productName,
                                                                                      productCode: productsModel.productCode,
                                                                                      productReceivedQuantity: productsModel.productReceivedQuantity,
                                                                                      productDemandQuantity: productsModel.productDemandQuantity,
                                                                                      productQtyToReceive: productsModel.productQtyToReceive,
                                                                                      productTracking: productsModel.productTracking,
                                                                                      productUomID: productsModel.productUomID,
                                                                                      lotNumber: "",
                                                                                      quantity: "",
                                                                                      isContainer: false,
                                                                                      cSerial: "",
                                                                                      cGtin: "",
                                                                                      pSerials: [],
                                                                                      pGtins: [],
                                                                                      serialNumber: "",
                                                                                      isEdited: false)
                
                productsModelArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
                
                filterLotItemsListArray[section!] = productsModelArray
            }
            else {
                Utility.showPopup(Title: Warning, Message: "Total quantity can not be greater than Quantity to be Received".localized(), InViewC: self)
            }
        }
        else {
            if quantityToReceive > 0 {
                let mwReceivingManuallyLotOrScanSerialBaseModel = MWReceivingManuallyLotOrScanSerialBaseModel(erpUUID: productsModel.erpUUID,
                                                                                      erpName: productsModel.erpName,
                                                                                      poNumber: productsModel.poNumber,
                                                                                      poUniqueID: productsModel.poUniqueID,
                                                                                      productUniqueID: productsModel.productUniqueID,
                                                                                      productName: productsModel.productName,
                                                                                      productCode: productsModel.productCode,
                                                                                      productReceivedQuantity: productsModel.productReceivedQuantity,
                                                                                      productDemandQuantity: productsModel.productDemandQuantity,
                                                                                      productQtyToReceive: productsModel.productQtyToReceive,
                                                                                      productTracking: productsModel.productTracking,
                                                                                      productUomID: productsModel.productUomID,
                                                                                      lotNumber: "",
                                                                                      quantity: "",
                                                                                      isContainer: false,
                                                                                      cSerial: "",
                                                                                      cGtin: "",
                                                                                      pSerials: [],
                                                                                      pGtins: [],
                                                                                      serialNumber: "",
                                                                                      isEdited: false)
                
                productsModelArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
                
                filterLotItemsListArray[section!] = productsModelArray
            }
            else {
                Utility.showPopup(Title: Warning, Message: "Total quantity can not be greater than Quantity to be Received".localized(), InViewC: self)
            }
        }
        
        listTable.reloadData()
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        let msg = "Do you want to remove this row?".localized()
        let confirmAlert = UIAlertController(title: "Alert".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                        
            if (self.textFieldTobeField != nil) {
                self.textFieldTobeField.resignFirstResponder()
            }
            
            let section = Int(sender.accessibilityValue!)
            var productsModelArray = self.filterLotItemsListArray[section!]
            productsModelArray.remove(at: sender.tag)
            self.filterLotItemsListArray[section!] = productsModelArray
            self.listTable.reloadData()
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if (textFieldTobeField != nil) {
            textFieldTobeField.resignFirstResponder()
        }
        
        
        //,,,sbm2
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot' and is_edited=true")
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
            if !fetchRequestResultArray.isEmpty {
                fetchRequestResultArray.forEach({ (cdModel) in
                    cdModel.is_edited = false
                    PersistenceService.saveContext()
                })
            }
        }catch let error {
            print(error.localizedDescription)
        }
        
        
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot' and is_edited=true")
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if !fetchRequestResultArray.isEmpty {
                fetchRequestResultArray.forEach({ (cdModel) in
                    cdModel.is_edited = false
                    PersistenceService.saveContext()
                })
            }
        }catch let error {
            print(error.localizedDescription)
        }
        //,,,sbm2
        
        
        
        
        
        
        var isEmpty = false
        var totalQtyAmount:Int = 0

        for i in 0..<filterLotItemsListArray.count {
            let productsModelArray = filterLotItemsListArray[i]
            if productsModelArray.count > 0 {
                var quantityToReceive = 0
                for j in 0..<productsModelArray.count {
                    let productsModel = productsModelArray[j]
                    if let lotNumber = productsModel.lotNumber,lotNumber.isEmpty {
                        isEmpty = true
                    }
                    if let quantity = productsModel.quantity,quantity.isEmpty {
                        isEmpty = true
                    }
                    if isEmpty {
                        Utility.showPopup(Title: Warning, Message: "Please fill all the details", InViewC: self)
                        return
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
                    
                    quantityToReceive = demandQty - productReceivedQty
                }
                
                let qtyArray = productsModelArray.map { $0.quantity }
                var qtyAmount:Int = 0
                for qty in qtyArray {
                    if let qtyStr = qty {
                        qtyAmount = qtyAmount + (Int(qtyStr) ?? 0)
                    }
                }
                
                totalQtyAmount = totalQtyAmount + qtyAmount
                
                if qtyAmount > quantityToReceive {
                    
                    //######//
                    let message = "Total quantity can not be greater than Quantity to be Received".localized()
                    Utility.showPopupWithAction(Title: Warning, Message: message, InViewC: self, action:{
                        let indexPath = IndexPath(row: productsModelArray.count-1, section: i)
                        let cell = self.listTable.cellForRow(at: indexPath) as! MWReceivingManuallyTableViewCell
                        cell.qtyTextField.becomeFirstResponder()
                    })
                    //######//
                    
                    return
                }
                else {
                    //,,,sbm2
                    for model in productsModelArray {
                        do{
                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(model.productCode!)' and is_edited= false")
                        
                            
                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                            if !fetchRequestResultArray.isEmpty {
                                fetchRequestResultArray.forEach({ (cdModel) in
                                    PersistenceService.context.delete(cdModel)
                                })
                                PersistenceService.saveContext()
                            }
                            
                            
                            let obj = MW_ReceivingManualLotOrScanSerial(context: PersistenceService.context)
                            obj.id = MWReceivingManualLotOrScanSerial.getAutoIncrementId()
                            obj.erp_uuid = model.erpUUID
                            obj.erp_name = model.erpName
                            obj.po_number = model.poNumber
                            obj.po_unique_id = model.poUniqueID
                            obj.product_unique_id = model.productUniqueID
                            obj.product_name = model.productName
                            obj.product_code = model.productCode
                            obj.product_received_qty = model.productReceivedQuantity
                            obj.product_demand_qty = model.productDemandQuantity
                            obj.product_qty_to_receive = model.productQtyToReceive
                            obj.product_tracking = model.productTracking
                            obj.product_uom_id = model.productUomID
                            obj.lot_number = model.lotNumber
                            obj.quantity = model.quantity
                            obj.is_container = false
                            obj.c_serial = ""
                            obj.c_gtin = ""
                            obj.p_serials = Utility.json(from: [])
                            obj.p_gtins = Utility.json(from: [])
                            obj.serial_number = ""
                            obj.is_edited = true
                            
                            PersistenceService.saveContext()
                                                        
                        }catch let error {
                            print(error.localizedDescription)
                        }
                        
                        
                        do{
                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(model.productCode!)'")
                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                            if !fetchRequestResultArray.isEmpty {
                                
                                fetchRequestResultArray.forEach({ (cdModel) in
                                    cdModel.is_edited = true
                                    PersistenceService.saveContext()
                                })
                            }
                        }catch let error {
                            print(error.localizedDescription)
                        }
                    }
                    //,,,sbm2
                }
            }
        }

        if totalQtyAmount > 0 {
            if filterSerialLineItemsArray.count > 0 && showSerialAlert == true {
                
                if flowType == "directManualLot" {
                    var msg = "There are serial based line item exist. Do you want to process this serial based line item?"
                    var alertStatus = "Alert6"
                    do{
                        let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='serial' and is_edited=true")

                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                        if !fetchRequestResultArray.isEmpty {
                            msg = "There are serial based line item exist. Do you want to modify this serial based line item?"
                            alertStatus = "Alert7"
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                    
                    self.showConfirmationViewController(confirmationMsg: msg, alertStatus: alertStatus)
                }
                else {
                    let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                    let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSummaryOfMappedLotsViewController") as! MWReceivingSummaryOfMappedLotsViewController
                    controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict//,,,sbm2
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            else {
                let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSummaryOfMappedLotsViewController") as! MWReceivingSummaryOfMappedLotsViewController
                controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict//,,,sbm2
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        else {
            Utility.showPopup(Title: Warning, Message: "Please add atleast one lot", InViewC: self)
        }
    }
    //MARK: - End
}


// MARK: - MWReceivingSelectionViewController
extension MWReceivingManuallyViewController: MWReceivingSelectionViewControllerDelegate {
    func showMWReceivingSelectionViewController() {
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSelectionViewController") as! MWReceivingSelectionViewController
        controller.delegate = self
        controller.previousController = "MWReceivingManuallyViewController"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
            
    func didClickOnCamera(){
        //,,,sbm2 temp
        /*
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
        */
        
        self.didSingleScanCodeForReceiveSerialVerification(scannedCode: [])
        //,,,sbm2 temp
    }
    
    func didClickManually() {
        
    }
    
    func didClickCrossButton() {
        showSerialAlert = false
    }
}
//MARK: - End


//MARK: - MWMultiScanViewControllerDelegate
extension MWReceivingManuallyViewController : MWMultiScanViewControllerDelegate {
    
    func didScanCodeForReceiveSerialVerification(scannedCode:[String]) {
        //Add Api here
        print("didScanCodeForReceiveSerialVerification....>>",scannedCode)
        
        if scannedCode.count > 0 {
            self.didSingleScanCodeForReceiveSerialVerification(scannedCode: scannedCode)
        }
    }
    func backFromMultiScan() {
        showSerialAlert = false
    }
}
//MARK: - End

//MARK: - MWSingleScanViewControllerDelegate
extension MWReceivingManuallyViewController : MWSingleScanViewControllerDelegate {
    
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
        
        let scanProductArray = Utility.createSampleScanProduct()//,,,sbm2 temp
        
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
        //,,,sbm2
        
        if scanProductArray.count > 0 {
            let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
            controller.flowType = "viaManualLot"
            controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func backFromSingleScan() {
        showSerialAlert = false
    }
}
//MARK: - End

// MARK: - MWConfirmationView
extension MWReceivingManuallyViewController: MWConfirmationViewDelegate {
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
        if alertStatus == "Alert6" {
            self.showMWReceivingSelectionViewController()
            
        }else if alertStatus == "Alert7" {
            let storyboard = UIStoryboard(name: "MWReceiving", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialListViewController") as! MWReceivingSerialListViewController
            controller.flowType = "viaManualLot"
            controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func cancelButtonPressed(alertStatus:String) {
        if alertStatus == "Alert6" ||  alertStatus == "Alert7" {
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSummaryOfMappedLotsViewController") as! MWReceivingSummaryOfMappedLotsViewController
            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict//,,,sbm2
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK: - End
}
// MARK: - End

extension MWReceivingManuallyViewController {
    //MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let section = Int(textField.accessibilityValue!)
        if textField.accessibilityHint == "LotNumber" {
            var productsModelArray = filterLotItemsListArray[section!]
            var productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[textField.tag]
            productsModel.lotNumber = textField.text
            productsModelArray[textField.tag] = productsModel
            filterLotItemsListArray[section!] = productsModelArray
        }
        else if textField.accessibilityHint == "qty" {
            var productsModelArray = filterLotItemsListArray[section!]
            var productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[textField.tag]
            productsModel.quantity = textField.text
            productsModelArray[textField.tag] = productsModel
            filterLotItemsListArray[section!] = productsModelArray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    //MARK: - End
}

extension MWReceivingManuallyViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MWReceivingManuallyHeaderView") as! MWReceivingManuallyHeaderView
        
        let productsModelArray = filterLotItemsListArray[section]
        if productsModelArray.count == 0 {
            headerView.clipsToBounds = true
            headerView.layer.cornerRadius = 15
            headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        else {
            headerView.clipsToBounds = true
            headerView.layer.cornerRadius = 15
            headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        let backgroundView = UIView(frame: headerView.bounds)
        backgroundView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") // E8EEE6
        headerView.backgroundView = backgroundView
        
        headerView.addLotButton.setRoundCorner(cornerRadious: headerView.addLotButton.frame.height/2)
        headerView.addLotButton.addTarget(self,action:#selector(addLotButtonPressed),for:.touchUpInside)
        headerView.addLotButton.accessibilityValue = "\(section)"

        
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = filterLotHeaderListArray[section]

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
        return filterLotHeaderListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productsModelArray = filterLotItemsListArray[section]
        return productsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWReceivingManuallyTableViewCell") as! MWReceivingManuallyTableViewCell
        cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 0
        
        cell.addLotButton.tag = -1
        cell.addLotButton.accessibilityValue = "-1"
        
        cell.removeButton.tag = -1
        cell.removeButton.accessibilityValue = "-1"
        
        cell.lotNumberTextField.tag = -1
        cell.lotNumberTextField.accessibilityValue = "-1"
        cell.lotNumberTextField.accessibilityHint = "LotNumber"
        
        cell.qtyTextField.tag = -1
        cell.qtyTextField.accessibilityValue = "-1"
        cell.qtyTextField.accessibilityHint = "qty"

        let productsModelArray = filterLotItemsListArray[indexPath.section]
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[indexPath.row]
        if let lotNumber = productsModel.lotNumber {
            cell.lotNumberTextField.text = lotNumber
        }
        if let quantity = productsModel.quantity {
            cell.qtyTextField.text = quantity
        }
        
        if indexPath.row == productsModelArray.count-1 {
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 15
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.addLotButton.isHidden = false
        }
        else {
            cell.addLotButton.isHidden = true
        }
        
        if productsModelArray.count > 0 {
            cell.removeButton.isHidden = false
        }else {
            cell.removeButton.isHidden = true
        }
            
        cell.addLotButton.tag = indexPath.row
        cell.addLotButton.accessibilityValue = "\(indexPath.section)"
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.accessibilityValue = "\(indexPath.section)"
        
        cell.lotNumberTextField.tag = indexPath.row
        cell.lotNumberTextField.accessibilityValue = "\(indexPath.section)"
        
        cell.qtyTextField.tag = indexPath.row
        cell.qtyTextField.accessibilityValue = "\(indexPath.section)"
        
        cell.addLotButton.isHidden = true

        return cell
    }
    //MARK: - End
}

class MWReceivingManuallyTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet weak var lotNumberTextField: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var addLotButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    
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

struct MWReceivingManuallyLotOrScanSerialBaseModel {
    var primaryID : Int16!
    var erpUUID : String!
    var erpName : String!
    var poNumber : String!
    var poUniqueID: String!
    
    var productUniqueID : String!
    var productName : String!
    var productCode : String!
    var productReceivedQuantity: String!
    var productDemandQuantity: String!
    var productQtyToReceive: String!
    var productTracking: String!
    var productUomID: String! //For odoo

    var lotNumber: String!
    var quantity: String!
    var isContainer: Bool!
    var cSerial: String!
    var cGtin: String!
    var pSerials: [Any]!
    var pGtins: [Any]!
    
    var serialNumber: String!
    var isEdited: Bool!
}
