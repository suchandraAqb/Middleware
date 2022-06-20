//
//  DPLotBasedViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData
@objc protocol DPLotBasedViewControllerDelegate: class{
    @objc optional func didAddedLotBasedProduct()
}
class DPLotBasedViewController: BaseViewController,DPAddLotBasedDelegate,UITableViewDataSource, UITableViewDelegate,DPProductLotStorageDelegate {
    weak var delegate : DPLotBasedViewControllerDelegate?

    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    var uniqueProductsArray:Array<Any>?
    
    @IBOutlet weak var dataContainer: UIView!
    @IBOutlet weak var addMoreButton: UIButton!
    
    @IBOutlet weak var quantityUpdateView: UIView!
    @IBOutlet weak var quantityUpdateContainer: UIView!
    @IBOutlet weak var quantityUpdateTextField: UITextField!
    @IBOutlet weak var quantityUpdateButton: UIButton!
    @IBOutlet weak var scanDisclaimerLabel: UILabel!
    var isFromScan:Bool?
    var scanLotbasedArray:Array<Any>?
    var dpProductList : Array<Any>?

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let headerNib = UINib.init(nibName: "PickingLotbasedListHeader", bundle: Bundle.main)
        listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "PickingLotbasedListHeader")
        
        let footerNib = UINib.init(nibName: "LotBasedFooterView", bundle: Bundle.main)
        listTable.register(footerNib, forHeaderFooterViewReuseIdentifier: "LotBasedFooterView")
        
        
        
        sectionView.roundTopCorners(cornerRadious: 40)
        dataContainer.roundTopCorners(cornerRadious: 40)
        quantityUpdateContainer.setRoundCorner(cornerRadious: 20)
        addMoreButton.setRoundCorner(cornerRadious: addMoreButton.frame.size.height/2.0)
        quantityUpdateButton.setRoundCorner(cornerRadious: quantityUpdateButton.frame.size.height/2.0)
        quantityUpdateTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        createInputAccessoryView()
        quantityUpdateTextField.inputAccessoryView = inputAccView
        
        if isFromScan ?? false {
            scanDisclaimerLabel.text = "Some serials did not match exactly but quantity could be found with their Product/Lot combination.\nThose items are scanned as Lot based".localized()
        }else{
            scanDisclaimerLabel.text = ""
        }
        addMoreButton.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupList()
        addMoreButton.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doneTyping()
    }
    //MARK: - End
    
    //MARK: - Private method
    func setupList(){
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and quantity>0")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                let uniqueArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid")
                uniqueProductsArray = uniqueArr as? Array<Any>
                print(uniqueProductsArray?.first as Any)
                itemsList = arr
                dataContainer.isHidden = false
                listTable.reloadData()
            }else{
                uniqueProductsArray = nil
                itemsList = nil
                listTable.reloadData()
                dataContainer.isHidden = true
            }
        }catch let error{
            print(error.localizedDescription)
            uniqueProductsArray = nil
            itemsList = nil
            listTable.reloadData()
            dataContainer.isHidden = true
            
        }
    }
    
    func removeLot(data:NSDictionary){
        var product_uuid = ""
        var lot_no = ""
        
        if let txt = data["product_uuid"] as? String{
            product_uuid = txt
        }
        
        if let txt = data["lot_no"] as? String{
            lot_no = txt
        }
        
        do{
            let predicate = NSPredicate(format:"product_uuid='\(product_uuid)' and lot_no = '\(lot_no)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                for obj in serial_obj {
                    PersistenceService.context.delete(obj)
                    PersistenceService.saveContext()
                }
                
            }
            
            setupList()
        }catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    
    func removeProduct(data:NSDictionary,lotNumber:String){
        var product_uuid = ""
        var lot_no = ""
        
        if let txt = data["product_uuid"] as? String{
            product_uuid = txt
        }
        
        if let txt = lotNumber as? String{
            lot_no = txt
        }
        
        do{
            let predicate = NSPredicate(format:"product_uuid='\(product_uuid)' and lot_no = '\(lot_no)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                for obj in serial_obj {
                    PersistenceService.context.delete(obj)
                    PersistenceService.saveContext()
                }
                
            }
            
            setupList()
        }catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    func addProduct(quantity:String, product:NSDictionary){
        
        var product_uuid = ""
        var lot_no = ""
        
        if let txt = product["product_uuid"] as? String{
            product_uuid = txt
        }
        
        if let txt = product["lot_no"] as? String{
            lot_no = txt
        }
        
        do{
            let predicate = NSPredicate(format:"product_uuid='\(product_uuid)' and lot_no = '\(lot_no)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                for obj in serial_obj {
                    obj.quantity = 0
                    PersistenceService.saveContext()
                }
                
                serial_obj.first?.quantity = Int16(quantity)!
                PersistenceService.saveContext()
                
                //self.quantityUpdateView.isHidden = true
                self.quantityUpdater(view: self.quantityUpdateView, isHidden: true)
                
                Utility.showPopup(Title: Success_Title, Message: "Lot Quantity Updated..".localized() , InViewC: self)
                
            }
            
            setupList()
        }catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    func fetchItemsWithNoStorage() -> [NSManagedObject]{
        
        var return_obj = [NSManagedObject]()
        
        do{
             let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and storage_uuid = ''")
             return_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
        
        
            
        }catch let error{
            print(error.localizedDescription)
                   
        }
        
        return return_obj
        
    }
    func serialBasedOrLotBasedItemsAdd(quantity:String,lotNumber:String,storageArea:String,storageShelf:String,shipmentLineItem:String){
            
            let appendStr:String! = "/\(defaults.object(forKey: "SOPickingUUID") ?? "")/items"
            var requestDict = [String:Any]()
            requestDict["picking_type"] = "LOT_BASED"
            requestDict["serials"] = ""
            requestDict["quantity"] = quantity
            requestDict["lot_number"] = lotNumber
            requestDict["storage_area_uuid"] = storageArea
            requestDict["storage_area_shelf_uuid"] = storageShelf
            requestDict["is_remove_item_if_already_found"] = false
            requestDict["is_remove_from_parent_container"] = true
            requestDict["product_shipment_line_item_uuid"] = shipmentLineItem
            
            self.showSpinner(onView: self.view)
            Utility.POSTServiceCall(type: "PickNewItem", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        if let responseArray: NSArray = responseData as? NSArray{
                            if responseArray.count > 0{
                                self.delegate?.didAddedLotBasedProduct!()
                                self.removeProduct(data: responseArray.firstObject as! NSDictionary,lotNumber:lotNumber)
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
        //MARK: - End
    func prepareLotdata(){
       do{
           let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and is_container = false")
           let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
           if !serial_obj.isEmpty{
               let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
               
               if let uniqueProductArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                   
                   for product_uuid in uniqueProductArr {
                       
                       do{
                           let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and is_container = false")
                           let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                           if !serial_obj.isEmpty{
                               let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                               if let uniqueLotArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>{
                                   
                                   
                                   for lot_no in uniqueLotArr {
                                       
                                       do{
                                           let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true and product_uuid='\(product_uuid)' and lot_no='\(lot_no)' and is_container = false")
                                           let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
                                           
                                           if !serial_obj.isEmpty{
                                               //let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                                               
                                               let obj = serial_obj.first
                                               var dict = [String : Any]()
                                               dict["type"] = Product_Types.LotBased.rawValue
                                               dict["product_uuid"] = obj?.product_uuid ?? ""
                                               dict["lot_number"] = lot_no
                                               dict["storage_area_uuid"] = obj?.storage_uuid ?? ""
                                               dict["storage_area_shelf_uuid"] = obj?.shelf_uuid ?? ""
                                               dict["quantity"] = serial_obj.reduce(0) { $0 + ($1.value(forKey: "quantity") as? Int64 ?? 0) }
                                               
                                               let arr = NSMutableArray()
                                               arr.addObjects(from: dpProductList!)
                                               let predicate = NSPredicate(format: "product_uuid = '\(obj?.product_uuid ?? "")'")
                                               let filterArr = arr.filtered(using: predicate)
                                               
                                               if filterArr.count > 0 {
                                                   let dict1 = filterArr.first as? NSDictionary
                                                   let shipmentStr = dict1?["shipment_line_item_uuid"] as? String
                                                   
                                                   self.serialBasedOrLotBasedItemsAdd(quantity: "\(serial_obj.reduce(0) { $0 + ($1.value(forKey: "quantity") as? Int64 ?? 0) })", lotNumber: "\(lot_no)" , storageArea: obj?.storage_uuid ?? "" , storageShelf: obj?.shelf_uuid ?? "",shipmentLineItem: shipmentStr ?? "")
                                               }
                                           }
                                       }catch let error{
                                           print(error.localizedDescription)
                                       }
                                       
                                       
                                   }
                                   
                                   
                               }
                               
                               
                           }
                       }catch let error{
                           print(error.localizedDescription)
                       }
                       
                       
                   }
                   
               }
           }
       }catch let error{
           print(error.localizedDescription)
       }
    }
    //MARK: - End
    
    //MARK: - IBAction
    
    @IBAction func quantityUpdateButtonPressed(_ sender: UIButton) {
        
        let quantity =   quantityUpdateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        
        if (quantity as NSString).intValue <= 0 {
            Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            var maxQuantity = 1
            
            if let qty = dict["lot_max_quantity"] as? Int {//quantity
                maxQuantity = qty
            }
            
            if (quantity as NSString).intValue > maxQuantity {
                Utility.showPopup(Title: App_Title, Message: "Quantity not available. Max available quantity".localized() + " \(maxQuantity)", InViewC: self)
                return
            }
            
           addProduct(quantity: quantity,product: dict)
        }
    }
    
    @IBAction func selectStorageButtonPressed(_ sender: UIButton) {
       
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            var product_uuid = ""
            var lot_no = ""
            
            if let txt = dict["product_uuid"] as? String{
                product_uuid = txt
            }
            
            if let txt = dict["lot_no"] as? String{
                lot_no = txt
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPProductLotStorageView") as! DPProductLotStorageViewController
            controller.productLot = lot_no
            controller.product_uuid = product_uuid
            controller.delegate = self
            controller.isFromList = true
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }
        
    }
    
    @IBAction func cancelQuantityUpdateButtonPressed(_ sender: UIButton) {
        //quantityUpdateView.isHidden = true
        self.quantityUpdater(view: self.quantityUpdateView, isHidden: true)
    }
    
    @IBAction func addProductButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPAddLotBasedView") as! DPAddLotBasedViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func doneButtonpressed(_ sender: UIButton) {
        
        if !fetchItemsWithNoStorage().isEmpty{
            Utility.showPopup(Title: App_Title, Message: "There are Lot(s) which dont have storage . Please select storage to continue..".localized(), InViewC: self)
            return
        }
        if sender.tag == 1 {
            self.navigationController?.popViewController(animated: false)
        }else{
            prepareLotdata()
            //delegate?.didAddedLotBasedProduct!()
            //self.navigationController?.popViewController(animated: false)
        }
            
    }
    
    @IBAction func crossButtonpressed(_ sender: UIButton) {
        
        let msg = "You are about to delete the resource.\nThis operation can’t be undone.\n\nProceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeLot(data: dict)
            }
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func lotQuantityButtonPressed(_ sender: UIButton) {
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            let prvQuan = dict["quantity"] as! Int32
            quantityUpdateTextField.text = "\(prvQuan)"
            quantityUpdateButton.tag = sender.tag
        }
        
        //quantityUpdateView.isHidden = false
        self.quantityUpdater(view: self.quantityUpdateView, isHidden: false)
    }
    
    //MARK: - End
    
    //MARK: - Tableview Delegate and Datasource
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat{
        return 123
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PickingLotbasedListHeader") as! PickingLotbasedListHeader
        
        if let uuid = uniqueProductsArray?[section] as? String {
            headerView.uuidLabel.text = uuid
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                if filterArray.count > 0 {
                    let arr = filterArray as NSArray?
                    let narr = arr?.value(forKeyPath: "quantity") as? Array<Int>
                    let sum = narr?.sum()
                    print("Total Quantity: \(String(describing: sum!))")
                    
                    headerView.quantityLabel.text = "\(String(describing: sum!))"
                    
                    if let dataDict = filterArray.first as? NSDictionary {
                        
                        if let name = dataDict["product_name"]{
                            headerView.nameLabel.text = name as? String
                        }
                        
                        if let name = dataDict["gtin"]{
                            headerView.gtinLabel.text = name as? String
                        }
                        
                        if let name = dataDict["identifier_value"]{
                            headerView.ndcLabel.text = name as? String
                        }
                    }
                }
            }
        }
        
        headerView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        headerView.lotQuantityView.layer.cornerRadius = 10
        headerView.lotQuantityView.clipsToBounds = true
        headerView.lotQuantityView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LotBasedFooterView") as! LotBasedFooterView
        footerView.bgView.backgroundColor = UIColor.white
        footerView.bgView.layer.cornerRadius = 10
        footerView.bgView.clipsToBounds = true
        footerView.bgView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return footerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return uniqueProductsArray?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let uuid = uniqueProductsArray?[section] as? String {
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                let uniqueLotArr = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>
                
                return uniqueLotArr?.count ?? 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LotProductListCell") as! LotProductListCell
        
        cell.dataView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 0)
        
        
        if let uuid = uniqueProductsArray?[indexPath.section] as? String {
            let allList = itemsList as NSArray?
            let predicate = NSPredicate(format:"product_uuid ='\(uuid)'")
            if let filterArray = allList?.filtered(using: predicate){
                if filterArray.count > 0 {
                    let uniqueLotArr = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>
                    if uniqueLotArr?.count ?? 0 > 0 {
                        let lotPredicate = NSPredicate(format:"lot_no='\(uniqueLotArr?[indexPath.row] ?? "")'")
                        let arr = filterArray as NSArray?
                        if let lotFilterArray = arr?.filtered(using: lotPredicate) {
                            
                            if let dataDict = lotFilterArray.first as? NSDictionary {
                                var dataStr:String = ""
                                
                                if let txt = dataDict["lot_no"] as? String{
                                    dataStr = txt
                                }
                                cell.lotNoLabel.text = dataStr
                                
                                if let txt = dataDict["location_uuid"] as? String,!txt.isEmpty{
                                    cell.storageView.isHidden = true
                                }else{
                                    cell.storageView.isHidden = false
                                }
                                
                                
                                dataStr = ""
                                if let quantity = (lotFilterArray as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                                    dataStr = "\(quantity.intValue)"
                                }
                                
                                cell.lotQuantityButton.setTitle(dataStr, for: .normal)
                                
                                
                                if uniqueLotArr!.count == Int(indexPath.row + 1) {
                                    cell.dataView.layer.cornerRadius = 10
                                    cell.dataView.clipsToBounds = true
                                    cell.dataView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                                    
                                }else{
                                    cell.dataView.layer.cornerRadius = 0
                                    cell.dataView.clipsToBounds = true
                                }
                                
                                cell.lotQuantityButton.tag = allList?.index(of: dataDict) ?? 0
                                cell.crossButton.tag = allList?.index(of: dataDict) ?? 0
                                cell.storageButton.tag = allList?.index(of: dataDict) ?? 0
                                
                            }
                        }
                    }
                }
            }
        }
        
        cell.lotQuantityButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious:cell.lotQuantityButton.frame.size.height / 2.0)
        
        return cell
        
    }
    //MARK: - End
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - End
    
    //MARK: - AdjustmentAddLotBasedDelegate
    func didProductAdded() {
        setupList()
    }
    //MARK: - End
    //MARK: - DPProductLotStorageDelegate
    func didSelectStorage(data: NSDictionary, productLot: String, product_uuid: String) {
        
        var location = ""
        var storage = ""
        var shelf = ""
        var quantity = ""
        
        if let txt = data["location_uuid"] as? String, !txt.isEmpty {
            location = txt
        }
               
       if let txt = data["storage_area_uuid"] as? String, !txt.isEmpty {
           storage = txt
       }
       
       if let txt = data["storage_shelf_uuid"] as? String, !txt.isEmpty {
           shelf = txt
       }
        
        if let txt = data["quantity"] as? String, !txt.isEmpty {
            quantity = txt
        }
        
    
        do{
            let predicate = NSPredicate(format:"product_uuid='\(product_uuid)' and lot_no = '\(productLot)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                for obj in serial_obj {
                    obj.location_uuid = location
                    obj.storage_uuid = storage
                    obj.shelf_uuid = shelf
                    obj.quantity = 0
                    obj.lot_max_quantity = Int16(Float(quantity) ?? 0)
                    PersistenceService.saveContext()
                }
               
                let first_obj = serial_obj.first!
                first_obj.quantity = Int16(Float(quantity) ?? 0)
                
                
//                let quantityInt = (quantity as NSString).integerValue
//                if (quantityInt) < first_obj.quantity {
////                    Utility.showPopup(Title: Warning, Message: "Storage not have sufficient quantity of the scaned product", InViewC: self)
//                    first_obj.quantity = Int16(Float(quantity) ?? 0)
//                }
                
           }
            
            setupList()
        }catch let error{
            print(error.localizedDescription)
        }
    }
    //MARK: - End
}
