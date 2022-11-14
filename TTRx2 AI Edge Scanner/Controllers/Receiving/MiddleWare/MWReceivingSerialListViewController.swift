//
//  MWReceivingSerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 09/08/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

class MWReceivingSerialListViewController: BaseViewController {
    @IBOutlet weak var listTableView: UITableView!
    
    var flowType: String = "" //"directSerialScan", "viaManualLot"
    var selectedPuchaseOrderDict: MWPuchaseOrderModel?
    var selectedLineItemsListArray : [MWViewItemsModel] = []
    var scannedSerialListArray = [MWReceivingManuallyLotOrScanSerialBaseModel]() //MWReceivingScanSerialBaseModel
    var selectedScannedSerialListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
    
    //MARK: - ViewLifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        self.listLineItemsByPurchaseOrderWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func getDBData() {
        //,,,sbm2
        selectedLineItemsListArray = []
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

        
        //,,,sbm2
        var filterSerialLineItemsListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
        for model in selectedLineItemsListArray {
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
            
            
            
            if productTracking == "lot" {
                
            }else if productTracking == "serial" {
                filterSerialLineItemsListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
            }
        }
        //,,,sbm2
        
        
        //,,,sbm2
        var scanProductArray = [MWReceivingScanProductModel]()
        do{
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                scanProductArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    scanProductArray.append(cdModel.convertCoreDataRequestsToMWReceivingScanProductModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            scanProductArray = []
        }
        //,,,sbm2
        
        
        var gtinArray:[String] = []
        for scanProductModel in scanProductArray {
            if let gtin = scanProductModel.GTIN {
                if !gtinArray.contains(gtin) {
                    gtinArray.append(gtin)
                }
                
                let filteredArray = filterSerialLineItemsListArray.filter { $0.productCode!.localizedCaseInsensitiveContains(gtin) }
                if filteredArray.count > 0 {
                    let lineItemModel = filteredArray[0]
                    var serial = ""
                    if let serialNumber = scanProductModel.serialNumber {
                        serial = serialNumber
                    }
                    var lot = ""
                    if let lotNumber = scanProductModel.lotNumber {
                        lot = lotNumber
                    }
                    
                    
                    //,,,sbm2
                    do{
                        let predicate = NSPredicate(format:"erp_uuid='\(lineItemModel.erpUUID!)' and po_number='\(lineItemModel.poNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)'")
                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
                            let obj = MW_ReceivingManualLotOrScanSerial(context: PersistenceService.context)
                            obj.id = MWReceivingManualLotOrScanSerial.getAutoIncrementId()
                            obj.erp_uuid = lineItemModel.erpUUID
                            obj.erp_name = lineItemModel.erpName
                            obj.po_number = lineItemModel.poNumber
                            obj.po_unique_id = lineItemModel.poUniqueID
                            obj.product_unique_id = lineItemModel.productUniqueID
                            obj.product_name = lineItemModel.productName
                            obj.product_code = lineItemModel.productCode
                            obj.product_received_qty = lineItemModel.productReceivedQuantity
                            obj.product_demand_qty = lineItemModel.productDemandQuantity
                            obj.product_qty_to_receive = lineItemModel.productQtyToReceive
                            obj.product_tracking = lineItemModel.productTracking
                            obj.product_uom_id = lineItemModel.productUomID
                            obj.lot_number = lot
                            obj.quantity = ""
                            obj.is_container = lineItemModel.isContainer
                            obj.c_serial = ""
                            obj.c_gtin = ""
                            obj.p_serials = Utility.json(from: [])
                            obj.p_gtins = Utility.json(from: [])
                            obj.serial_number = serial
                            obj.is_edited = false
                            
                            PersistenceService.saveContext()
                        }
                        else {
                            if let obj = fetchRequestResultArray.first {
                                obj.product_received_qty = lineItemModel.productReceivedQuantity
                                obj.product_demand_qty = lineItemModel.productDemandQuantity
                                obj.product_qty_to_receive = lineItemModel.productQtyToReceive
                                PersistenceService.saveContext()
                            }
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                    //,,,sbm2
                }
            }
        }
        
        //,,,sbm2
        scannedSerialListArray = []
        for gtin in gtinArray {
            do{
                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(gtin)' and product_tracking='serial'")
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    
                }else {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        if cdModel.is_edited == true {
                            if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == cdModel.serial_number && $0.productCode == cdModel.product_code}) {
                                selectedScannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                            }
                        }
                        scannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                    })
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
        //,,,sbm2

