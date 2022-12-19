//
//  MWPickingSerialViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 08/11/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm3

import UIKit

protocol MWPickingSerialViewControllerDelegate: AnyObject {
    func reloadSelectedScannedSerialListArray(selectedScannedArray:[MWPickingManuallyLotOrScanSerialBaseModel])
}

class MWPickingSerialViewController: BaseViewController {
    @IBOutlet weak var soNumberButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var lotExistLabel: UILabel!
    
    weak var delegate: MWPickingSerialViewControllerDelegate?
    var flowType: String = "" //"directSerialScan", "viaManualLot"

    var selectedSaleOrderDict: MWSaleOrderModel?
    var selectedScannedSerialListArray : [MWPickingManuallyLotOrScanSerialBaseModel] = []
    
    var filterSerialHeaderListArray : [MWPickingManuallyLotOrScanSerialBaseModel] = []
    var filterSerialItemsListArray : [[MWPickingManuallyLotOrScanSerialBaseModel]] = []
    
    var initialQuantityText = ""//,,,sbm2-1
    
//    var filterLotLineItemsArray : [MWPickingViewItemsModel] = [] //,,,sbm2 //,,,sbm2-1
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        self.createInputAccessoryView()
                
        soNumberButton.backgroundColor = UIColor.clear
        soNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
        soNumberButton.setTitle("SO: \(selectedSaleOrderDict?.soNumber ?? "")", for: UIControl.State.normal)
        
