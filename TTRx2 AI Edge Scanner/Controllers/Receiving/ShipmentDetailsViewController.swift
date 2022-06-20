//
//  ShipmentDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

@objc protocol ShipmentDetailsViewControllerDelegate: AnyObject {
    func willScanAgain()
}
class ShipmentDetailsViewController: BaseViewController,ConfirmationViewDelegate {
    
    weak var delegate: ShipmentDetailsViewControllerDelegate?
    
    @IBOutlet weak var step5View: UIView!
    @IBOutlet weak var step4BarViewContainer: UIView!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var viewPOButton: UIButton!
    @IBOutlet weak var udidValueLabel: UILabel!
    @IBOutlet weak var tpValueLabel: UILabel!
    @IBOutlet weak var etaValueLabel: UILabel!
    @IBOutlet weak var poValueLabel: UILabel!
    @IBOutlet weak var shipDateValueLabel: UILabel!
    @IBOutlet weak var deliveryDateValueLabel: UILabel!
    @IBOutlet weak var cOrderIdValueLabel: UILabel!
    @IBOutlet weak var invoiceValueLabel: UILabel!
    @IBOutlet weak var orderValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    @IBOutlet weak var SFNickNameValueLabel: UILabel!
    @IBOutlet weak var SFAddressValueLabel: UILabel!
    @IBOutlet weak var STNickNameValueLabel: UILabel!
    @IBOutlet weak var STAddressValueLabel: UILabel!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step5Button: UIButton!
    
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step4BarView: UIView!
    
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    @IBOutlet weak var quarantineButton:UIButton!
    @IBOutlet weak var deleteButton:UIButton!
    @IBOutlet var deleteShipmentPopupView: UIView!
    @IBOutlet var deleteAssociatedInboundCheckBox: UIButton!
    @IBOutlet var deleteShipmentConfirmButton: UIButton!
    @IBOutlet var deleteShipmentPopupInnerView: UIView!
    
    @IBOutlet var deletePopupHeaderLabel: UILabel!
    @IBOutlet var deletePopupDescriptionLabel1: UILabel!
    @IBOutlet var deletePopupDescriptionLabel2: UILabel!
    @IBOutlet var deleteShipmentCancelButton: UIButton!
    
    
    var isFiveStep:Bool!
    var isfromSearchmanually : Bool!
    //MARK: - End
    
    var shipmentId:String?
    var itemsArray:Array<Any>?
    var itemsMainArray:Array<Any>?
    var allLocations:NSDictionary?
    public var responseDict: NSDictionary?
    var delivaryStatus : String?
    var isnotlotsetForeach : Bool = false

    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        removeReceivingDefaults()
        Utility.removeReceivingLotDB()
        Utility.removeReceivingLineDB()
        isFiveStep = true;
        defaults.set(true, forKey: "isFiveStep")
        defaults.set(shipmentId, forKey: "shipmentId")
        // Do any additional setup after loading the view.
        //shipmentId = "051fb89f-b46a-4b8c-9d8a-b0edb3e72e7b" // f88c1515-9262-4f60-b30d-23078b94e743
        sectionView.roundTopCorners(cornerRadious: 40)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        //detailsView.alpha = 0
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        viewPOButton.setRoundCorner(cornerRadious: viewPOButton.frame.size.height/2.0)
        
        quarantineButton.setRoundCorner(cornerRadious: quarantineButton.frame.size.height/2.0)
        deleteButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E57777"), cornerRadious: quarantineButton.frame.size.height/2.0)
        
        deleteButton.setTitle("Delete this inbound".localized(), for: .normal)
        deletePopupHeaderLabel.text="Delete Inbound Shipment".localized()
        deletePopupDescriptionLabel1.text="Deleting this inbound transaction will unload the content of this shipment from the data, and remove the shipment. The sender of the data won't be notified.".localized()
        deleteAssociatedInboundCheckBox.setTitle("Delete Associated Inbound Transaction".localized(), for: .normal)
        deletePopupDescriptionLabel2.text="Check this box to delete the inbound transaction associated to this shipment. The shipment must have only one transaction, and the transaction must have no other inbound shipments, otherwise the option will be rejected.".localized()
        deleteShipmentConfirmButton.setTitle("Delete Shipment".localized(), for: .normal)
        deleteShipmentCancelButton.setTitle("Cancel".localized(), for: .normal)
        
        
        
        
        