        self.listTableView.reloadData()
    }
    //MARK: - End
    
    //MARK: - WebserviceCall
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
        requestDict["source_erp"] = self.selectedPuchaseOrderDict!.erpUUID!
        
        if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue {
            requestDict["po_id"] = self.selectedPuchaseOrderDict!.uniqueID!
        }
        else if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
            requestDict["po_uuid"] = self.selectedPuchaseOrderDict!.uniqueID!
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
                                if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue {
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
                                                obj.erp_uuid = self.selectedPuchaseOrderDict!.erpUUID!
                                                obj.erp_name = self.selectedPuchaseOrderDict!.erpName!
                                                obj.po_number = self.selectedPuchaseOrderDict!.poNumber!
                                                obj.po_unique_id = self.selectedPuchaseOrderDict!.uniqueID!
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
                                                obj.product_flow_type = "directSerialScanEntry"
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
                                else if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
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
                                                obj.erp_uuid = self.selectedPuchaseOrderDict!.erpUUID!
                                                obj.erp_name = self.selectedPuchaseOrderDict!.erpName!
                                                obj.po_number = self.selectedPuchaseOrderDict!.poNumber!
                                                obj.po_unique_id = self.selectedPuchaseOrderDict!.uniqueID!
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
                                                obj.product_flow_type = "directSerialScanEntry"
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
                    if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
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
                                    if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue {
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
                                                    obj.erp_uuid = self.selectedPuchaseOrderDict!.erpUUID!
                                                    obj.erp_name = self.selectedPuchaseOrderDict!.erpName!
                                                    obj.po_number = self.selectedPuchaseOrderDict!.poNumber!
                                                    obj.po_unique_id = self.selectedPuchaseOrderDict!.uniqueID!
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
                                                    obj.product_flow_type = "directSerialScanEntry"
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
                                    else if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
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
                                                    obj.erp_uuid = self.selectedPuchaseOrderDict!.erpUUID!
                                                    obj.erp_name = self.selectedPuchaseOrderDict!.erpName!
                                                    obj.po_number = self.selectedPuchaseOrderDict!.poNumber!
                                                    obj.po_unique_id = self.selectedPuchaseOrderDict!.uniqueID!
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
                                                    obj.product_flow_type = "directSerialScanEntry"
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
                if viewControllers[viewControllers.count-2] is MWPuchaseOrderListViewController || viewControllers[viewControllers.count-2] is DashboardViewController {
                    
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
    
    @IBAction func checkUncheckButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if selectedScannedSerialListArray.count > 0 {
            //,,,sbm1
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialViewController") as! MWReceivingSerialViewController
            controller.delegate = self
            controller.flowType = flowType //"directSerialScan", "viaManualLot"
            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict
            controller.selectedScannedSerialListArray = selectedScannedSerialListArray
            self.navigationController?.pushViewController(controller, animated: true)
            
            /*
            self.showConfirmationViewController(confirmationMsg: "Are you sure to submit".localized(), alertStatus: "Alert1")
            self.showConfirmationViewController(confirmationMsg: "One or more unallocated serials are available! Please either remove those serials or allocate them before submit.".localized(), alertStatus: "Alert2")//false
            self.showConfirmationViewController(confirmationMsg: "Do you want to process another line item for odoo?".localized(), alertStatus: "Alert3")
            self.showConfirmationViewController(confirmationMsg: "Demand quantity of Aspirin in odoo does not match with the allocated serials! Do you want to add more serials for this item?".localized(), alertStatus: "Alert4")
            */
            //,,,sbm1
        }
        else {
            let message = "Please select atleast one serial".localized()
            Utility.showPopup(Title: Warning, Message: message, InViewC: self)
        }
        
    }
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        self.showMWReceivingSelectionViewController()
    }
    //MARK: - End
}

//MARK: - MWReceivingSelectionViewControllerDelegate
extension MWReceivingSerialListViewController: MWReceivingSelectionViewControllerDelegate {
    func showMWReceivingSelectionViewController() {
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSelectionViewController") as! MWReceivingSelectionViewController
        controller.delegate = self
        controller.previousController = "MWReceivingSerialListViewController"
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
    
    func didClickManually(){
    }
    func didClickCrossButton() {
    }
}
//MARK: - End

//MARK: - MWMultiScanViewControllerDelegate
extension MWReceivingSerialListViewController : MWMultiScanViewControllerDelegate {
    
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
extension MWReceivingSerialListViewController : MWSingleScanViewControllerDelegate {
    
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
        
