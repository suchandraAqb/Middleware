//
//  DPViewItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol DPViewPickedItemsViewDelegate:class{
    func reloadPickedItemsApi()
}
class DPViewPickedItemsViewController:  BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    
   
    @IBOutlet weak var quantityEditTextFiled:UITextField!
    @IBOutlet weak var lotBasedView:UIView!
    @IBOutlet var radioButtons:[UIButton]!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var lotbasedMainView:UIView!
    @IBOutlet weak var filterButton: UIButton!

    var uniqueitemsList:[Any]?
    var tempuniqueitemsList:[Any]?

    var editlotDict = NSDictionary()
    var deletelotDict = NSDictionary()
    var searchDict = NSMutableDictionary()
    var itemListShowArray:Array<Any>?
    weak var delegate:DPViewPickedItemsViewDelegate?

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        lotbasedMainView.roundTopCorners(cornerRadious: 40)
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2)
        lotBasedView.isHidden = true
        for button in radioButtons{
            if button.tag == 0{
                button.isSelected = true
            }else{
                button.isSelected = false
            }
        }
        self.createInputAccessoryView()
        self.serialBasedOrLotBasedItemsGetApiCall()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.reloadPickedItemsApi()
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func radioButtonPressed(_ sender:UIButton){
        var arr = NSArray()
        if let list = (tempuniqueitemsList as NSArray?){
            arr = list
        
        for button in radioButtons{
            button.isSelected = false
        }
        if (!sender.isSelected && sender.tag == 0) {
            sender.isSelected = true
            let predicate = NSPredicate(format:"picking_type = '\("LOT_BASED")' || picking_type = '\("GS1_SERIAL_BASED")'|| picking_type = '\("SIMPLE_SERIAL_BASED")'")
            self.uniqueitemsList = arr.filtered(using: predicate)
            listTable.reloadData()
            
        }else if(!sender.isSelected && sender.tag == 1){
            sender.isSelected = true
            let predicate = NSPredicate(format:"picking_type = '\("LOT_BASED")'")
            self.uniqueitemsList = arr.filtered(using: predicate)
            listTable.reloadData()
            
        }else if(!sender.isSelected && sender.tag == 2){
            sender.isSelected = true
            let predicate = NSPredicate(format:"picking_type = '\("GS1_SERIAL_BASED")'|| picking_type = '\("SIMPLE_SERIAL_BASED")'")
            self.uniqueitemsList = arr.filtered(using: predicate)
            listTable.reloadData()
          }
        }
    }
    @IBAction func editButtonPressed(_ sender:UIButton){
        if let itemDict = self.uniqueitemsList![sender.tag] as? NSDictionary{
            self.quantityEditTextFiled.text = itemDict["quantity"] as? String
        }
        lotBasedView.isHidden = false
        if let itemDict = uniqueitemsList?[sender.tag] as? NSDictionary{
            editlotDict = itemDict
         }
    }
    @IBAction func saveButtonPressed(_ sender:UIButton){
        if let str = quantityEditTextFiled.text,str.isEmpty{
            Utility.showPopup(Title: Warning, Message: "Lot quantity must be provided".localized(), InViewC: self)
            return
        }
        let quantity = (quantityEditTextFiled.text! as NSString).integerValue
            if !(quantity > 0) {
                Utility.showPopup(Title: Warning, Message: "Please enter quantity more than 0".localized(), InViewC: self)
                return
            }       
        lotBasedView.isHidden = true
        self.lotBasedQuantityEdit(itemDict: editlotDict)
        
    }
    @IBAction func deleteButtonPressed(_ sender:UIButton){
        
        let msg = "Are you sure? you are about to delete the picked item".localized()
        let alert = CustomAlert(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        alert.setTitleImage(UIImage(named: "warning"))

        let okaction = UIAlertAction(title: "Yes".localized(), style: .default) { (UIAlertAction) in
            if let itemDict = self.uniqueitemsList?[sender.tag] as? NSDictionary{
                self.deletelotDict = itemDict
             }
            self.deleteApiCallForRemoveLotItem(itemDict: self.deletelotDict)
        }
        let action = UIAlertAction(title: "No".localized(), style: .cancel) { (UIAlertAction) in
            self.lotBasedView.isHidden = true
        }
        alert.addAction(okaction)
        alert.addAction(action)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    @IBAction func crossButtonPressed(_ sender:UIButton){
        self.doneTyping()
        lotBasedView.isHidden = true
    }
    @IBAction func filterButtonPressed(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingFilterItemsView") as! PickingFilterItemsViewController
            if filterButton.isSelected {
                controller.searchDict = searchDict
            }
            controller.delegate = self
       self.navigationController?.pushViewController(controller, animated: false)
    }
   
    //MARK: - End
    //MARK: - Private Method
    func lotBasedQuantityEdit(itemDict:NSDictionary){
        
        let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items/\(itemDict["uuid"] ?? "")"
        var requestDict = [String:Any]()
        requestDict["quantity"] = quantityEditTextFiled.text
        requestDict["storage_area_uuid"] = itemDict["storage_area_uuid"]
    
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "PickNewItem", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                    self.removeSpinner()
                if isDone! {
                    self.serialBasedOrLotBasedItemsGetApiCall()
                    Utility.showPopup(Title: Success_Title, Message: "Lot Quantity Updated..".localized(), InViewC: self)
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
    func deleteApiCallForRemoveLotItem(itemDict:NSDictionary){
        var storageArea =  ""
        if let str = itemDict["storage_shelf_uuid"] as? String,!str.isEmpty {
            storageArea = itemDict["storage_shelf_uuid"] as! String
        }
     let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items/\(itemDict["uuid"] ?? "")?storage_area_uuid=\(itemDict["storage_area_uuid"] ?? "")&storage_area_shelf_uuid=\(storageArea)"
        var requestDict = [String:Any]()
        requestDict["storage_area_uuid"] = itemDict["storage_area_uuid"]
        requestDict["storage_shelf_uuid"] = itemDict["storage_area_shelf_uuid"]
    
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "PickNewItem", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    self.serialBasedOrLotBasedItemsGetApiCall()
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
    func serialBasedOrLotBasedItemsGetApiCall(){
        self.showSpinner(onView: self.view)
        UserInfosModel.UserInfoShared.serialBasedOrLotBasedItemsGetApiCall(ServiceCompletion:{ isDone, itemArr in
            self.removeSpinner()
            if itemArr != nil && !(itemArr?.isEmpty ?? false) {
                self.uniqueitemsList = itemArr
                self.tempuniqueitemsList = itemArr
                Utility.saveObjectTodefaults(key: "PickedItemCount", dataObject: self.uniqueitemsList ?? "")
                for button in self.radioButtons {
                    if button.isSelected{
                        self.radioButtonPressed(button)
                    }
                }
                if self.filterButton.isSelected {
                    self.searchFilterData(productUuid: self.searchDict["product_uuid"] as! String, productName: self.searchDict["product_name"] as! String, lot: self.searchDict["lot"] as! String, serial: self.searchDict["serial"] as! String, ndc: self.searchDict["NDC"] as! String, dateStr: self.searchDict["expirationDate"] as! String)
                }
            }else{
                self.uniqueitemsList = []
            }
            self.listTable.reloadData()
        })
    
    }
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
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return uniqueitemsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        if let dataDict = uniqueitemsList?[indexPath.section] as? NSDictionary{
            var product_type = ""
            if let name = dataDict["picking_type"] as? String,!name.isEmpty{
                if name == "GS1_SERIAL_BASED" || name == "SIMPLE_SERIAL_BASED"{
                    product_type = "Serial Based"
                }else{
                    product_type = "Lot Based"
                }
            }
            cell.udidValueLabel.text = product_type

            if product_type == "Serial Based" {
               cell.editButton.isHidden = true
            }else{
                cell.editButton.isHidden = false
            }
            
            var product_name = ""
            if let name = dataDict["product_name"] as? String,!name.isEmpty{
                product_name = name
            }
            cell.productNameLabel.text = product_name
            
            cell.quantityLabel.text = dataDict["quantity"] as? String
           
            var product_sku = ""
            if let name = dataDict["sku"] as? String,!name.isEmpty{
                product_sku = name
            }
            cell.skuValueLabel.text = product_sku
                        
            if let identifiersArray = dataDict["identifiers"] as? NSArray{
                if let identifiersDict = identifiersArray.firstObject{
                    let dict = identifiersDict as? NSDictionary
                    cell.ndcLabel.text = dict?["type"] as? String
                    cell.ndcValueLabel.text = dict?["value"] as? String
                }
            }
            
            var lotNumber = ""
            if let lotArr = dataDict["lots"] as? NSArray {
                if let lotstr = lotArr.firstObject as? NSString {
                    lotNumber = lotstr as String
                }
            }
            
            cell.lotValueLabel.text = lotNumber
            
            var lot_exp = ""
            if let lot_expArr = dataDict["lot_expirations"] as? NSArray{
                lot_exp = lot_expArr.firstObject as! String
            }
            cell.expirationDateLabel.text = lot_exp
            
          var serial = ""
            if let serialArr = dataDict["serials"] as? NSArray,serialArr.count>0{
                if let str = serialArr.firstObject as? String{
                    serial = str
                }
           }
            cell.serialNumberText.text = serial
        
        }
        cell.editButton.tag = indexPath.section
        cell.deleteButton.tag = indexPath.section
        
//        var product_uuid = ""
//        if let uuid = uniqueitemsList?[indexPath.section]  as? String{
//            product_uuid = uuid
//        }
//
//        let predicate = NSPredicate(format:"product_uuid='\(product_uuid)'")
//        let arr = itemsList! as NSArray
//        let filterArray = arr.filtered(using: predicate)
//
//
//        var dataDict:NSDictionary?
//
//        var quantity = ""
//        if !filterArray.isEmpty && filterArray.count>0 {
//            dataDict = filterArray.first as? NSDictionary
//            if let qty = (filterArray as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
//                quantity = "\(qty.intValue)"
//            }
//        }
//
//        var dataStr:String = "Container"
//
//        if let name = dataDict?["product_name"]  as? String , !name.isEmpty{
//            dataStr = name
//            cell.viewSerialButton.isHidden = false
//        }else{
//            cell.viewSerialButton.isHidden = true
//        }
//
//
//        cell.productNameLabel.text = dataStr
//
//        dataStr = ""
//
//        cell.quantityLabel.text = quantity
//
//        dataStr = ""
//        if let uuid = dataDict?["product_uuid"]  as? String{
//            dataStr = uuid
//        }
//
//        cell.udidValueLabel.text = dataStr
//
//        dataStr = ""
//        if let ndc = dataDict?["identifier_value"]as? String{
//            dataStr = ndc
//        }
//
//        cell.ndcValueLabel.text = dataStr
//
//        dataStr = ""
//
//        if let gtin14 = dataDict?["gtin"]  as? String{
//            dataStr = gtin14
//        }
//
//        cell.skuValueLabel.text = dataStr
//
//        cell.viewSerialButton.tag = indexPath.section
        
        
        return cell
        
    }
    //MARK: - End
    
    
}

extension DPViewPickedItemsViewController : PickingFilterItemsViewDelegate{
    func searchFilterData(productUuid: String, productName: String, lot: String, serial: String, ndc: String, dateStr: String) {
        if let responseDict: NSDictionary =  Utility.getObjectFromDefauls(key: "PickedData") as? NSDictionary{
                if let list = responseDict["data"] as? Array<[String:Any]>{
                    self.uniqueitemsList = list
            }
            if uniqueitemsList!.count > 0 {

            searchDict.setValue(productUuid, forKey: "product_uuid")
            searchDict.setValue(productName, forKey: "product_name")
            searchDict.setValue(serial, forKey: "serial")
            searchDict.setValue(lot, forKey: "lot")
            searchDict.setValue(ndc, forKey: "NDC")
            searchDict.setValue(dateStr, forKey: "expirationDate")

            
            filterButton.isSelected = true
            
            if !productUuid.isEmpty{
                let predicate = NSPredicate(format: "product_uuid = '\(productUuid)'")
                uniqueitemsList = (uniqueitemsList! as NSArray).filtered(using: predicate)
            }
            if !productName.isEmpty{
                let predicate = NSPredicate(format: "product_name CONTAINS[c] '\(productName)'")
                uniqueitemsList = (uniqueitemsList! as NSArray).filtered(using: predicate)
            }
            if !lot.isEmpty{
                let lotmainArr = NSMutableArray()
                let uniqueArr = uniqueitemsList! as NSArray
                for item in uniqueArr {
                    let itemdict = item as? NSDictionary
                    let arr = itemdict?["lots"] as? NSArray
                    if let lotStr = arr?.firstObject as? String,!lotStr.isEmpty{
                           if lotStr == lot {
                               lotmainArr.add(item)
                           }
                        }
                   }
                uniqueitemsList = lotmainArr.mutableCopy() as? [Any]
            }
                
            if !serial.isEmpty{
                let serialmainArr = NSMutableArray()
                let uniqueArr = uniqueitemsList! as NSArray

                for item in uniqueArr {
                    let itemdict = item as? NSDictionary
                    let arr = itemdict?["serials"] as? NSArray
                    if let serailsStr = arr?.firstObject as? String,!serailsStr.isEmpty{
                           if serailsStr == serial {
                               serialmainArr.add(item)
                           }
                        }
                   }
                uniqueitemsList = serialmainArr.mutableCopy() as? [Any]

            }
            if !ndc.isEmpty{
                let ndcmainArr = NSMutableArray()
                let uniqueArr = uniqueitemsList! as NSArray

                for item in uniqueArr {
                    let itemdict = item as? NSDictionary
                    let arr = itemdict?["identifiers"] as? NSArray
                    if let ndcDict = arr?.firstObject as? NSDictionary{
                        var ndcStr = ndcDict["value"] as? String
                                ndcStr = ndcStr?.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                        let ndcSerach = ndc.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                                if ndcStr == ndcSerach {
                                    ndcmainArr.add(item)
                              }
                           }
                     }
                    uniqueitemsList = ndcmainArr.mutableCopy() as? [Any]
                 }
                if !dateStr.isEmpty && (dateStr != "Expiration Date"){
                    let expirationmainArr = NSMutableArray()
                    let uniqueArr = uniqueitemsList! as NSArray

                    for item in uniqueArr {
                        let itemdict = item as? NSDictionary
                        let arr = itemdict?["lot_expirations"] as? NSArray
                        if let expStr = arr?.firstObject as? String,!expStr.isEmpty{
                               if expStr == dateStr {
                                   expirationmainArr.add(item)
                               }
                            }
                       }
                    uniqueitemsList = expirationmainArr.mutableCopy() as? [Any]
                }
             }
          
            tempuniqueitemsList = uniqueitemsList
            
            for button in self.radioButtons {
                if button.isSelected{
                    self.radioButtonPressed(button)
                }
            }
            listTable.reloadData()
        }
    }
    func clearAll(){
        searchDict = NSMutableDictionary()
        filterButton.isSelected = false
        self.serialBasedOrLotBasedItemsGetApiCall()
    }
}
