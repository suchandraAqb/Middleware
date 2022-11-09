//
//  MWReceivingSerialViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 11/08/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

protocol MWReceivingSerialViewControllerDelegate: AnyObject {
    func reloadSelectedScannedSerialListArray(selectedScannedArray:[MWReceivingManuallyLotOrScanSerialBaseModel])
}

class MWReceivingSerialViewController: BaseViewController {
    @IBOutlet weak var poNumberButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var lotExistLabel: UILabel!
    
    weak var delegate: MWReceivingSerialViewControllerDelegate?
    var flowType: String = "" //"directSerialScan", "viaManualLot"

    var selectedPuchaseOrderDict: MWPuchaseOrderModel?
    var selectedScannedSerialListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
    
    var filterSerialHeaderListArray : [MWReceivingManuallyLotOrScanSerialBaseModel] = []
    var filterSerialItemsListArray : [[MWReceivingManuallyLotOrScanSerialBaseModel]] = []
    
    var filterLotLineItemsArray : [MWViewItemsModel] = [] //,,,sbm2
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
                
        poNumberButton.backgroundColor = UIColor.clear
        poNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
        poNumberButton.setTitle("PO: \(selectedPuchaseOrderDict?.poNumber ?? "")", for: UIControl.State.normal)
        
        let headerNib = UINib.init(nibName: "MWReceivingSummaryLotHeaderView", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "MWReceivingSummaryLotHeaderView")
        
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
                filterSerialHeaderListArray.append(mwReceivingManuallyLotOrScanSerialBaseModel)
                filterSerialItemsListArray.append(filtered)
            }
        }
        
        if flowType == "directSerialScan" {
            //,,,sbm2
            lotExistLabel.isHidden = true
            do{
                let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot'")

                let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                if !fetchRequestResultArray.isEmpty {
                    fetchRequestResultArray.forEach({ (cdModel) in
                        filterLotLineItemsArray.append(cdModel.convertCoreDataRequestsToMWViewItemsModel())
                    })
                    
                    lotExistLabel.isHidden = false
                    lotExistLabel.text = "\(fetchRequestResultArray.count) lot exist in this Purchase Order"
                }
            }catch let error{
                print(error.localizedDescription)
            }
            //,,,sbm2

        }else {
            lotExistLabel.isHidden = true
        }
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        
        let msg = "Do you want to remove this row?".localized()
        let confirmAlert = UIAlertController(title: "Alert".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                                    
            let section = Int(sender.accessibilityValue!)
            var productsModelArray = self.filterSerialItemsListArray[section!]
            
            let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[sender.tag]
            let serialNumber = productsModel.serialNumber
            self.selectedScannedSerialListArray = self.selectedScannedSerialListArray.filter { $0.serialNumber != serialNumber }
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
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='serial' and is_edited=true")
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
            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='serial' and is_edited=true")
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
        
        
        
        for i in 0..<filterSerialItemsListArray.count {
            let productsModelArray = filterSerialItemsListArray[i]
            if productsModelArray.count > 0 {
                let productsModel = productsModelArray[0]
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
                if productsModelArray.count > quantityToReceive {
                    
                    //######//
                    let message = "Total quantity can not be greater than Quantity to be Received".localized()
                    Utility.showPopupWithAction(Title: Warning, Message: message, InViewC: self, action:{
                        
                    })
                    //######//
                    
                    return
                }
                else {
                    //,,,sbm2
                    for model in productsModelArray {
                        do{
                            let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_code='\(model.productCode!)' and serial_number='\(model.serialNumber!)'")
                            let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchRequestWithPredicate(predicate: predicate))
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
        
        
            
        if filterLotLineItemsArray.count > 0 { //,,,sbm2
            if flowType == "directSerialScan" {
                
                var msg = "There are lot based line item exist. Do you want to process this lot based line item?"
                do{
                    let predicate = NSPredicate(format:"erp_uuid='\(self.selectedPuchaseOrderDict!.erpUUID!)' and po_number='\(self.selectedPuchaseOrderDict!.poNumber!)' and product_tracking='lot' and is_edited=true")

                    let fetchRequestResultArray = try PersistenceService.context.fetch(MWReceivingLineItem.fetchRequestWithPredicate(predicate: predicate))
                    if !fetchRequestResultArray.isEmpty {
                        msg = "There are lot based line item exist. Do you want to modify this lot based line item?"
                    }
                }catch let error{
                    print(error.localizedDescription)
                }

                self.showConfirmationViewController(confirmationMsg: msg, alertStatus: "Alert7")
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
    //MARK: - End
}

// MARK: - MWConfirmationView
extension MWReceivingSerialViewController: MWConfirmationViewDelegate {
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
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingManuallyViewController") as! MWReceivingManuallyViewController
            controller.flowType = "viaSerialScan"
            controller.selectedPuchaseOrderDict = self.selectedPuchaseOrderDict
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func cancelButtonPressed(alertStatus:String) {
        if alertStatus == "Alert7" {
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSummaryOfMappedLotsViewController") as! MWReceivingSummaryOfMappedLotsViewController
            controller.selectedPuchaseOrderDict = selectedPuchaseOrderDict//,,,sbm2
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK: - End
}
// MARK: - End

extension MWReceivingSerialViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        headerView.alreadyReceivedQuantityLabel.text = "Already Received Qty:".localized()
        headerView.quantityToReceiveLabel.text = "Qty to be Received:".localized()
        
        
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = filterSerialHeaderListArray[section]
        
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
        return filterSerialHeaderListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productsModelArray = filterSerialItemsListArray[section]
        return productsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWReceivingSerialTableViewCell") as! MWReceivingSerialTableViewCell
        cell.mainView.backgroundColor = Utility.hexStringToUIColor(hex: "eaf8ea") //E8EEE6
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 0
                
        let productsModelArray = filterSerialItemsListArray[indexPath.section]
        let productsModel:MWReceivingManuallyLotOrScanSerialBaseModel = productsModelArray[indexPath.row]
        
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
    }
    //MARK: - End
}

class MWReceivingSerialTableViewCell: UITableViewCell {
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