        self.getDBData()
        //,,,sbm2
    }
    func backFromSingleScan() {
    }
}
//MARK: - End

//MARK: - MWReceivingSerialViewControllerDelegate
extension MWReceivingSerialListViewController: MWReceivingSerialViewControllerDelegate {
    func reloadSelectedScannedSerialListArray(selectedScannedArray:[MWReceivingManuallyLotOrScanSerialBaseModel]) {
        selectedScannedSerialListArray = selectedScannedArray
        listTableView.reloadData()
    }
}
//MARK: - End


// MARK: - MWConfirmationView
extension MWReceivingSerialListViewController: MWConfirmationViewDelegate {
    func showConfirmationViewController(confirmationMsg:String, alertStatus:String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MWConfirmationViewController") as! MWConfirmationViewController
        controller.confirmationMsg = confirmationMsg
        controller.alertStatus = alertStatus
        if alertStatus == "Alert2" {
            controller.isCancelButtonShow = false
        }else {
            controller.isCancelButtonShow = true
        }
        
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - MWConfirmationViewDelegate
    func doneButtonPressed(alertStatus:String) {
        self.navigationController?.popViewController(animated: true)
    }
    func cancelButtonPressed(alertStatus:String) {
        
    }
    //MARK: - End
}
// MARK: - End

//MARK: - Tableview Delegate and Datasource
extension MWReceivingSerialListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return scannedSerialListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWReceivingViewTableCell") as! MWReceivingViewTableCell
        
        if let productsModel = scannedSerialListArray[indexPath.section] as MWReceivingManuallyLotOrScanSerialBaseModel? {
            cell.serialNumberLabel.text = ""
            if let serialNumber = productsModel.serialNumber {
                cell.serialNumberLabel.text =  serialNumber
            }
            cell.productLotNumberLabel.text = ""
            if let lotNumber = productsModel.lotNumber {
                cell.productLotNumberLabel.text =  "Lot #:".localized() + "  " + lotNumber
            }
            cell.productNameLabel.text = ""
            if let productName = productsModel.productName {
                cell.productNameLabel.text = productName
            }
            
            cell.productTrackingLabel.text = ""
            if let productTracking = productsModel.productTracking {
                cell.productTrackingLabel.text = "Type:".localized() + "  " + productTracking
            }
            
            if selectedScannedSerialListArray.contains(where: {$0.serialNumber == productsModel.serialNumber && $0.productCode == productsModel.productCode}) {
                cell.checkUncheckButton.isSelected = true
            }else {
                cell.checkUncheckButton.isSelected = false
            }
        }
        
        if cell.checkUncheckButton.isSelected {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameLabel.textColor = UIColor.white
            cell.serialNumberLabel.textColor = UIColor.white
            
            cell.productNameTitleLabel.textColor = UIColor.white
            cell.serialNumberTitleLabel.textColor = UIColor.white
            
            cell.productTrackingLabel.textColor = UIColor.white
            cell.productLotNumberLabel.textColor = UIColor.white
        }else {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
            
            cell.productNameLabel.textColor = Utility.hexStringToUIColor(hex: "276A44") //072144
            cell.serialNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44") //719898
            cell.serialNumberTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productTrackingLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.productLotNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
        }
        
        cell.checkUncheckButton.tag = indexPath.section
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! MWReceivingViewTableCell
        cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
        
        if cell.checkUncheckButton.isSelected {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameLabel.textColor = UIColor.white
            cell.serialNumberLabel.textColor = UIColor.white
            
            cell.productNameTitleLabel.textColor = UIColor.white
            cell.serialNumberTitleLabel.textColor = UIColor.white
            
            cell.productTrackingLabel.textColor = UIColor.white
            cell.productLotNumberLabel.textColor = UIColor.white
            
        }else {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
            
            cell.productNameLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.serialNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.serialNumberTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productTrackingLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.productLotNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
        }
        
        let selectedPuchaseOrderDict = scannedSerialListArray[indexPath.section]
        let serialNumber = selectedPuchaseOrderDict.serialNumber
        let productCode = selectedPuchaseOrderDict.productCode
        if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == serialNumber && $0.productCode == productCode}) {
            selectedScannedSerialListArray.append(selectedPuchaseOrderDict)
        }else {
            let indexNO = selectedScannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode})
            selectedScannedSerialListArray.remove(at: indexNO!)
        }
    }
}
//MARK: - End

//MARK: - Tableview Cell
class MWReceivingViewTableCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var serialNumberTitleLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    @IBOutlet weak var productNameTitleLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productLotNumberLabel: UILabel!
    @IBOutlet weak var productTrackingLabel: UILabel!

    @IBOutlet weak var checkUncheckButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        serialNumberLabel.text = ""
        productNameLabel.text = ""

        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End
