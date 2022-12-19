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
    var serialHeaderListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
    var reScanEnable = false
    var filterLineItemsListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []

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
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")
            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")
            //,,,sbm5
            
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
        var filterLotLineItemsListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
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
                filterLotLineItemsListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)//,,,sbm2-1
            }else if productTracking == "serial" {
                filterSerialLineItemsListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
            }
        }
        //,,,sbm2
        
        //**********************************************************************************************************************************************************//
        
        //Serial Based Line Item
        //,,,sbm2
        var scanProductForSerialArray = [MWReceivingScanProductModel]()
        do{
            //,,,sbm5
            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")
            //,,,sbm5

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                scanProductForSerialArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    scanProductForSerialArray.append(cdModel.convertCoreDataRequestsToMWReceivingScanProductModel())
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
                        let predicate = NSPredicate(format:"po_number='\(lineItemModel.poNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and product_tracking='serial'")
                        //,,,sbm5
                        
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
                            obj.product_tracking = "serial"
                            obj.product_uom_id = lineItemModel.productUomID
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
        selectedScannedSerialListArray = []

        for gtin in gtinArray {
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(gtin)' and product_tracking='serial'")
                let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(gtin)' and product_tracking='serial'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    
                }else {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        if cdModel.is_edited == true {
                            if !reScanEnable {
                                if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == cdModel.serial_number && $0.productCode == cdModel.product_code}) {
                                    selectedScannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                                }
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
        
        //**********************************************************************************************************************************************************//
        
        //,,,sbm2-1
        //Lot Based Line Item
        var scanProductForLotArray = [MWReceivingScanProductModel]()
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot'")
//            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot'")
            
            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")

            //,,,sbm5

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                scanProductForLotArray = []
            }else {
                fetchRequestResultArray.forEach({ (cdModel) in
                    scanProductForLotArray.append(cdModel.convertCoreDataRequestsToMWReceivingScanProductModel())
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
//                        let predicate = NSPredicate(format:"erp_uuid='\(lineItemModel.erpUUID!)' and po_number='\(lineItemModel.poNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        let predicate = NSPredicate(format:"po_number='\(lineItemModel.poNumber!)' and product_code='\(lineItemModel.productCode!)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                        //,,,sbm5
                        
                        let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                        if fetchRequestResultArray.isEmpty {
//                            let filteredArray = scanProductForLotArray.filter { $0.lotNumber == lot && $0.productTracking == "lot" && $0.serialNumber == serial }
                            
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
                            obj.product_tracking = "lot"
                            obj.product_uom_id = lineItemModel.productUomID
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
                                
                                obj.product_received_qty = lineItemModel.productReceivedQuantity
                                obj.product_demand_qty = lineItemModel.productDemandQuantity
                                obj.product_qty_to_receive = lineItemModel.productQtyToReceive
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
//                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(gtin)' and product_tracking='lot'")
                let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(gtin)' and product_tracking='lot'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {

                }else {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        if cdModel.is_edited == true {
                            
                            if !reScanEnable {
                                if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == cdModel.serial_number && $0.productCode == cdModel.product_code && $0.lotNumber == cdModel.lot_number}) {
                                    selectedScannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
                                }
                            }
                        }
                        scannedSerialListArray.append(cdModel.convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel())
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
    
    func selectedDataSave(){
        //,,,sbm2
        selectedLineItemsListArray = []
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")
            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)'")
            //,,,sbm5
            
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
            
            
            
            filterLineItemsListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
            
        }
        self.listTableView.reloadData()
    }
    //MARK: - End
    
    //MARK: - WebserviceCall
    func listLineItemsByPurchaseOrderWebServiceCall() {
       
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsByPurchaseOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = self.selectedPuchaseOrderDict!.erpUUID!
   
        requestDict["po_id"] = self.selectedPuchaseOrderDict!.uniqueID!
        //,,,sbm5

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
//                                if self.selectedPuchaseOrderDict!.erpUUID! == MWStaticData.ERP_UUID.odoo.rawValue {//,,,sbm5
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
                                            //,,,sbm5
//                                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(product_code)'")
                                            //,,,sbm5
                                            
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
    func validateReceivingLotSerials(){
      
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"validateReceivingLotSerials")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = self.selectedPuchaseOrderDict!.erpUUID!
        requestDict["po_id"] = self.selectedPuchaseOrderDict!.uniqueID!
        
        //https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/validate-receiving-lot-serial
        
        var arr = [[String:Any]]()
        
        let duplicateProductCodeArray = selectedScannedSerialListArray.map { $0.productCode }
        var productCodeArray : [String] = []

        for value in duplicateProductCodeArray {
            if !productCodeArray.contains(value!) {
                productCodeArray.append(value!)
            }
        }
        for productCode in productCodeArray {
            let filtered = selectedScannedSerialListArray.filter { $0.productCode == productCode }
            if filtered.count > 0 {
                let mwReceivingManuallyLotOrScanSerialBaseModel = filtered[0]
                
                var dict1:[String:Any] = [:]
                var arr1 = [[String:Any]]()
                if let productCode = mwReceivingManuallyLotOrScanSerialBaseModel.productCode {
                    dict1["product_code"] = productCode
                }
                if let productName = mwReceivingManuallyLotOrScanSerialBaseModel.productName {
                    dict1["product_name"] = productName
                }
                var dict2:[String:Any] = [:]
                
                let duplicateLotArray = filtered.map { $0.lotNumber }

                var lotCodeArray : [String] = []
                for lotvalue in duplicateLotArray {
                    if !lotCodeArray.contains(lotvalue!) {
                        lotCodeArray.append(lotvalue!)
                    }
                }
                for lotValue in lotCodeArray {

//                    let productLotdetails = lotValue
                    var lotNo = ""
//                    if let lotNumber = productLotdetails {
                        dict2["lot_number"] = lotValue
                        lotNo = lotValue
//                    }
                    let Serialfiltered = filtered.filter { $0.lotNumber == lotNo }
                    let lotserialNumberArray = Serialfiltered.map { $0.serialNumber }
                    dict2["p_serials"] = lotserialNumberArray
                    arr1.append(dict2)
                }
                dict1["lots"] = arr1
                arr.append(dict1)
          }
        }
        requestDict["line_items"] = Utility.json(from: arr)
            
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "validateReceivingLotSerials", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                
                if isDone! {
                    //API
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                         if statusCode! {
                             if let dataDict = Utility.convertToDictionary(text: responseDict["data"] as! String){
                                 if let dictvalue = dataDict[self.selectedPuchaseOrderDict!.erpUUID!] as? NSDictionary{
                                    self.selectedDataSave()
                                    if let dataArr = dictvalue["data"] as? NSArray, dataArr.count>0{
                                      
                                     for item in dataArr {
                                         let dictvalue = item as? NSDictionary
                                     
                                         var product_tracking = ""
                                         if let producttracking = dictvalue?["product_tracking"] as? String{
                                             product_tracking = producttracking
                                         }
                                         
                                         var product_name = ""
                                         if let productname = dictvalue?["product_name"] as? String{
                                             product_name = productname
                                         }
                                         var lot_number = ""
                                         if let lot = dictvalue?["lot_number"] as? String{
                                             lot_number = lot
                                         }
                                        var serialNumber = ""
                                         if let serial = dictvalue?["serial"] as? String{
                                             serialNumber = serial
                                         }
                                         var product_code = ""
                                         if let productcode = dictvalue?["product_code"] as? String{
                                             product_code = productcode
                                         }
                                        
                                         let filteredArray = self.filterLineItemsListArray.filter { $0.productCode!.localizedCaseInsensitiveContains(product_code) }
                                         if filteredArray.count > 0 {
                                             let lineItemModel = filteredArray[0]
                                   
                                         let obj = MW_ReceivingManualLotOrScanSerial(context: PersistenceService.context)
                                             obj.id = MWReceivingManualLotOrScanSerial.getAutoIncrementId()
                                             obj.erp_uuid = self.selectedPuchaseOrderDict!.erpUUID
                                             obj.erp_name = self.selectedPuchaseOrderDict!.erpName
                                             obj.po_number = self.selectedPuchaseOrderDict!.poNumber
                                             obj.po_unique_id = lineItemModel.poUniqueID
                                             obj.product_unique_id = lineItemModel.productUniqueID
                                             obj.product_name = product_name
                                             obj.product_code = product_code
                                             obj.product_received_qty = lineItemModel.productReceivedQuantity
                                             obj.product_demand_qty = lineItemModel.productDemandQuantity
                                             obj.product_qty_to_receive = lineItemModel.productQtyToReceive
                                             obj.product_tracking = product_tracking
//                                             obj.product_uom_id = lineItemModel.productUomID
                                             obj.lot_number = lot_number
                                             obj.quantity = "1"
                                             obj.is_container = false
                                             obj.c_serial = ""
                                             obj.c_gtin = ""
                                             obj.p_serials = Utility.json(from: [])
                                             obj.p_gtins = Utility.json(from: [])
                                             obj.serial_number = serialNumber
                                             obj.is_edited = false

                                             PersistenceService.saveContext()
                                           
                                            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
                                            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialViewController") as! MWReceivingSerialViewController
                                                         controller.delegate = self
                                             controller.flowType = self.flowType //"directSerialScan", "viaManualLot"
                                             controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
                                             controller.selectedScannedSerialListArray = self.selectedScannedSerialListArray
                                            self.navigationController?.pushViewController(controller, animated: true)
                                     }
                                   }
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
                        //,,,sbm5
//                        let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited=true")
                        let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and is_edited=true")
                        //,,,sbm5
                        
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
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if selectedScannedSerialListArray.count > 0 {
            self.validateReceivingLotSerials()
            
            //,,,sbm1
//            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
//            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSerialViewController") as! MWReceivingSerialViewController
//            controller.delegate = self
//            controller.flowType = flowType //"directSerialScan", "viaManualLot"
//            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict
//            controller.selectedScannedSerialListArray = selectedScannedSerialListArray
//            self.navigationController?.pushViewController(controller, animated: true)
            
            /*
            self.showConfirmationViewController(confirmationMsg: "Are you sure to submit".localized(), alertStatus: "Alert1")
            self.showConfirmationViewController(confirmationMsg: "One or more unallocated serials are available! Please either remove those serials or allocate them before submit.".localized(), alertStatus: "Alert2")//false
            self.showConfirmationViewController(confirmationMsg: "Do you want to process another line item for odoo?".localized(), alertStatus: "Alert3")
            self.showConfirmationViewController(confirmationMsg: "Demand quantity of Aspirin in odoo does not match with the allocated serials! Do you want to add more serials for this item?".localized(), alertStatus: "Alert4")
            */
            //,,,sbm1
        }
        else {
            let message = "Please choose atleast one scan item for Receiving".localized()
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
        controller.modalTransitionStyle = .flipHorizontal
        self.present(controller, animated: true, completion: nil)
    }
    
    func didClickOnCamera(){
        //,,,sbm2 temp
     
        if(defaults.bool(forKey: "IsMultiScan")){
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWMultiScanViewController") as! MWMultiScanViewController
            controller.isForReceivingSerialVerificationScan = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWSingleScanViewController") as! MWSingleScanViewController
            controller.delegate = self
            controller.isForReceivingSerialVerificationScan = true
            self.navigationController?.pushViewController(controller, animated: true)
        }        
       // self.didSingleScanCodeForReceiveSerialVerification(scannedCode: [])
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
       //Scan From Device
        for code in scannedCode {
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
            
            //,,,sbm2-1
            if product_tracking == "serial" {
                do{
                    //,,,sbm5
                    let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)'")
                    //,,,sbm5
                    
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
                        obj.quantity = "1" //,,,sbm2-1
                        PersistenceService.saveContext()
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
            }
            else {
                do{
                  
                    let predicate = NSPredicate(format:"po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and gtin='\(gtin)' and serial_number='\(serial)' and lot_number='\(lot)' and product_tracking='lot'")
                    //,,,sbm5
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
      }
        reScanEnable = true
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
        
        for i in 0..<self.selectedScannedSerialListArray.count {
            let scannedModel:MWReceivingManuallyLotOrScanSerialBaseModel = self.selectedScannedSerialListArray[i]
            let quantity = scannedModel.quantity
            let productCode = scannedModel.productCode
            let serialNumber = scannedModel.serialNumber
            let lotNumber = scannedModel.lotNumber
            let productTracking = scannedModel.productTracking

            if productTracking == "lot" {
                let indexNO = scannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber})
                var productModel:MWReceivingManuallyLotOrScanSerialBaseModel = scannedSerialListArray[indexNO!]
                productModel.quantity = quantity
                scannedSerialListArray[indexNO!] = productModel
            }
        }//,,,sbm2-1
        
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
                cell.productLotNumberLabel.text =  "Lot:".localized() + "  " + lotNumber
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
        
        let selectedPuchaseOrderDict = scannedSerialListArray[indexPath.section]
        let serialNumber = selectedPuchaseOrderDict.serialNumber
        let productCode = selectedPuchaseOrderDict.productCode
        let lotNumber = selectedPuchaseOrderDict.lotNumber
        
        var producttracking = ""
        if let productTracking = selectedPuchaseOrderDict.productTracking {
            producttracking = productTracking
        }
        if producttracking == "serial" {
            if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == serialNumber && $0.productCode == productCode}) {
                selectedScannedSerialListArray.append(selectedPuchaseOrderDict)
            }else {
                let indexNO = selectedScannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode})
                selectedScannedSerialListArray.remove(at: indexNO!)
            }
        }
        else {
            if !selectedScannedSerialListArray.contains(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber}) {
                selectedScannedSerialListArray.append(selectedPuchaseOrderDict)
            }else {
                let indexNO = selectedScannedSerialListArray.firstIndex(where: {$0.serialNumber == serialNumber && $0.productCode == productCode  && $0.lotNumber == lotNumber})
                selectedScannedSerialListArray.remove(at: indexNO!)
            }
        }
    }
}
//MARK: - End

//MARK: - Tableview Cell
class MWReceivingViewTableCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var serialNumberStackView: UIStackView!
//    @IBOutlet weak var serialNumberLineView: UIView!
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