        deleteShipmentPopupView.isHidden=true
        deleteShipmentPopupInnerView.layer.cornerRadius=15
        deleteShipmentPopupInnerView.clipsToBounds=true
        deleteShipmentConfirmButton.layer.cornerRadius=10
        viewPOButton.isHidden = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.allLocations = UserInfosModel.getLocations()
            self.getShipmentDetails()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        self.fetchFromLocalDB()
    }
    
    //MARK: - End
    public var localTableData : Array<ReceiveLotEdit>?
    private func fetchFromLocalDB(){
        do {
            let fetchRequest = NSFetchRequest<ReceiveLotEdit>(entityName: "ReceiveLotEdit")
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            self.localTableData = serial_obj
         
            
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: - IBAction
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if itemsMainArray != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsView") as! ItemsViewController
            controller.itemsList = itemsMainArray
            controller.shipmentId = shipmentId
            controller.isfromSetLot = false
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No items found.", InViewC: self)
        }
    }
    @IBAction func viewItemsSetLotButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if itemsMainArray != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsView") as! ItemsViewController
            controller.itemsList = itemsMainArray
            controller.shipmentId = shipmentId
            controller.isfromSetLot = true
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "No items found.", InViewC: self)
        }
    }
    //MARK: - IBAction
    @IBAction func viewPOButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
        controller.shipmentId = self.shipmentId ?? ""
        controller.responseDict =  self.responseDict
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let items = self.itemsArray{
            for item in items{
                if let itemm = item as? NSDictionary{
                    if let lots = itemm["lots"] as? Array<NSDictionary>{
                        if let _ = lots.first(where: {$0["lot_number"] as? String == ""}), self.localTableData?.count == 0{
                            
                            let popUpAlert = UIAlertController(title: "Set Lot Number", message: "It seems like there are lot number missing in some line items. Please set lot number.".localized(), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Set lot manually".localized(), style: .cancel, handler: {_ in
                                self.viewItemsSetLotButtonPressed(self.viewItemsButton)
                            })
                            
                            let smartScanAction = UIAlertAction(title: "Smart Scan".localized(), style: .default, handler: {_ in
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                                controller.isForReceivingSerialVerificationScan = true
                                controller.delegate = self
                                controller.lineItemsArr = self.responseDict!["ship_lines_item"] as? Array<Any>
                                self.navigationController?.pushViewController(controller, animated: true)
                            })
                            
                            let cancelAction = UIAlertAction(title: "Skip and proceed".localized(), style: .default, handler: {_ in
                                
                                defaults.set(true, forKey: "rec_1stStep")
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
                                controller.shipmentId = self.shipmentId ?? ""
                                controller.responseDict =  self.responseDict
                                self.navigationController?.pushViewController(controller, animated: false)
                            })
                           
                            popUpAlert.addAction(smartScanAction)
                            popUpAlert.addAction(okAction)
                            popUpAlert.addAction(cancelAction)
                            
                            self.present(popUpAlert, animated: true, completion: nil)
                            
                        
                            
                        }else{
                            if !isnotlotsetForeach {
                            defaults.set(true, forKey: "rec_1stStep")
                            
                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
                            controller.shipmentId = self.shipmentId ?? ""
                            controller.responseDict =  self.responseDict
                            self.navigationController?.pushViewController(controller, animated: false)
                        }else{
                                
                                let popUpAlert = UIAlertController(title: "Set Lot Number", message: "Please set lot number.".localized(), preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Set lot manually".localized(), style: .cancel, handler: {_ in
                                    self.viewItemsSetLotButtonPressed(self.viewItemsButton)
                                })
                                
                                let smartScanAction = UIAlertAction(title: "Smart Scan".localized(), style: .default, handler: {_ in
                                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                                    controller.isForReceivingSerialVerificationScan = true
                                    controller.delegate = self
                                    controller.lineItemsArr = self.responseDict!["ship_lines_item"] as? Array<Any>
                                    self.navigationController?.pushViewController(controller, animated: true)
                                })
                                
                                let cancelAction = UIAlertAction(title: "Skip and proceed".localized(), style: .default, handler: {_ in
                                    
                                    defaults.set(true, forKey: "rec_1stStep")
                                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
                                    controller.shipmentId = self.shipmentId ?? ""
                                    controller.responseDict =  self.responseDict
                                    self.navigationController?.pushViewController(controller, animated: false)
                                })
                               
                                popUpAlert.addAction(smartScanAction)
                                popUpAlert.addAction(okAction)
                                popUpAlert.addAction(cancelAction)
                                
                                self.present(popUpAlert, animated: true, completion: nil)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 2 {
            
            nextButtonPressed(UIButton())
            
        }else if sender.tag == 3 {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialVerificationView") as! SerialVerificationViewController
            controller.shipmentId = self.shipmentId ?? ""
            self.navigationController?.pushViewController(controller, animated: false)
            
        } else if sender.tag == 4 {
            
            if isFiveStep {
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "StorageSelectionView") as! StorageSelectionViewController
                self.navigationController?.pushViewController(controller, animated: false)
                
            }else{
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }
            
        }else if sender.tag == 5 {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
    }
    
    @IBAction func scanAgainButtonsPressed(_ sender: UIButton) {
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
        self.delegate?.willScanAgain()
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if (isfromSearchmanually != nil) && isfromSearchmanually{
            isfromSearchmanually = false
            self.navigationController?.popViewController(animated: true)
        }
        else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
            controller.confirmationMsg = "Are you sure you want to cancel Receiving".localized()
            controller.delegate = self
            controller.isCancelConfirmation = true
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func quarantineButtonPressed(_ sender:UIButton){
        let storyboard = UIStoryboard.init(name: "Adjustments", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "QuarantineGeneralView") as! QuarantineGeneralViewController
        controller.shippingDetailsDict = self.responseDict
        controller.adjustmentType = "QUARANTINE"
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    @IBAction func deleteShipmentButtonPressed(_ sender: UIButton) {
        deleteShipmentPopupView.isHidden=false
    }
    
    @IBAction func deleteShipmentConfirmButtonPressed(_ sender: UIButton) {
        deleteShipmentPopupView.isHidden=true
        let requestDict = NSMutableDictionary()
        requestDict.setValue("SILENT_DELETE", forKey: "type_of_deletion")
        if deleteAssociatedInboundCheckBox.isSelected {
            requestDict.setValue(true, forKey: "is_delete_transaction")
        }else{
            requestDict.setValue(false, forKey: "is_delete_transaction")
        }
        deleteShipmentWebServiceCall(requestData: requestDict)
    }
    
    @IBAction func deleteAssociatedTransactionButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        deleteAssociatedInboundCheckBox.setTitle("Delete Associated Inbound Transaction".localized(), for: .normal)
    }
    
    @IBAction func deleteShipmentCancelButtonPressed(_ sender: UIButton) {
        deleteShipmentPopupView.isHidden=true
    }
    //MARK: - End
    //MARK: - Private Method
    
    func autoPopulateLot(scannedCode: [String]){
        let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]
        var scannedLotList=[Any]()
        var extraQtyFound=false
        var distinctLotList=[Any]()


        for data in scannedCode {
            let details = UtilityScanning(with:data).decoded_info
            if details.count > 0 {
                var dict = [String:Any]()
                var gtin14:String=""
//                var lotNumber:String=""
//                var expDateStr:String=""
//                var uuid:String=""
                
                if(details.keys.contains("01")){
                    if let gtin = details["01"]?["value"] as? String{
                        dict["gtin14"]=gtin
                        gtin14=gtin;
                    }
                }
                if(details.keys.contains("10")){
                    if let lot = details["10"]?["value"] as? String{
                        dict["lot_number"]=lot
                    }
                }
                if (details.keys.contains("17")) {
                    if let date = details["17"]?["value"] as? String{
                        let splitArr = date.split(separator: "T")
                        if let  dateStr = String?(String(splitArr[0])){
                            dict["expDateStr"]=dateStr
                        }
                    }
                }
                if !allproducts!.isEmpty,!gtin14.isEmpty {
                    let filteredArray = allproducts?.filter { $0["gtin14"] as? String == gtin14 }
                    print(filteredArray as Any)
                    if filteredArray!.count > 0 {
                        let  idValue =  (filteredArray?.first?["uuid"] as? String) ?? ""
                        dict["uuid"]=idValue
                    }else{
                        // Here convert to ndc and check with all products
                    }
                }
                if !dict.isEmpty {
                    scannedLotList.append(dict)
                    if !distinctLotList.isEmpty {
                        if !(distinctLotList as NSArray).contains(dict){
                            distinctLotList.append(dict)
                        }
                    }else{
                        distinctLotList.append(dict)
                    }
                }
            }
        }
        
        let scannedLotArray = scannedLotList as? [[String:Any]]
        if let items = self.itemsArray{
            for (index,item) in items.enumerated(){
                if let itemm = item as? NSDictionary{
                    if let uuid=itemm["uuid"] as? String {
                        let itemQuantity=itemm["quantity"] as? Int
                        if let ItemLotsArray = itemm["lots"] as? Array<NSDictionary> {
                            var itemLotsArrayTemp=ItemLotsArray as? [[String:Any]]
                            if let dictinctScannedLotArray = distinctLotList as? [[String:Any]] {
                                let filteredScannedLotArray = dictinctScannedLotArray.filter { $0["uuid"] as? String == uuid }
                                if !filteredScannedLotArray.isEmpty {
                                    var scannedlotCount=0
                                    for (index1,item1) in filteredScannedLotArray.enumerated(){
                                        let lotNumber=item1["lot_number"] as? String
                                        if ((lotNumber?.isEmpty) != nil) {
                                            let tempFilterArr = scannedLotArray!.filter { $0["lot_number"] as? String == lotNumber }
                                            scannedlotCount=scannedlotCount+tempFilterArr.count
                                            if itemLotsArrayTemp!.count>index1 {
                                                var tempDict = itemLotsArrayTemp![index1]
                                                tempDict["lot_number"]=item1["lot_number"]
                                                tempDict["expiration_date"]=item1["expDateStr"]
                                                tempDict["quantity"]=tempFilterArr.count
                                                itemLotsArrayTemp![index1]=tempDict
                                            }else{
                                                var tempDict1=[String:Any]()
                                                tempDict1["lot_number"]=item1["lot_number"]
                                                tempDict1["expiration_date"]=item1["expDateStr"]
                                                tempDict1["quantity"]=tempFilterArr.count
                                                tempDict1["best_by_date"]=""
                                                tempDict1["production_date"]=""
                                                tempDict1["sell_by_date"]=""
                                                itemLotsArrayTemp?.append(tempDict1)
                                                
                                              
                                            }
                                        }
                                    }
                                    
                                    if scannedlotCount<=itemQuantity!{
                                        var itemTemp=itemsArray![index] as? [String:Any]
                                        itemTemp!["lots"]=itemLotsArrayTemp
                                        itemsArray![index]=itemTemp!;
                                    }else{
                                        extraQtyFound=true
                                    }
                                    
                                }
                            }
                        }
                    }
                }
              
            }
            
            //---popup
            if extraQtyFound {
                self.dismiss(animated: false, completion:nil)
                isnotlotsetForeach = true
                Utility.showPopup(Title: App_Title, Message: "scanned items cannot be greater than total quantity ", InViewC: self)
            }else{
                for item in itemsArray! as NSArray{
                  if let itemm = item as? NSDictionary{
                      if let lots = itemm["lots"] as? Array<NSDictionary>{
                          if let _ = lots.first(where: {$0["lot_number"] as? String == ""}){
                              Utility.showPopup(Title: App_Title,Message : "lot not set for each product.Please scan again",InViewC:self)
                              isnotlotsetForeach = true
                              return
                          }
                      }
                  }
              }
            for item in itemsArray! as NSArray {
              let itemDict = item as! NSDictionary
                var lotOrSerial = ""
                if ((itemDict["is_having_serial"]) != nil) {
                    let ishavingSerail = itemDict["is_having_serial"] as! Bool
                    if ishavingSerail {
                        lotOrSerial = "SERIAL_BASED"
                    }else{
                        lotOrSerial = "LOT_BASED"
                    }
                }
                let lots = itemDict["lots"] as! NSArray
                for lot in lots as NSArray {
                    let lotDict = lot as! NSDictionary
                    let obj = ReceiveLotEdit(context: PersistenceService.context)
                    obj.id = ReceivingEditLotVC.getAutoIncrementId()
                    obj.lot_number = (lotDict["lot_number"] as! String)
                    if lotDict["expiration_date"] is NSNull {
                        obj.expiration_date = ""
                    }else{
                        obj.expiration_date = (lotDict["expiration_date"] != nil) ? lotDict["expiration_date"] as! String : ""
                    }
                    obj.quantity = lotDict["quantity"] as! Int16
                    obj.lot_type = lotOrSerial
                    obj.isEditable = true
                    obj.shipment_line_item_uuid = itemDict["shipment_line_item_uuid"] as? String
                    isnotlotsetForeach = false
                    PersistenceService.saveContext()
                    }
                }
                    defaults.set(true, forKey: "rec_1stStep")
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
                    controller.shipmentId = self.shipmentId ?? ""
                    controller.responseDict =  self.responseDict
                    self.navigationController?.pushViewController(controller, animated: false)
                }
            }
        
        
        print(itemsArray as Any)
        
        
        /* code for autopopulate lot no extra lot added-
         if let items = self.itemsArray{
             for (index,item) in items.enumerated(){
                 if let itemm = item as? NSDictionary{
                     if let uuid=itemm["uuid"] as? String {
                         if let ItemLotsArray = itemm["lots"] as? Array<NSDictionary> {
                             var itemLotsArrayTemp=ItemLotsArray as? [[String:Any]]
                             if let scannedLotArray = distinctLotList as? [[String:Any]] {
                                 let filteredArray = scannedLotArray.filter { $0["uuid"] as? String == uuid }
                                 if !filteredArray.isEmpty {
                                     for (index1,item1) in ItemLotsArray.enumerated(){
                                         let lotNumber=item1["lot_number"] as? String
                                         if ((lotNumber?.isEmpty) != nil) {
                                             if let tempDict=filteredArray[index1] as? [String:Any] {
                                                 itemLotsArrayTemp![index1]["lot_number"]=tempDict["lot_number"] as? String
                                                 itemLotsArrayTemp![index1]["expiration_date"]=tempDict["expDateStr"] as? String
                                             }
                                         }
                                     }
                                     var itemTemp=itemsArray![index] as? [String:Any]
                                     itemTemp!["lots"]=itemLotsArrayTemp
                                     itemsArray![index]=itemTemp!;
                                 }
                             }
                         }
                     }
                 }
                 
             }
         }
         
         */
        
//        if !uuid.isEmpty {
//            if let items=itemsArray as? [[String:Any]] {
//                if let index = items.firstIndex(where: {$0["uuid"] as! String == uuid}) {
//                    var item=items[index]
//                }
//            }
//        }
        
        
    }
    
    
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "rec_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "rec_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "rec_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "rec_4thStep")
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted{
            
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    
    func getShipmentDetails(){
        
        DispatchQueue.main.async{
            self.showSpinner(onView: self.view)
        }
        
        Utility.GETServiceCall(type: "ShipmentDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: shipmentId ?? "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                    
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: responseDict, requiringSecureCoding: false)
                        defaults.set(data, forKey: ttrShipmentDetails)
                    } catch {
                        print("Unable to Save Dictionary")
                    }
                    
                    self.populateDetails(dataDict: responseDict)
                    
                }else{
                    
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
    
    func populateDetails(dataDict:NSDictionary?){
        
        self.responseDict = dataDict
        
        if dataDict != nil{
            
            if let is_received = dataDict!["is_received"] as? Bool{
                
                if is_received{
                    Utility.showAlertWithPopAction(Title: App_Title, Message: "Shipment already received.", InViewC: self, isPop: true, isPopToRoot: true)
                    return
                }
                quarantineButton.isUserInteractionEnabled = true
                quarantineButton.alpha  = 1
              }
            if allLocations != nil{
                if let location_uuid = dataDict!["location_uuid"] as? String{
                    
                    if let locationData = allLocations![location_uuid] as? NSDictionary{
                        
                        if let sa_count = locationData["sa_count"] as? Int{
                            
                            let sa_areas = locationData["sa"] as? Array<Any>
                            
                            if sa_count == 1 {
                                if sa_areas != nil{
                                    if let object = sa_areas?.first as? NSDictionary{
                                        
                                        if let is_have_shelf = object["is_have_shelf"] as? Bool{
                                            
                                            if !is_have_shelf{
                                                
                                                Utility.saveObjectTodefaults(key: "selected_storage", dataObject: object)
                                                isFiveStep = false
                                                defaults.set(false, forKey: "isFiveStep")
                                            }else{
                                                isFiveStep = true
                                                defaults.set(true, forKey: "isFiveStep")
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }else{
                                isFiveStep = true
                                defaults.set(true, forKey: "isFiveStep")
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            udidValueLabel.text = shipmentId
            
            
            if let items:Array<Any> = dataDict!["ship_lines_item"] as? Array<Any>{
                itemsArray = items
                itemsMainArray = items
            }
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let shipDate:String = dataDict!["ship_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    shipDateValueLabel.text = formattedDate
                }
            }
            
            if let ship_eta_date:String = dataDict!["ship_eta_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_eta_date){
                    etaValueLabel.text = formattedDate
                }
            }
            
            if let ship_delivery_date:String = dataDict!["ship_delivery_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_delivery_date){
                    deliveryDateValueLabel.text = formattedDate
                }
            }
            
            
            
            if let trading_partner:NSDictionary = dataDict!["trading_partner"] as? NSDictionary{
                
                if let name = trading_partner["name"]{
                    tpValueLabel.text = name as? String
                }
                
            }
            
            if let transactions:Array<Any> = dataDict!["transactions"] as? Array<Any>{
                
                if transactions.count>0{
                    
                    let firstTransaction:NSDictionary = transactions.first as? NSDictionary ?? NSDictionary()
                    
                    if let po:String = firstTransaction["po_number"] as? String{
                        poValueLabel.text = po
                    }
                    
                    if let custom_order_id:String = firstTransaction["custom_order_id"] as? String{
                        cOrderIdValueLabel.text = custom_order_id
                    }
                    
                    if let invoice_number:String = firstTransaction["invoice_number"] as? String{
                        invoiceValueLabel.text = invoice_number
                    }
                    
                    if let order_number:String = firstTransaction["order_number"] as? String{
                        orderValueLabel.text = order_number
                    }
                    
                    if let release_number:String = firstTransaction["release_number"] as? String{
                        releaseValueLabel.text = release_number
                    }
                    
                    
                    if let ship_from:NSDictionary = firstTransaction["ship_from"] as? NSDictionary {
                        
                        if let recipient_name:String = ship_from["recipient_name"] as? String{
                            SFNickNameValueLabel.text = recipient_name
                        }
                        
                        var addressStr:String = ""
                        
                        if let line1:String = ship_from["line1"] as? String{
                            addressStr = addressStr + line1 + ", "
                        }
                        
                        
                        
                        if let line2:String = ship_from["line2"] as? String{
                            addressStr = addressStr + line2 + "\n"
                        }
                        
                        if let line3:String = ship_from["line3"] as? String{
                            addressStr = addressStr + line3 + "\n\n"
                        }
                        
                        if let city:String = ship_from["city"] as? String{
                            addressStr = addressStr + city + ", "
                        }
                        
                        if let state_name:String = ship_from["state_name"] as? String{
                            addressStr = addressStr + state_name + ", "
                        }
                        
                        if let country_name:String = ship_from["country_name"] as? String{
                            addressStr = addressStr + country_name
                        }
                        
                        if let phone:String = ship_from["phone"] as? String{
                            addressStr =  addressStr + "\n" + phone
                        }
                        
                        SFAddressValueLabel.text = addressStr
                        
                    }
                }
                
            }
            
            if let ship_to:NSDictionary = dataDict!["ship_to_location"] as? NSDictionary {
                
                if let recipient_name:String = ship_to["recipient_name"] as? String{
                    STNickNameValueLabel.text = recipient_name
                }
                
                var addressStr:String = ""
                
                if let line1:String = ship_to["line1"] as? String{
                    addressStr = addressStr + line1 + ", "
                }
                
                if let line2:String = ship_to["line2"] as? String{
                    addressStr = addressStr + line2 + "\n"
                }
                
                if let line3:String = ship_to["line3"] as? String{
                    addressStr = addressStr + line3 + "\n\n"
                }
                
                if let city:String = ship_to["city"] as? String{
                    addressStr = addressStr + city + ", "
                }
                
                if let state_name:String = ship_to["state_name"] as? String{
                    addressStr = addressStr + state_name + ", "
                }
                
                if let country_name:String = ship_to["country_name"] as? String{
                    addressStr = addressStr + country_name
                }
                
                if let phone:String = ship_to["phone"] as? String{
                    addressStr = addressStr + "\n" + phone
                }
                
                STAddressValueLabel.text = addressStr
                
            }
            
            //TODO: - For Testing 3 Steps View
            /*var dataDict = [String:Any]()
             dataDict["uuid"] = "6d72602d-6843-4adc-aedb-5d147d84ffa5"
             dataDict["name"] = "Main Storage"
             do{
             let dictData = try NSKeyedArchiver.archivedData(withRootObject: dataDict, requiringSecureCoding: false)
             defaults.set(dictData, forKey: "selected_storage")
             } catch {
             print("Unable to Save Dictionary")
             }
             
             isFiveStep = false
             defaults.set(false, forKey: "isFiveStep")*/
            //TODO: - End
            
            if !isFiveStep{
                step4Label.text = "Confirm Receiving"
                step5View.isHidden = true
                step4BarViewContainer.isHidden = true
            }
        }
    }
    
    func removeReceivingDefaults(){
        defaults.removeObject(forKey: "shipmentDetails")
        defaults.removeObject(forKey: "shipmentId")
        defaults.removeObject(forKey: "rec_1stStep")
        defaults.removeObject(forKey: "rec_2ndStep")
        defaults.removeObject(forKey: "rec_3rdStep")
        defaults.removeObject(forKey: "rec_4thStep")
        defaults.removeObject(forKey: "isFiveStep")
        defaults.removeObject(forKey: "selected_storage")
        defaults.removeObject(forKey: "selected_shelf")
    }
    
    //MARK: - End
    //MARK: - Web Service Call
    func deleteShipmentWebServiceCall(requestData:NSMutableDictionary){
        let appendStr = "\(shipmentId!)"
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "deleteReceivingShipment", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if (responseDict["uuid"] as? String) != nil {
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment deleted successfully".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
    }
    func cancelConfirmation() {
        Utility.removeReceivingLotDB()
        Utility.removeReceivingLineDB()
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
}

extension ShipmentDetailsViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            self.autoPopulateLot(scannedCode: scannedCode)
        }
    }
}
extension ShipmentDetailsViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
            self.autoPopulateLot(scannedCode: scannedCode)
        }
        
    }
}
