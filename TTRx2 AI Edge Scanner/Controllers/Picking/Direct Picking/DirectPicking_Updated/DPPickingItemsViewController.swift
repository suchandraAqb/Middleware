//
//  DPPickingItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol DPPickingItemsDelegate:class{
     func refreshItemsList()
}
class DPPickingItemsViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var productNameLabel:UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var ndcLabel:UILabel!
    @IBOutlet weak var ndcValueLabel:UILabel!
    @IBOutlet weak var expirationDateLabel:UILabel!
    @IBOutlet weak var storageAreaButton:UIButton!
    @IBOutlet weak var storageshelfButton:UIButton!
    @IBOutlet weak var lotButton:UIButton!
    @IBOutlet weak var availableQuantity:UILabel!
    @IBOutlet weak var upcLabel:UILabel!
    @IBOutlet weak var scanView:UIView!
    @IBOutlet weak var detailsView:UIView!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var lotbasedView:UIView!
    @IBOutlet weak var lotbasedMainView:UIView!
    @IBOutlet weak var lotbaseEnterQuantityPickedForShelfTextField:UITextField!
    @IBOutlet weak var addLotButtonQuantity:UIButton!

    var delegate : DPPickingItemsDelegate?
    var storageAreas : Array<Any>?
    var shelfs : Array<Any>?
    var serialList : Array<Any>?
    var pickItemDetails = NSDictionary()
    var lotListArray = NSArray ()
    var allScannedSerials = Array<String>()
    var duplicateSerials = Array<String>()
    var verifiedSerials = Array<Dictionary<String,Any>>()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.setRoundCorner(cornerRadious: 10)
        scanView.setRoundCorner(cornerRadious: 10)
        lotbasedMainView.roundTopCorners(cornerRadious: 40)
        addLotButtonQuantity.setRoundCorner(cornerRadious: addLotButtonQuantity.frame.size.height/2)
        lotbasedView.isHidden = true
        productCountLabel.isHidden = true
        itemsCountLabel.isHidden = true
        self.createInputAccessoryView()
        self.lots_autocompleteApiCall()
    }
    //MARK: - End
    //MARK: - API Call
    func lots_autocompleteApiCall(){
        var product_uuid = ""
        if let productuuid = pickItemDetails["product_uuid"] as? String,!productuuid.isEmpty{
            product_uuid = productuuid
         }
        let appendStr:String! = "/?location_uuid=\(defaults.object(forKey: "SOPickingLocationUUID") ?? "")&product_uuid=\(product_uuid)&lot_type=ANY&is_in_stock_only=true&sort_by_asc=true&nb_per_page=500&page=1"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetLotListOfLocation", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseArray: NSArray = responseData as? NSArray{
                        self.lotListArray = responseArray
                
                    }
                  
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
                self.setupPickItemsDetails()

            }
        }
    }
    
    
    func serialBasedOrLotBasedItemsAdd(isFromSerial:Bool,serailList:NSArray,scancode:[String]){
        
        let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items"
        var requestDict = [String:Any]()
        if isFromSerial {
            requestDict["picking_type"] = "SIMPLE_SERIAL_BASED"
            requestDict["quantity"] = 0
            let str = serailList.componentsJoined(by: "\n")
            requestDict["serials"] = str
        }else{
            requestDict["picking_type"] = "LOT_BASED"
            requestDict["quantity"] = lotbaseEnterQuantityPickedForShelfTextField.text
            requestDict["serials"] = ""
        }
        requestDict["product_shipment_line_item_uuid"] = pickItemDetails["shipment_line_item_uuid"]
        requestDict["product_sku"] = ""
        requestDict["product_upc"] = ""
        requestDict["product_identfier_code"] = ""
        requestDict["product_identfier_value"] = ""
        requestDict["lot_number"] = lotButton.titleLabel?.text
        requestDict["storage_area_uuid"] = storageAreaButton.accessibilityHint
        requestDict["storage_area_shelf_uuid"] = storageshelfButton.accessibilityHint
        requestDict["is_remove_item_if_already_found"] = false
        requestDict["is_remove_from_parent_container"] = true
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "PickNewItem", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseArray: NSArray = responseData as? NSArray{
                        if responseArray.count > 0 {
                            self.delegate?.refreshItemsList()
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "Product Added".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                        }
                    }
                  
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
    func storageAreaDetails(){
        let userinfo = UserInfosModel.UserInfoShared
        self.showSpinner(onView: self.view)
        userinfo.getStorageAreasOfALocation(location_uuid: (defaults.object(forKey: "SOPickingLocationUUID") ?? "") as! String) { isDone, sa in
            self.removeSpinner()
            if sa != nil && !(sa?.isEmpty ?? false){
                self.storageAreas = sa
            }
        }
    }
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = (defaults.object(forKey: "SOPickingLocationUUID") ?? "") as! String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                           self.shelfs = list
                            
                            let shelfDict = self.shelfs?.first as? NSDictionary
                            if let name = shelfDict?["name"] as? String{
                                self.storageshelfButton.setTitle(name, for: .normal)

                                if let uuid = shelfDict?["storage_shelf_uuid"] as? String {
                                    self.storageshelfButton.accessibilityHint = uuid
                                }
                            }
                        }
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
    
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func dropdownButtonPressed(_ sender:UIButton){
     if lotListArray.count > 0 {
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPLotBasedUpdatedView") as! DPLotBasedUpdatedViewController
         controller.lots = lotListArray as? Array
         controller.delegate = self
         self.present(controller,animated: true,completion: nil)
       }
    }
    @IBAction func storageButtonPressed(_ sender:UIButton){
        
        if storageAreas == nil {
            return
        }
        sender.tag = 1
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = storageAreas as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Storage Area".localized()
        controller.sender = storageAreaButton
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
           
    }
    @IBAction func shelfButtonPressed(_ sender:UIButton){
        
            
            if shelfs == nil || shelfs?.count == 0 {
                getShelfList(storageAreaUUID: storageAreaButton.accessibilityHint ?? "")
                return
            }
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = shelfs as! Array<[String:Any]>
            controller.type = "Storage Shelf".localized()
            controller.delegate = self
            controller.sender = storageshelfButton
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
    }
    @IBAction func cameraButtonPressed(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        controller.delegate = self
        controller.pickSOItemDetails = pickItemDetails
        controller.lotnumberselected = lotButton.titleLabel?.text as NSString?
        controller.isSOPickItemSelction = true
        self.navigationController?.pushViewController(controller, animated: true)

    }
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPViewPickedItems") as! DPViewPickedItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func pickItemsByLotBasePressed(_ sender:UIButton){
        lotbaseEnterQuantityPickedForShelfTextField.text = ""
        lotbasedView.isHidden = false
    }
    @IBAction func addLotBasePressed(_ sender:UIButton){
        if let str = lotbaseEnterQuantityPickedForShelfTextField.text,str.isEmpty{
            Utility.showPopup(Title: Warning, Message: "Lot quantity must be provided.", InViewC: self)
            return
        }
        let quantity = (lotbaseEnterQuantityPickedForShelfTextField.text! as NSString).integerValue
            if !(quantity > 0) {
                Utility.showPopup(Title: Warning, Message: "Please enter quantity more than 0".localized(), InViewC: self)
                return
        }
        lotbasedView.isHidden = true
        self.serialBasedOrLotBasedItemsAdd(isFromSerial: false, serailList: [], scancode: [])
    }
    @IBAction func crossButtonPressed(_ sender:UIButton){
        self.doneTyping()
        lotbasedView.isHidden = true
    }
    //MARK: - End
    //MARK: - Private Method
    func setupPickItemsDetails(){
        
        var dataStr:String = ""
         if let productName = pickItemDetails["product_name"] as? String,!productName.isEmpty{
             dataStr = productName
        }
        productNameLabel.text = dataStr
        
        dataStr = ""
        if let productUps = pickItemDetails["product_upc"] as? String,!productUps.isEmpty{
            dataStr = productUps
        }
        upcLabel.text = dataStr
        
        dataStr = ""
        if let product_sku = pickItemDetails["product_sku"] as? String,!product_sku.isEmpty{
            dataStr = product_sku
        }
        skuLabel.text = dataStr
        
        dataStr = ""
        if let product_expiration = pickItemDetails["expiration_date"] as? String,!product_expiration.isEmpty{
            dataStr = product_expiration
        }
        expirationDateLabel.text = dataStr
        
        dataStr = ""
        if let storageArea = pickItemDetails["storage_area_name"] as? String,!storageArea.isEmpty{
            dataStr = storageArea
        }
        storageAreaButton.setTitle(dataStr, for: .normal)
        storageAreaButton.accessibilityHint = pickItemDetails["storage_area_uuid"] as? String
        
        dataStr = ""
        if let shelfArea = pickItemDetails["shelf_area_name"] as? String,!shelfArea.isEmpty{
            dataStr = shelfArea
        }
        storageshelfButton.setTitle(dataStr, for: .normal)
        storageshelfButton.accessibilityHint = pickItemDetails["shelf_area_uuid"] as? String
        
        dataStr = ""
        if let lotNumber = pickItemDetails["lot_number"] as? String,!lotNumber.isEmpty{
            dataStr = lotNumber
        }
        lotButton.accessibilityHint = dataStr
        lotButton.setTitle(dataStr, for: .normal)
        self.lotButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)

        
        if let identifier = pickItemDetails["product_identifiers"] as? [[String:Any]],!identifier.isEmpty{
            if let firstObj = identifier.first,!firstObj.isEmpty{
                if let type = firstObj["identifier_code"] as? String, !type.isEmpty{
                    ndcLabel.text = type

                }
                if let value = firstObj["value"] as? String, !value.isEmpty{
                    ndcValueLabel.text = value
                }
            }
        }
        dataStr = ""
        let predicate = NSPredicate(format: "lot_number = '\(self.lotButton.titleLabel?.text ?? "")'")
        let filterArr = self.lotListArray.filtered(using: predicate)
        if filterArr.count > 0 {
            let dict = filterArr.first as! NSDictionary
            if let availableQuantity = dict["total_available_quantity"] as? NSString{
                dataStr = "\(availableQuantity.intValue)"
            }
        }
        self.availableQuantity.text = dataStr
        self.storageAreaDetails()
        self.getShelfList(storageAreaUUID: storageAreaButton.accessibilityHint ?? "")
    }
    
  
    func populateProductandItemsCount(items:String?){
        var str = ""
        if items!.count > 1 {
            str = "items added."
        }else{
            str = "item added."
        }
        productCountLabel.isHidden = false
        productCountLabel.text = "\(items ?? "") \(str)"
    }
    //MARK: - End
    //MARK: - IBAction
    
  
    //MARK: - End
    //MARK: - textField Delegate
       func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.inputAccessoryView = inputAccView
          
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
          
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool
       {
           textField.resignFirstResponder()
           return true
       }
    //MARK: - End
    
    
    //MARK: - SingleSelectDropdownDelegate

        func selecteditem(data: NSDictionary,sender:UIButton?) {
            if sender == lotButton {
                if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
                    if lotNumber == lotButton.accessibilityHint{
                        var dataStr = ""
                        if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
                            dataStr = lotNumber
                        }
                        self.lotButton.setTitle(dataStr, for: .normal)
                        self.lotButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)
                        
                        dataStr = ""
                        if let expirationDate = data["lot_expiration"] as? String,!expirationDate.isEmpty{
                            dataStr = expirationDate
                        }
                        self.expirationDateLabel.text = dataStr
                        
                        dataStr = ""
                        if let availableQuantity = data["total_available_quantity"] as? NSString{
                            dataStr = "\(availableQuantity.intValue)"
                        }
                        self.availableQuantity.text = dataStr
                    }
                  else{
                      let msg = "Picking will be done with a different lot than what was suggested.Do you want to continue?".localized()
                      let confirmAlert = CustomAlert(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
                      confirmAlert.setTitleImage(UIImage(named: "warning"))

                    let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: { (UIAlertAction) in
                   
                    })
                    let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
                   
                        var dataStr = ""
                        if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
                            dataStr = lotNumber
                        }
                        self.lotButton.setTitle(dataStr, for: .normal)
                        self.lotButton.setTitleColor(Utility.hexStringToUIColor(hex: "F1AB2C"), for: .normal)
                   
                        dataStr = ""
                        if let expirationDate = data["lot_expiration"] as? String,!expirationDate.isEmpty{
                            dataStr = expirationDate
                        }
                        self.expirationDateLabel.text = dataStr
                   
                        dataStr = ""
                        if let availableQuantity = data["total_available_quantity"] as? NSString{
                            dataStr = "\(availableQuantity.intValue)"
                        }
                        self.availableQuantity.text = dataStr
                    })
                    confirmAlert.addAction(action)
                    confirmAlert.addAction(okAction)
                    self.navigationController?.present(confirmAlert, animated: true, completion: nil)
                    }
                  }
                }else if sender == storageAreaButton{
                   
                   if let name = data["name"] as? String{
                       storageAreaButton.setTitle(name, for: .normal)
                       
                        if let uuid = data["uuid"] as? String{
                            storageAreaButton.accessibilityHint = uuid
                       }
                       
                   }
                self.getShelfList(storageAreaUUID: storageAreaButton.accessibilityHint ?? "")
                   
               }else{
                   
                   if let name = data["name"] as? String{
                       storageshelfButton.setTitle(name, for: .normal)

                       if let uuid = data["storage_shelf_uuid"] as? String {
                           storageshelfButton.accessibilityHint = uuid
                       }
                   }
               }
           }
        }

    //MARK: - DPLotBasedUpdatedViewDelegate
    extension DPPickingItemsViewController:DPLotBasedUpdatedViewDelegate{
      func didLotAdded(data:NSDictionary){
        
        if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
            if lotNumber == lotButton.accessibilityHint{
                var dataStr = ""
                if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
                    dataStr = lotNumber
                }
                self.lotButton.setTitle(dataStr, for: .normal)
                self.lotButton.setTitleColor(Utility.hexStringToUIColor(hex: "072144"), for: .normal)
                
                dataStr = ""
                if let expirationDate = data["lot_expiration"] as? String,!expirationDate.isEmpty{
                    dataStr = expirationDate
                }
                self.expirationDateLabel.text = dataStr
                
                dataStr = ""
                if let availableQuantity = data["total_available_quantity"] as? NSString{
                    dataStr = "\(availableQuantity.intValue)"
                }
                self.availableQuantity.text = dataStr
            }
          else{
              let msg = "Picking will be done with a different lot than what was suggested.Do you want to continue?".localized()
              let confirmAlert = CustomAlert(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
            confirmAlert.setTitleImage(UIImage(named: "warning"))

            let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: { (UIAlertAction) in
           
            })
            let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
           
                var dataStr = ""
                if let lotNumber = data["lot_number"] as? String,!lotNumber.isEmpty{
                    dataStr = lotNumber
                }
                self.lotButton.setTitle(dataStr, for: .normal)
                self.lotButton.setTitleColor(Utility.hexStringToUIColor(hex: "F1AB2C"), for: .normal)
           
                dataStr = ""
                if let expirationDate = data["lot_expiration"] as? String,!expirationDate.isEmpty{
                    dataStr = expirationDate
                }
                self.expirationDateLabel.text = dataStr
           
                dataStr = ""
                if let availableQuantity = data["total_available_quantity"] as? NSString{
                    dataStr = "\(availableQuantity.intValue)"
                }
                self.availableQuantity.text = dataStr
            })
            confirmAlert.addAction(action)
            confirmAlert.addAction(okAction)
            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
            }
          }
        }
    }
extension DPPickingItemsViewController : ScanViewControllerDelegate{
    
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        if scannedCode.isEmpty{
            Utility.showPopup(Title: App_Title, Message: "No scanned serials found.".localized(), InViewC: self)
            return
        }
        DispatchQueue.main.async{
            var serialNumber = ""
            self.serialList = []
            for code in scannedCode{
                let details = UtilityScanning(with:code).decoded_info
                if details.count > 0 {
                    if(details.keys.contains("21")){
                        if let serial = details["21"]?["value"] as? String{
                            serialNumber = serial
                            self.serialList?.append(serialNumber)
                        }
                    }
                }
            }
            self.serialBasedOrLotBasedItemsAdd(isFromSerial: true, serailList: self.serialList! as NSArray, scancode: scannedCode)
            
        }
    }
}