        let headerNib = UINib.init(nibName: "MWPickingSummaryLotHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "MWPickingSummaryLotHeaderView")
        
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
                let mwPickingManuallyLotOrScanSerialBaseModel = filtered[0]
                filterSerialHeaderListArray.append(mwPickingManuallyLotOrScanSerialBaseModel)
                filterSerialItemsListArray.append(filtered)
            }
        }
        
        //,,,sbm2-1
        /*
        if flowType == "directSerialScan" {
            //,,,sbm2
            lotExistLabel.isHidden = true
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot'")
                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot'")
                //,,,sbm5

                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                if !fetchRequestResultArray.isEmpty {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        filterLotLineItemsArray.append(cdModel.convertCoreDataRequestsToMWPickingViewItemsModel())
                    })
                    
                    lotExistLabel.isHidden = false
                    lotExistLabel.text = "\(fetchRequestResultArray.count) lot exist in this Sale Order"
                }
            }catch let error{
                print(error.localizedDescription)
            }
            //,,,sbm2

        }else {
            lotExistLabel.isHidden = true
        }
        */
        
        lotExistLabel.isHidden = true
        //,,,sbm2-1
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        let section = Int(sender.accessibilityValue!)
        var productsModelArray = self.filterSerialItemsListArray[section!]
        var productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[sender.tag]
        var productName = ""
        if let val = productsModel.productName {
            productName = val
        }
        let quantity = productsModel.quantity
        var quantityInt = Int(quantity!)!
        if quantityInt > 0 {
            quantityInt = quantityInt - 1
            let quantityString = String(quantityInt)

            if quantityInt == 0 {
                let indexPath = IndexPath(row: sender.tag, section: section!)
                let cell = self.listTable.cellForRow(at: indexPath) as! MWPickingLotTableViewCell
                cell.quantityTextField.text = quantityString
                
                
                let msg = "Do you want to remove this product - \(productName)?".localized()
                let confirmAlert = UIAlertController(title: "Alert".localized(), message: msg, preferredStyle: .alert)
                let noAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
                    
                    cell.quantityTextField.text = productsModel.quantity
                }
                let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                    let serialNumber = productsModel.serialNumber
                    let productTracking = productsModel.productTracking
                    let lotNumber = productsModel.lotNumber
                    
                    if productTracking == "serial" {
                        self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.serialNumber != serialNumber }
                    }
                    else {
                        self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.lotNumber != lotNumber }
                    }
                    
                    self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
                    
                    productsModelArray.remove(at: cell.quantityTextField.tag)
                    
                    if productsModelArray.count == 0 {
                        self.filterSerialHeaderListArray.remove(at: section!)
                        self.filterSerialItemsListArray.remove(at: section!)
                    }
                    else {
                        self.filterSerialItemsListArray[section!] = productsModelArray
                    }
                    self.listTable.reloadData()
                    
                }
                confirmAlert.addAction(noAction)
                confirmAlert.addAction(yesAction)
                self.navigationController?.present(confirmAlert, animated: true, completion: nil)
            }
            else {
                productsModel.quantity = quantityString
                productsModelArray [sender.tag] = productsModel
                self.filterSerialItemsListArray[section!] = productsModelArray
                
                
                let indexPath = IndexPath(row: sender.tag, section: section!)
                let cell = self.listTable.cellForRow(at: indexPath) as! MWPickingLotTableViewCell
                cell.quantityTextField.text = quantityString
                
    //            listTable.reloadSections(IndexSet(integer: section!), with: .none)
                
                //,,,sbm2
                do{
                    //,,,sbm5
//                    let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                    let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                    //,,,sbm5

                    
                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                    if fetchRequestResultArray.isEmpty {
                        
                    }
                    else {
                        if let obj = fetchRequestResultArray.first {
                            obj.quantity = productsModel.quantity
                            PersistenceService.saveContext()
                        }
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                
                do{
                    //,,,sbm5
//                    let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                    let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                    //,,,sbm5
                    
                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                    if fetchRequestResultArray.isEmpty {
                        
                    }
                    else {
                        if let obj = fetchRequestResultArray.first {
                            obj.quantity = productsModel.quantity
                            PersistenceService.saveContext()
                        }
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
                
                
                for i in 0..<self.selectedScannedSerialListArray.count {
                    var scannedModel:MWPickingManuallyLotOrScanSerialBaseModel = self.selectedScannedSerialListArray[i]
                    let productTracking = scannedModel.productTracking
                    if productTracking == "lot" {
                        if scannedModel.productCode == productsModel.productCode &&
                           scannedModel.productTracking == productsModel.productTracking &&
                           scannedModel.lotNumber == productsModel.lotNumber {
                            
                            scannedModel.quantity = productsModel.quantity
                            self.selectedScannedSerialListArray[i] = scannedModel
                        }
                    }
                }
                self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
                //,,,sbm2
            }
        }
    }
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        let section = Int(sender.accessibilityValue!)
        var productsModelArray = self.filterSerialItemsListArray[section!]
        var productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[sender.tag]
        let quantity = productsModel.quantity
        var quantityInt = Int(quantity!)!
        quantityInt = quantityInt + 1
        
        let quantityString = String(quantityInt)
        productsModel.quantity = quantityString
        productsModelArray [sender.tag] = productsModel
        self.filterSerialItemsListArray[section!] = productsModelArray
        
        
        let indexPath = IndexPath(row: sender.tag, section: section!)
        let cell = self.listTable.cellForRow(at: indexPath) as! MWPickingLotTableViewCell
        cell.quantityTextField.text = quantityString
                
        //,,,sbm2
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
            let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
            //,,,sbm5

            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                
            }
            else {
                if let obj = fetchRequestResultArray.first {
                    obj.quantity = productsModel.quantity
                    PersistenceService.saveContext()
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
        
        
        do{
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
            let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
            if fetchRequestResultArray.isEmpty {
                
            }
            else {
                if let obj = fetchRequestResultArray.first {
                    obj.quantity = productsModel.quantity
                    PersistenceService.saveContext()
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
        
        
        for i in 0..<self.selectedScannedSerialListArray.count {
            var scannedModel:MWPickingManuallyLotOrScanSerialBaseModel = self.selectedScannedSerialListArray[i]
            let productTracking = scannedModel.productTracking
            if productTracking == "lot" {
                if scannedModel.productCode == productsModel.productCode &&
                   scannedModel.productTracking == productsModel.productTracking &&
                   scannedModel.lotNumber == productsModel.lotNumber {
                    
                    scannedModel.quantity = productsModel.quantity
                    self.selectedScannedSerialListArray[i] = scannedModel
                }
            }
        }
        self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
        //,,,sbm2
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        
        //,,,sbm2-1
        let section = Int(sender.accessibilityValue!)
        var productsModelArray = self.filterSerialItemsListArray[section!]
        let productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[sender.tag]
        var productName = ""
        if let val = productsModel.productName {
            productName = val
        }
        //,,,sbm2-1
        
        let msg = "Do you want to remove this product - \(productName)?".localized()
        let confirmAlert = UIAlertController(title: "Alert".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            let serialNumber = productsModel.serialNumber
            let productTracking = productsModel.productTracking
            let lotNumber = productsModel.lotNumber
            
            if productTracking == "serial" {
                self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.serialNumber != serialNumber }
            }
            else {
                self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.lotNumber != lotNumber }
            }
            
            self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
            
            productsModelArray.remove(at: sender.tag)
            
            if productsModelArray.count == 0 {
                self.filterSerialHeaderListArray.remove(at: section!)
                self.filterSerialItemsListArray.remove(at: section!)
            }
            else {
                self.filterSerialItemsListArray[section!] = productsModelArray
            }
            self.listTable.reloadData()
            
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        //,,,sbm2
        do{
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='serial' and is_edited=true")
            
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")//,,,sbm2-1
            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")//,,,sbm2-1
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
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
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='serial' and is_edited=true")
            
            //,,,sbm5
//            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")//,,,sbm2-1
            let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and is_edited=true")//,,,sbm2-1
            //,,,sbm5
            
            let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
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
        
        //,,,sbm2-1
        var isEmpty = false
        var totalQtyAmount:Int = 0
        //,,,sbm2-1
        
        for i in 0..<filterSerialItemsListArray.count {
            let productsModelArray = filterSerialItemsListArray[i]
            print("productsModelArray......?>>>>>>",productsModelArray)
            if productsModelArray.count > 0 {
                let productsModel = productsModelArray[0]
                
                //,,,sbm2-1
                var productName = ""
                if let val = productsModel.productName {
                    productName = val
                }
                
                var productTracking = ""
                if let val = productsModel.productTracking {
                    productTracking = val
                }
                
                if productTracking == "serial" {
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
                    
                    var productDeliveredQty = 0
                    var productDeliveredQuantityStr = ""
                    if let val = productsModel.productDeliveredQuantity {
                        productDeliveredQuantityStr = val
                    }
                    if productDeliveredQuantityStr.contains(".") {
                        if let productDeliveredQtyDouble = Double(productDeliveredQuantityStr) {
                            productDeliveredQty = Int(productDeliveredQtyDouble)
                        }
                    }else {
                        if let productDeliveredQtyInt = Int(productDeliveredQuantityStr) {
                            productDeliveredQty = productDeliveredQtyInt
                        }
                    }
                    
                    let quantityToDeliver = demandQty - productDeliveredQty
                    if productsModelArray.count > quantityToDeliver {
                        
                        //######//
                        let message = "Total quantity can not be greater than Quantity to be Picked in this product -  \(productName)"
                        Utility.showPopupWithAction(Title: Warning, Message: message, InViewC: self, action:{
                            
                        })
                        //######//
                        
                        return
                    }
                    else {
                        //,,,sbm2
                        for model in productsModelArray {
                            do{
                                //,,,sbm5
//                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)' and serial_number='\(model.serialNumber!)'")
                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)' and serial_number='\(model.serialNumber!)'")
                                //,,,sbm5

                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                                if !fetchRequestResultArray.isEmpty {
                                    
                                    fetchRequestResultArray.forEach({ (cdModel) in
                                        cdModel.is_edited = true
                                        PersistenceService.saveContext()
                                    })
                                }
                            }catch let error {
                                print(error.localizedDescription)
                            }
                            
                            
                            do{
                                //,,,sbm5
//                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)'")
                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)'")
                                //,,,sbm5
                                
                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
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
                else {
                    var quantityToDeliver = 0
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
                        
                        var productDeliveredQty = 0
                        var productDeliveredQuantityStr = ""
                        if let val = productsModel.productDeliveredQuantity {
                            productDeliveredQuantityStr = val
                        }
                        if productDeliveredQuantityStr.contains(".") {
                            if let productDeliveredQtyDouble = Double(productDeliveredQuantityStr) {
                                productDeliveredQty = Int(productDeliveredQtyDouble)
                            }
                        }else {
                            if let productDeliveredQtyInt = Int(productDeliveredQuantityStr) {
                                productDeliveredQty = productDeliveredQtyInt
                            }
                        }
                        
                        quantityToDeliver = demandQty - productDeliveredQty
                    }
                    
                    let qtyArray = productsModelArray.map { $0.quantity }
                    var qtyAmount:Int = 0
                    for qty in qtyArray {
                        if let qtyStr = qty {
                            qtyAmount = qtyAmount + (Int(qtyStr) ?? 0)
                        }
                    }
                    
                    totalQtyAmount = totalQtyAmount + qtyAmount
                    
                    if qtyAmount > quantityToDeliver {
                        
                        //######//
                        let message = "Total quantity can not be greater than Quantity to be Picked in this product -  \(productName)"
                        Utility.showPopupWithAction(Title: Warning, Message: message, InViewC: self, action:{
//                            let indexPath = IndexPath(row: 0, section: i)
//                            let cell = self.listTable.cellForRow(at: indexPath) as! MWPickingLotTableViewCell
//                            cell.quantityTextField.becomeFirstResponder()
                        })
                        //######//
                        
                        return
                    }
                    else {
                        //,,,sbm2
                        for model in productsModelArray {
                            do{
                                //,,,sbm5
//                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)' and is_edited= false")
                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)' and is_edited= false")
                                //,,,sbm5
                                
                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                                if !fetchRequestResultArray.isEmpty {
                                    fetchRequestResultArray.forEach({ (cdModel) in
                                        PersistenceService.context.delete(cdModel)
                                    })
                                    PersistenceService.saveContext()
                                }
                                
                                
                                let obj = MW_PickingManualLotOrScanSerial(context: PersistenceService.context)
                                obj.id = MWPickingManualLotOrScanSerial.getAutoIncrementId()
                                obj.erp_uuid = model.erpUUID
                                obj.erp_name = model.erpName
                                obj.so_number = model.soNumber
                                obj.so_unique_id = model.soUniqueID
                                obj.product_unique_id = model.productUniqueID
                                obj.product_name = model.productName
                                obj.product_code = model.productCode
                                obj.product_delivered_qty = model.productDeliveredQuantity
                                obj.product_demand_qty = model.productDemandQuantity
                                obj.product_qty_to_deliver = model.productQtyToDeliver
                                obj.product_tracking = model.productTracking
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
                                //,,,sbm5
//                                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)'")
                                let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_code='\(model.productCode!)'")
                                //,,,sbm5
                                
                                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
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
                //,,,sbm2-1
            }
        }
        
        //,,,sbm2-1
        /*
        if filterLotLineItemsArray.count > 0 { //,,,sbm2
            if flowType == "directSerialScan" {
                
                var msg = "There are lot based line item exist. Do you want to process this lot based line item?"
                do{
                    //,,,sbm5
                    //let predicate = NSPredicate(format:"erp_uuid='\(self.selectedSaleOrderDict!.erpUUID!)' and so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot' and is_edited=true")
                      let predicate = NSPredicate(format:"so_number='\(self.selectedSaleOrderDict!.soNumber!)' and product_tracking='lot' and is_edited=true")
                    //,,,sbm5

                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingLineItem.fetchRequestWithPredicate(predicate: predicate))
                    if !fetchRequestResultArray.isEmpty {
                        msg = "There are lot based line item exist. Do you want to modify this lot based line item?"
                    }
                }catch let error{
                    print(error.localizedDescription)
                }

                self.showConfirmationViewController(confirmationMsg: msg, alertStatus: "Alert7")
            }
            else {
                let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSummaryOfMappedLotsViewController") as! MWPickingSummaryOfMappedLotsViewController
                controller.selectedSaleOrderDict = selectedSaleOrderDict//,,,sbm2
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        else {
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSummaryOfMappedLotsViewController") as! MWPickingSummaryOfMappedLotsViewController
            controller.selectedSaleOrderDict = selectedSaleOrderDict//,,,sbm2
            self.navigationController?.pushViewController(controller, animated: true)
        }
        */
        
        let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSummaryOfMappedLotsViewController") as! MWPickingSummaryOfMappedLotsViewController
        controller.selectedSaleOrderDict = selectedSaleOrderDict//,,,sbm2
        self.navigationController?.pushViewController(controller, animated: true)
        //,,,sbm2-1
    }
    //MARK: - End
}

// MARK: - MWConfirmationView
extension MWPickingSerialViewController: MWConfirmationViewDelegate {
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
        if alertStatus == "Alert7" {
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingManuallyViewController") as! MWPickingManuallyViewController
            controller.flowType = "viaSerialScan"
            controller.selectedSaleOrderDict = self.selectedSaleOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func cancelButtonPressed(alertStatus:String) {
        if alertStatus == "Alert7" {
            let storyboard = UIStoryboard.init(name: "MWPicking", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWPickingSummaryOfMappedLotsViewController") as! MWPickingSummaryOfMappedLotsViewController
            controller.selectedSaleOrderDict = selectedSaleOrderDict//,,,sbm2
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK: - End
}
// MARK: - End

extension MWPickingSerialViewController {
    //MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        textFieldTobeField = textField
        initialQuantityText = textField.text!//,,,sbm2-1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let section = Int(textField.accessibilityValue!)
        var productsModelArray = self.filterSerialItemsListArray[section!]
        var productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[textField.tag]
        var productName = ""
        if let val = productsModel.productName {
            productName = val
        }
        let quantityString = textField.text
        let quantityInt = Int(quantityString!)
        if quantityInt == 0 {
            let msg = "Do you want to remove this product - \(productName)?".localized()
            let confirmAlert = UIAlertController(title: "Alert".localized(), message: msg, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
                
                textField.text = productsModel.quantity
            }
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                let serialNumber = productsModel.serialNumber
                let productTracking = productsModel.productTracking
                let lotNumber = productsModel.lotNumber
                
                if productTracking == "serial" {
                    self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.serialNumber != serialNumber }
                }
                else {
                    self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.lotNumber != lotNumber }
                }
                
                self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
                
                productsModelArray.remove(at: textField.tag)
                
                if productsModelArray.count == 0 {
                    self.filterSerialHeaderListArray.remove(at: section!)
                    self.filterSerialItemsListArray.remove(at: section!)
                }
                else {
                    self.filterSerialItemsListArray[section!] = productsModelArray
                }
                self.listTable.reloadData()
                
            }
            confirmAlert.addAction(noAction)
            confirmAlert.addAction(yesAction)
            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        }
        else {
            productsModel.quantity = quantityString
            productsModelArray [textField.tag] = productsModel
            self.filterSerialItemsListArray[section!] = productsModelArray
                            
            //,,,sbm2
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and gtin='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingScanProduct.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    
                }
                else {
                    if let obj = fetchRequestResultArray.first {
                        obj.quantity = productsModel.quantity
                        PersistenceService.saveContext()
                    }
                }
            }catch let error {
                print(error.localizedDescription)
            }
            
            do{
                //,,,sbm5
//                let predicate = NSPredicate(format:"erp_uuid='\(productsModel.erpUUID!)' and so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                let predicate = NSPredicate(format:"so_number='\(productsModel.soNumber!)' and product_code='\(productsModel.productCode!)' and serial_number='\(productsModel.serialNumber!)' and lot_number='\(productsModel.lotNumber!)' and product_tracking='lot'")
                //,,,sbm5
                
                let fetchRequestResultArray = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
                if fetchRequestResultArray.isEmpty {
                    
                }
                else {
                    if let obj = fetchRequestResultArray.first {
                        obj.quantity = productsModel.quantity
                        PersistenceService.saveContext()
                    }
                }
            }catch let error {
                print(error.localizedDescription)
            }
            
            
            for i in 0..<self.selectedScannedSerialListArray.count {
                var scannedModel:MWPickingManuallyLotOrScanSerialBaseModel = self.selectedScannedSerialListArray[i]
                let productTracking = scannedModel.productTracking
                if productTracking == "lot" {
                    if scannedModel.productCode == productsModel.productCode &&
                       scannedModel.productTracking == productsModel.productTracking &&
                       scannedModel.lotNumber == productsModel.lotNumber {
                        
                        scannedModel.quantity = productsModel.quantity
                        self.selectedScannedSerialListArray[i] = scannedModel
                    }
                }
            }
            self.delegate?.reloadSelectedScannedSerialListArray(selectedScannedArray: self.selectedScannedSerialListArray)
            //,,,sbm2
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    //MARK: - End
}

extension MWPickingSerialViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MWPickingSummaryLotHeaderView") as! MWPickingSummaryLotHeaderView
        
        
        let productsModelArray = filterSerialItemsListArray[section]
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
        backgroundView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea")
        headerView.backgroundView = backgroundView
        
        headerView.productNameLabel.text = ""
        headerView.productTrackingLabel.text = "Type:".localized()
        headerView.demandQuantityLabel.text = "Demand Qty:".localized()
        headerView.alreadyDeliveredQuantityLabel.text = "Already Picked Qty:".localized()
        headerView.quantityToDeliverLabel.text = "Qty to be Picked:".localized()
        
        
        let productsModel:MWPickingManuallyLotOrScanSerialBaseModel = filterSerialHeaderListArray[section]
        
        if let productName = productsModel.productName {
            headerView.productNameLabel.text = productName
        }
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
        
        var productDeliveredQty = 0
        var productDeliveredQuantityStr = ""
        if let val = productsModel.productDeliveredQuantity {
            productDeliveredQuantityStr = val
        }

        if productDeliveredQuantityStr.contains(".") {
            if let productDeliveredQtyDouble = Double(productDeliveredQuantityStr) {
                productDeliveredQty = Int(productDeliveredQtyDouble)
            }
        }else {
            if let productDeliveredQtyInt = Int(productDeliveredQuantityStr) {
                productDeliveredQty = productDeliveredQtyInt
            }
        }
        headerView.alreadyDeliveredQuantityLabel.text = "Already Picked Qty:".localized() + "  " + String(productDeliveredQty)
        
        let quantityToDeliver = demandQty - productDeliveredQty
        headerView.quantityToDeliverLabel.text = "Qty to be Picked:".localized() + "  " + String(quantityToDeliver)
        
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
        return filterSerialHeaderListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productsModelArray = filterSerialItemsListArray[section]
        return productsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //,,,sbm2-1
        let productsModelArray = filterSerialItemsListArray[indexPath.section]
        let productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[indexPath.row]
        print("productTracking....",productsModel.productTracking as Any)
        
        if productsModel.productTracking == "serial" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MWPickingSerialTableViewCell") as! MWPickingSerialTableViewCell
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") //E8EEE6
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 0
            
            //,,,sbm2-1
    //        let productsModelArray = filterSerialItemsListArray[indexPath.section]
    //        let productsModel:MWPickingManuallyLotOrScanSerialBaseModel = productsModelArray[indexPath.row]
            //,,,sbm2-1
            
            if let serialNO = productsModel.serialNumber {
                cell.serialNumberLabel.text = serialNO
            }
            if let lotNumber = productsModel.lotNumber {
                cell.lotNumberLabel.text = lotNumber
            }
            
            if indexPath.row == productsModelArray.count-1 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            cell.removeButton.tag = indexPath.row
            cell.removeButton.accessibilityValue = "\(indexPath.section)"
            
            if productsModelArray.count > 0 {
                cell.removeButton.isHidden = false
            }else {
                cell.removeButton.isHidden = true
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MWPickingLotTableViewCell") as! MWPickingLotTableViewCell
            cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") //E8EEE6
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 0
            cell.quantityStackView.setBorder(width: 1, borderColor: UIColor.lightGray, cornerRadious: 2)

            if let lotNumber = productsModel.lotNumber {
                cell.lotNumberLabel.text = lotNumber
            }
            if let quantity = productsModel.quantity {
                cell.quantityTextField.text = quantity
            }
            
            if indexPath.row == productsModelArray.count-1 {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            cell.removeButton.tag = indexPath.row
            cell.removeButton.accessibilityValue = "\(indexPath.section)"
            
            if productsModelArray.count > 0 {
                cell.removeButton.isHidden = false
            }else {
                cell.removeButton.isHidden = true
            }
            
            cell.minusButton.tag = indexPath.row
            cell.minusButton.accessibilityValue = "\(indexPath.section)"
            
            cell.plusButton.tag = indexPath.row
            cell.plusButton.accessibilityValue = "\(indexPath.section)"
            
            cell.quantityTextField.tag = indexPath.row
            cell.quantityTextField.accessibilityValue = "\(indexPath.section)"
            
            return cell
        }
        //,,,sbm2-1
    }
    //MARK: - End
}

class MWPickingSerialTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
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

class MWPickingLotTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lotNumberLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var quantityStackView: UIStackView!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
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
