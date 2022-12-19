//
//  MWPickingSerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 08/11/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm3

import UIKit

class MWPickingSerialListViewController: BaseViewController {
    @IBOutlet weak var listTableView: UITableView!
    
    var flowType: String = "" //"directSerialScan", "viaManualLot"
    var selectedSaleOrderDict: MWSaleOrderModel?
    var selectedLineItemsListArray : [MWPickingViewItemsModel] = []
    var scannedSerialListArray = [MWPickingManuallyLotOrScanSerialBaseModel]() //MWPickingScanSerialBaseModel
    var selectedScannedSerialListArray : [MWPickingManuallyLotOrScanSerialBaseModel] = []
    var reScanEnable = false
    
    //MARK: - ViewLifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        self.listLineItemsBySaleOrderWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func getDBData() {
        //,,,sbm2
        selectedLineItemsListArray = []
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)'")
            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)'")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                selectedLineItemsListArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    selectedLineItemsListArray.append(cdModel.convertCoreDataRequestsToMWPickingViewItemsModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            selectedLineItemsListArray = []
        }
        //,,,sbm2

        
        //,,,sbm2
        var filterSerialLineItemsListArray : [MWPickingManuallyLotOrScanSerialBaseModel] = []
        var filterLotLineItemsListArray : [MWPickingManuallyLotOrScanSerialBaseModel] = []
        for model in selectedLineItemsListArray {
            var erpUUID = ""
            if let val = model.erpUUID {
                erpUUID = val
            }
            var erpName = ""
            if let val = model.erpName {
                erpName = val
            }
            var soNumber = ""
            if let val = model.soNumber {
                soNumber = val
            }
            var soUniqueID = ""
            if let val = model.soUniqueID {
                soUniqueID = val
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
            var productDeliveredQuantity = ""
            if let val = model.productDeliveredQuantity {
                productDeliveredQuantity = val
            }
            var productDemandQuantity = ""
            if let val = model.productDemandQuantity {
                productDemandQuantity = val
            }
            var productQtyToDeliver = ""
            if let val = model.productQtyToDeliver {
                productQtyToDeliver = val
            }
            var productTracking = ""
            if let val = model.productTracking {
                productTracking = val
            }
            
            
            let mwPickingManuallyLotOrScanSerialBaseModel = MWPickingManuallyLotOrScanSerialBaseModel(erpUUID: erpUUID,
                                                                                  erpName: erpName,
                                                                                  soNumber: soNumber,
                                                                                  soUniqueID: soUniqueID,
                                                                                  productUniqueID: productUniqueID,
                                                                                  productName: productName,
                                                                                  productCode: productCode,
                                                                                  productDeliveredQuantity: productDeliveredQuantity,
                                                                                  productDemandQuantity: productDemandQuantity,
                                                                                  productQtyToDeliver: productQtyToDeliver,
                                                                                  productTracking: productTracking,
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
                filterLotLineItemsListArray.append(mwPickingManuallyLotOrScanSerialBaseModel)//,,,sbm2-1
            }else if productTracking == "serial" {
                filterSerialLineItemsListArray.append(mwPickingManuallyLotOrScanSerialBaseModel)
            }
        }
        //,,,sbm2
        
        //**********************************************************************************************************************************************************//
        
        //Serial Based Line Item
        //,,,sbm2
        var scanProductForSerialArray = [MWPickingScanProductModel]()
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='serial'")
            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='serial'")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                scanProductForSerialArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    scanProductForSerialArray.append(cdModel.convertCoreDataRequestsToMWPickingScanProductModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            scanProductForSerialArray = []
        }
        //,,,sbm2
        
        var gtinArray:[String] = []
        for scanProductModel in scanProductForSerialArray {
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
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(lineItemModel.erpUUID!)' and so_number='\(lineItemModel.soNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and product_tracking='serial'")
                        let predicate = NSPredicate(format:"so_number='\(lineItemModel.soNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and product_tracking='serial'")
                        //,,,sbm5
                        
                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
                            let obj = MW_PickingManualLotOrScanSerial(context: PersistenceService.context)
                            obj.id = MWPickingManualLotOrScanSerial.getAutoIncrementId()
                            obj.erp_uuid = lineItemModel.erpUUID
                            obj.erp_name = lineItemModel.erpName
                            obj.so_number = lineItemModel.soNumber
                            obj.so_unique_id = lineItemModel.soUniqueID
                            obj.product_unique_id = lineItemModel.productUniqueID
                            obj.product_name = lineItemModel.productName
                            obj.product_code = lineItemModel.productCode
                            obj.product_delivered_qty = lineItemModel.productDeliveredQuantity
                            obj.product_demand_qty = lineItemModel.productDemandQuantity
                            obj.product_qty_to_deliver = lineItemModel.productQtyToDeliver
                            obj.product_tracking = "serial"
                            obj.lot_number = lot
                            obj.quantity = "1"
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
                                obj.product_delivered_qty = lineItemModel.productDeliveredQuantity
                                obj.product_demand_qty = lineItemModel.productDemandQuantity
                                obj.product_qty_to_deliver = lineItemModel.productQtyToDeliver
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
        selectedScannedSerialListArray = []
        
        for gtin in gtinArray {
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(gtin)' and product_tracking='serial'")
                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(gtin)' and product_tracking='serial'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    
                }else {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        if cdModel.is_edited == true {
                            if !reScanEnable {
                                if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == cdModel.serial_number && $0.productCode == cdModel.product_code}) {
                                    selectedScannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWPickingManuallyLotOrScanSerialBaseModel())
                                }
                            }
                        }
                        scannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWPickingManuallyLotOrScanSerialBaseModel())
                    })
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
        //,,,sbm2
        
        //**********************************************************************************************************************************************************//
        
        //,,,sbm2-1
        //Lot Based Line Item
        var scanProductForLotArray = [MWPickingScanProductModel]()
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot'")
            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot'")
            //,,,sbm5

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                scanProductForLotArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    scanProductForLotArray.append(cdModel.convertCoreDataRequestsToMWPickingScanProductModel())
                })
            }
        }catch let error{
            print(error.localizedDescription)
            scanProductForLotArray = []
        }
                
        var gtinArray1:[String] = []
        for scanProductModel in scanProductForLotArray {
            if let gtin = scanProductModel.GTIN {
                if !gtinArray1.contains(gtin) {
                    gtinArray1.append(gtin)
                }

                let filteredArray = filterLotLineItemsListArray.filter { $0.productCode!.localizedCaseInsensitiveContains(gtin) }
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
                    var quantity = ""
                    if let qty = scanProductModel.quantity {
                        quantity = qty
                    }

                    do{
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(lineItemModel.erpUUID!)' and so_number='\(lineItemModel.soNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        let predicate = NSPredicate(format:"so_number='\(lineItemModel.soNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        //,,,sbm5

                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
//                            let filteredArray = scanProductForLotArray.filter { $0.lotNumber == lot && $0.productTracking == "lot" && $0.serialNumber == serial }
                            
                            let obj = MW_PickingManualLotOrScanSerial(context: PersistenceService.context)
                            obj.id = MWPickingManualLotOrScanSerial.getAutoIncrementId()
                            obj.erp_uuid = lineItemModel.erpUUID
                            obj.erp_name = lineItemModel.erpName
                            obj.so_number = lineItemModel.soNumber
                            obj.so_unique_id = lineItemModel.soUniqueID
                            obj.product_unique_id = lineItemModel.productUniqueID
                            obj.product_name = lineItemModel.productName
                            obj.product_code = lineItemModel.productCode
                            obj.product_delivered_qty = lineItemModel.productDeliveredQuantity
                            obj.product_demand_qty = lineItemModel.productDemandQuantity
                            obj.product_qty_to_deliver = lineItemModel.productQtyToDeliver
                            obj.product_tracking = "lot"
                            obj.lot_number = lot
//                            obj.quantity = String(filteredArray.count)
                            obj.quantity = quantity
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
                                if reScanEnable {
                                    let scanQty: Int = Int(quantity)!
                                    obj.quantity = String(scanQty)
                                }
                                
                                obj.product_delivered_qty = lineItemModel.productDeliveredQuantity
                                obj.product_demand_qty = lineItemModel.productDemandQuantity
                                obj.product_qty_to_deliver = lineItemModel.productQtyToDeliver
                                PersistenceService.saveContext()
                            }
                        }
                    }catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        for gtin in gtinArray1 {
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(gtin)' and product_tracking='lot'")
                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(gtin)' and product_tracking='lot'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {

                }else {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        if cdModel.is_edited == true {
                            
                            if !reScanEnable {
                                if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == cdModel.serial_number && $0.productCode == cdModel.product_code && $0.lotNumber == cdModel.lot_number}) {
                                    selectedScannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWPickingManuallyLotOrScanSerialBaseModel())
                                }
                            }
                        }
                        scannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWPickingManuallyLotOrScanSerialBaseModel())
                    })
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
        
        reScanEnable = false
        //,,,sbm2-1

        self.listTableView.reloadData()
    }
    //MARK: - End
    
    //MARK: - WebserviceCall
    func listLineItemsBySaleOrderWebServiceCall() {
        /*
         List Line Items By Sale Order
         4032b2bb-3b29-4fe1-b384-4a76b30101eb
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-line-items-by-sale-order
         
        POST
         {
                 "action_uuid": "4032b2bb-3b29-4fe1-b384-4a76b30101eb",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "so_id": "184"
         }
        */
        
        /*
         Response Data: Optional({
             data = "[{\"product_id\": \"1405\", \"product_code\": \"00303160123016\", \"product_name\": \"00303160123016 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_delivered_quantity\": \"0.0\", \"product_qty_to_deliver\": \"100.0\"}, {\"product_id\": \"1406\", \"product_code\": \"00303160123801\", \"product_name\": \"00303160123801 - Serial Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"serial\", \"product_demand_quantity\": \"100.0\", \"product_delivered_quantity\": \"0.0\", \"product_qty_to_deliver\": \"100.0\"}, {\"product_id\": \"1403\", \"product_code\": \"00349908118142\", \"product_name\": \"00349908118142 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_delivered_quantity\": \"0.0\", \"product_qty_to_deliver\": \"100.0\"}, {\"product_id\": \"1404\", \"product_code\": \"10349908118149\", \"product_name\": \"10349908118149 - Lot Product\", \"product_uom_id\": \"1\", \"product_tracking\": \"lot\", \"product_demand_quantity\": \"100.0\", \"product_delivered_quantity\": \"0.0\", \"product_qty_to_deliver\": \"100.0\"}]";
             message = "Successfully executed.";
             status = success;
             "status_code" = 1;
         })
         */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsBySaleOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = self.selectedSaleOrderDict!.erpUUID!
        
        //,,,sbm5
        /*
        if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue {
            requestDict["so_id"] = self.selectedSaleOrderDict!.uniqueID!
        }
        else if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
//            requestDict["so_uuid"] = self.selectedSaleOrderDict!.uniqueID!
            requestDict["so_id"] = self.selectedSaleOrderDict!.uniqueID!
        }*/
        
        requestDict["so_id"] = self.selectedSaleOrderDict!.uniqueID!
        //,,,sbm5
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListLineItemsBySaleOrder", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
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
//                                if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue { //,,,sbm5
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
                                        var product_delivered_quantity = ""
//                                        if let value = dict["product_delivered_quantity"] as? Int {
                                        if let value = dict["product_delivered_quantity"] as? String {
//                                            product_delivered_quantity = String(value)
                                            product_delivered_quantity = value
                                        }
                                        var product_qty_to_deliver = ""
//                                        if let value = dict["product_qty_to_deliver"] as? Int {
                                        if let value = dict["product_qty_to_deliver"] as? String {
//                                            product_qty_to_deliver = String(value)
                                            product_qty_to_deliver = value
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
                                        var transaction_type = ""
                                        if let value = dict["transaction_type"] as? String {
                                            transaction_type = value
                                        }
                                        
                                        //,,,sbm2
                                        do{
                                            //,,,sbm5
                                            //let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                            //,,,sbm5
                     
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_PickingLineItem(context: PersistenceService.context)
                                                obj.id = MWPickingLineItem.getAutoIncrementId()
                                                obj.erp_uuid = self.selectedSaleOrderDict!.erpUUID!
                                                obj.erp_name = self.selectedSaleOrderDict!.erpName!
                                                obj.so_number = self.selectedSaleOrderDict!.soNumber!
                                                obj.so_unique_id = self.selectedSaleOrderDict!.uniqueID!
                                                obj.product_unique_id = product_id
                                                obj.product_name = product_name
                                                obj.product_code = product_code
                                                obj.product_delivered_qty = product_delivered_quantity
                                                obj.product_demand_qty = product_demand_quantity
                                                obj.product_qty_to_deliver = product_qty_to_deliver
                                                obj.product_tracking = product_tracking
                                                obj.transaction_type = transaction_type
                                                obj.is_edited = false
                                                obj.product_flow_type = "directSerialScanEntry"
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.product_delivered_qty = product_delivered_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_deliver = product_qty_to_deliver
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                
                                //,,,sbm5
                                /*
                                }
                                else if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
                                    for dict in dataArray {
                                        var product_id = ""
                                        if let value = dict["product_id"] as? String {
                     product_id = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_delivered_quantity = ""
                                        if let value = dict["product_delivered_quantity"] as? String {
                                            product_delivered_quantity = value
                                        }
                                        var product_qty_to_deliver = ""
                                        if let value = dict["product_qty_to_deliver"] as? Int {
                                            product_qty_to_deliver = String(value)
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
                                        var transaction_type = ""
                                        if let value = dict["transaction_type"] as? String {
                                            transaction_type = value
                                        }
                                        
                                        
                                        //,,,sbm2
                                        do{
                                            //,,,sbm5
                                            //let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                            //,,,sbm5
                                 
                                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                            if fetchRequestResultArray.isEmpty {
                                                let obj = MW_PickingLineItem(context: PersistenceService.context)
                                                obj.id = MWPickingLineItem.getAutoIncrementId()
                                                obj.erp_uuid = self.selectedSaleOrderDict!.erpUUID!
                                                obj.erp_name = self.selectedSaleOrderDict!.erpName!
                                                obj.so_number = self.selectedSaleOrderDict!.soNumber!
                                                obj.so_unique_id = self.selectedSaleOrderDict!.uniqueID!
                                                obj.product_unique_id = product_id
                                                obj.product_name = product_name
                                                obj.product_code = product_code
                                                obj.product_delivered_qty = product_delivered_quantity
                                                obj.product_demand_qty = product_demand_quantity
                                                obj.product_qty_to_deliver = product_qty_to_deliver
                                                obj.product_tracking = product_tracking
                                                obj.transaction_type = transaction_type
                                                obj.is_edited = false
                                                obj.product_flow_type = "directSerialScanEntry"
                                                PersistenceService.saveContext()
                                            }
                                            else {
                                                if let obj = fetchRequestResultArray.first {
                                                    obj.product_delivered_qty = product_delivered_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_deliver = product_qty_to_deliver
                                                    PersistenceService.saveContext()
                                                }
                                            }
                                        }catch let error {
                                            print(error.localizedDescription)
                                        }
                                        //,,,sbm2
                                    }
                                }*/
                            //,,,sbm5
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
                    //,,,sbm5
                    /*
                    var path = ""
                    if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
                        //TTRx
                        path = Bundle.main.path(forResource: "MWListSaleOrders_ttrx", ofType: "json")!
                    }else {
//                        path = Bundle.main.path(forResource: "MW_list-line-items-by-sale-order_odoo", ofType: "json")!
                        path = Bundle.main.path(forResource: "MW_list-line-items-by-sale-order_odoo_Serial", ofType: "json")!
                    }*/
                    
                    let path = Bundle.main.path(forResource: "MW_list-line-items-by-sale-order_odoo_Serial", ofType: "json")!
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
//                                                print("dataArray....>>>>>",dataArray)
//                                    if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue { //,,,sbm5
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
                                            var product_delivered_quantity = ""
                                            if let value = dict["product_delivered_quantity"] as? String {
                                                product_delivered_quantity = value
                                            }
                                            var product_qty_to_deliver = ""
                                            if let value = dict["product_qty_to_deliver"] as? String {
                                                product_qty_to_deliver = value
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
                                            var transaction_type = ""
                                            if let value = dict["transaction_type"] as? String {
                                                transaction_type = value
                                            }
                                            
                                            //,,,sbm2
                                            do{
                                                //,,,sbm5
//                                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                                //,,,sbm5

                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_PickingLineItem(context: PersistenceService.context)
                                                    obj.id = MWPickingLineItem.getAutoIncrementId()
                                                    obj.erp_uuid = self.selectedSaleOrderDict!.erpUUID!
                                                    obj.erp_name = self.selectedSaleOrderDict!.erpName!
                                                    obj.so_number = self.selectedSaleOrderDict!.soNumber!
                                                    obj.so_unique_id = self.selectedSaleOrderDict!.uniqueID!
                                                    obj.product_unique_id = product_id
                                                    obj.product_name = product_name
                                                    obj.product_code = product_code
                                                    obj.product_delivered_qty = product_delivered_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_deliver = product_qty_to_deliver
                                                    obj.product_tracking = product_tracking
                                                    obj.transaction_type = transaction_type
                                                    obj.is_edited = false
                                                    obj.product_flow_type = "directSerialScanEntry"
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.product_delivered_qty = product_delivered_quantity
                                                        obj.product_demand_qty = product_demand_quantity
                                                        obj.product_qty_to_deliver = product_qty_to_deliver
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    
                                    //,,,sbm5
                                    /*
                                    }
                                    else if self.selectedSaleOrderDict!.erpUUID! == MWStaticData.ERP_UUID.ttrx.rawValue {
                                        for dict in dataArray {
                                            var product_id = ""
                                            if let value = dict["product_id"] as? String {
                                                product_id = value
                                            }
                                            var product_demand_quantity = ""
                                            if let value = dict["product_demand_quantity"] as? String {
                                                product_demand_quantity = value
                                            }
                                            var product_delivered_quantity = ""
                                            if let value = dict["product_delivered_quantity"] as? String {
                                                product_delivered_quantity = value
                                            }
                                            var product_qty_to_deliver = ""
                                            if let value = dict["product_qty_to_deliver"] as? Int {
                                                product_qty_to_deliver = String(value)
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
                                            var transaction_type = ""
                                            if let value = dict["transaction_type"] as? String {
                                                transaction_type = value
                                            }
                                            
                                            //,,,sbm2
                                            do{
                                                //,,,sbm5
                                                //let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(product_code)'")
                                                //,,,sbm5
                                     
                                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                                                if fetchRequestResultArray.isEmpty {
                                                    let obj = MW_PickingLineItem(context: PersistenceService.context)
                                                    obj.id = MWPickingLineItem.getAutoIncrementId()
                                                    obj.erp_uuid = self.selectedSaleOrderDict!.erpUUID!
                                                    obj.erp_name = self.selectedSaleOrderDict!.erpName!
                                                    obj.so_number = self.selectedSaleOrderDict!.soNumber!
                                                    obj.so_unique_id = self.selectedSaleOrderDict!.uniqueID!
                                                    obj.product_unique_id = product_id
                                                    obj.product_name = product_name
                                                    obj.product_code = product_code
                                                    obj.product_delivered_qty = product_delivered_quantity
                                                    obj.product_demand_qty = product_demand_quantity
                                                    obj.product_qty_to_deliver = product_qty_to_deliver
                                                    obj.product_tracking = product_tracking
                                                    obj.transaction_type = transaction_type
                                                    obj.is_edited = false
                                                    obj.product_flow_type = "directSerialScanEntry"
                                                    PersistenceService.saveContext()
                                                }
                                                else {
                                                    if let obj = fetchRequestResultArray.first {
                                                        obj.product_delivered_qty = product_delivered_quantity
                                                        obj.product_demand_qty = product_demand_quantity
                                                        obj.product_qty_to_deliver = product_qty_to_deliver
                                                        PersistenceService.saveContext()
                                                    }
                                                }
                                            }catch let error {
                                                print(error.localizedDescription)
                                            }
                                            //,,,sbm2
                                        }
                                    }*/
                                    //,,,sbm5
                                    
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
                if viewControllers[viewControllers.count-2] is MWSaleOrderListViewController || viewControllers[viewControllers.count-2] is DashboardViewController {
                    
                    var count = 0
                    do{
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")
                        let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")
                        //,,,sbm5
                        
                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                        count = fetchRequestResultArray.count
                    }catch let error {
                        print(error.localizedDescription)
                    }
                    
                    
                    if count > 0 {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MWPickingCancelViewController") as! MWPickingCancelViewController
                        self.navigationController?.pushViewController(controller, animated: false)
                    }
                    else {
                        MWPicking.removeAllMW_PickingEntityDataFromDB()//,,,sbm2
                        navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }//,,,sbm2
    
//    @IBAction func checkUncheckButtonPressed(_ sender: UIButton) {
//        if sender.isSelected {
//            sender.isSelected = false
//        }else {
//            sender.isSelected = true
//        }
//    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if selectedScannedSerialListArray.count > 0 {
            //,,,sbm1
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSerialViewController") as! MWPickingSerialViewController
            controller.delegate = self
            controller.flowType = flowType //"directSerialScan", "viaManualLot"
            controller.selectedSaleOrderDict = selectedSaleOrderDict
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
        self.showMWPickingSelectionViewController()
    }
    //MARK: - End
}

//MARK: - MWPickingSelectionViewControllerDelegate
extension MWPickingSerialListViewController: MWPickingSelectionViewControllerDelegate {
    func showMWPickingSelectionViewController() {
        let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSelectionViewController") as! MWPickingSelectionViewController
        controller.delegate = self
        controller.previousController = "MWPickingSerialListViewController"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
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
    }
    func didClickCrossButton() {
    }
}
//MARK: - End

//MARK: - MWMultiScanViewControllerDelegate
extension MWPickingSerialListViewController : MWMultiScanViewControllerDelegate {
    
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
extension MWPickingSerialListViewController : MWSingleScanViewControllerDelegate {
    
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
        
        //,,,sbm5
        var scanProductArray:[[String: Any]] = []
        if self.selectedSaleOrderDict?.erpName == "odoo" {
             scanProductArray = Utility.createSampleScanProduct()//,,,sbm2 temp
        }else {
             scanProductArray = Utility.createSampleScanProduct_TTRX()//,,,sbm2 temp
        }
        //,,,sbm5
        
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
            
            //,,,sbm2-1
            if product_tracking == "serial" {
                do{
                    //,,,sbm5
//                    let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
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
                /*
//                do{
//                    let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
//                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
//                    if fetchRequestResultArray.isEmpty {
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
//                    }
//                }catch let error {
//                    print(error.localizedDescription)
//                }
                
                */
                
                do{
                    //,,,sbm5
//                    let predicate = NSPredicate(format:"erp_uuid='\(MWStaticData.ERP_UUID.odoo.rawValue)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
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
        
        reScanEnable = true
        self.getDBData()
        //,,,sbm2
    }
    func backFromSingleScan() {
    }
}
//MARK: - End

//MARK: - MWPickingSerialViewControllerDelegate
extension MWPickingSerialListViewController: MWPickingSerialViewControllerDelegate {
    func reloadSelectedScannedSerialListArray(selectedScannedArray:[MWPickingManuallyLotOrScanSerialBaseModel]) {
        selectedScannedSerialListArray = selectedScannedArray
        
        for i in 0..<self.selectedScannedSerialListArray.count {
            let scannedModel:MWPickingManuallyLotOrScanSerialBaseModel = self.selectedScannedSerialListArray[i]
            let quantity = scannedModel.quantity
            let productCode = scannedModel.productCode
            let serialNumber = scannedModel.serialNumber
            let lotNumber = scannedModel.lotNumber
            let productTracking = scannedModel.productTracking

            if productTracking == "lot" {
                let indexNO = scannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber})
                var productModel:MWPickingManuallyLotOrScanSerialBaseModel = scannedSerialListArray[indexNO!]
                productModel.quantity = quantity
                scannedSerialListArray[indexNO!] = productModel
            }
        }//,,,sbm2-1
        
        listTableView.reloadData()
    }
}
//MARK: - End

// MARK: - MWConfirmationView
extension MWPickingSerialListViewController: MWConfirmationViewDelegate {
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
extension MWPickingSerialListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return scannedSerialListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWPickingViewTableCell") as! MWPickingViewTableCell
        
        if let productsModel = scannedSerialListArray[indexPath.section] as MWPickingManuallyLotOrScanSerialBaseModel? {
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
            cell.quantityLabel.isHidden = true
            cell.quantityLabel.text = ""
            
            cell.serialNumberStackView.isHidden = false
            
            var producttracking = ""
            if let productTracking = productsModel.productTracking {
                cell.productTrackingLabel.text = "Type:".localized() + "  " + productTracking
                producttracking = productTracking
            }
            
            if producttracking == "serial" {
                cell.quantityLabel.isHidden = true
                
                if selectedScannedSerialListArray.contains(where: {$0.serialNumber == productsModel.serialNumber && $0.productCode == productsModel.productCode}) {
                    cell.checkUncheckButton.isSelected = true
                }else {
                    cell.checkUncheckButton.isSelected = false
                }
            }
            else {
                cell.quantityLabel.isHidden = false
                cell.serialNumberStackView.isHidden = true
                
                if let quantity = productsModel.quantity {
                    cell.quantityLabel.text = "Quantity:".localized() + "  " + quantity
                }
                
                if selectedScannedSerialListArray.contains(where: {$0.serialNumber == productsModel.serialNumber && $0.productCode == productsModel.productCode && $0.lotNumber == productsModel.lotNumber}) {
                    cell.checkUncheckButton.isSelected = true
                }else {
                    cell.checkUncheckButton.isSelected = false
                }
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
            
            cell.quantityLabel.textColor = UIColor.white
        }else {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
            
            cell.productNameLabel.textColor = Utility.hexStringToUIColor(hex: "276A44") //072144
            cell.serialNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44") //719898
            cell.serialNumberTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productTrackingLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.productLotNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.quantityLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
        }
        
        cell.checkUncheckButton.tag = indexPath.section
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! MWPickingViewTableCell
        cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
        
        if cell.checkUncheckButton.isSelected {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameLabel.textColor = UIColor.white
            cell.serialNumberLabel.textColor = UIColor.white
            
            cell.productNameTitleLabel.textColor = UIColor.white
            cell.serialNumberTitleLabel.textColor = UIColor.white
            
            cell.productTrackingLabel.textColor = UIColor.white
            cell.productLotNumberLabel.textColor = UIColor.white
            
            cell.quantityLabel.textColor = UIColor.white
            
        }else {
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
            
            cell.productNameLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.serialNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productNameTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.serialNumberTitleLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.productTrackingLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            cell.productLotNumberLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
            
            cell.quantityLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
        }
        
        let selectedSaleOrderDict = scannedSerialListArray[indexPath.section]
        let serialNumber = selectedSaleOrderDict.serialNumber
        let productCode = selectedSaleOrderDict.productCode
        let lotNumber = selectedSaleOrderDict.lotNumber
        
        var producttracking = ""
        if let productTracking = selectedSaleOrderDict.productTracking {
            producttracking = productTracking
        }
        
        if producttracking == "serial" {
            if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == serialNumber && $0.productCode == productCode}) {
                selectedScannedSerialListArray.append(selectedSaleOrderDict)
            }else {
                let indexNO = selectedScannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode})
                selectedScannedSerialListArray.remove(at: indexNO!)
            }
        }
        else {
            if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber}) {
                selectedScannedSerialListArray.append(selectedSaleOrderDict)
            }else {
                let indexNO = selectedScannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber})
                selectedScannedSerialListArray.remove(at: indexNO!)
            }
        }
    }
}
//MARK: - End

//MARK: - Tableview Cell
class MWPickingViewTableCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var serialNumberStackView: UIStackView!
    @IBOutlet weak var serialNumberTitleLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    @IBOutlet weak var productNameTitleLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productLotNumberLabel: UILabel!
    @IBOutlet weak var productTrackingLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

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
