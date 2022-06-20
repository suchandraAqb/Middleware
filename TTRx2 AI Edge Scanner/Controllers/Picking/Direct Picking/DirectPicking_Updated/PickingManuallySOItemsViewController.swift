//
//  PickingManuallySOItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol PickingManuallySOItemsViewDelegate:class{
    func reloadItems()
}
class PickingManuallySOItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var filterButton:UIButton!
    var itemsList:Array<Any>?
    var tempuniqueitemsList:[Any]?

    var isFromViewItems =  false
    var searchDict = NSMutableDictionary()
    weak var delegate:PickingManuallySOItemsViewDelegate?

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.getShipmentItemDetails()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.reloadItems()
    }
    //MARK: - End

    
    //MARK: - IBAction
    @IBAction func pickItemButtonPressed(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPPickingItemsView") as! DPPickingItemsViewController
        controller.pickItemDetails = itemsList?[sender.tag] as! NSDictionary
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    @IBAction func filterButtonpressed(_ sender:UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PickingFilterItemsView") as! PickingFilterItemsViewController
            if filterButton.isSelected {
                controller.searchDict = searchDict
            }
            controller.delegate = self
            controller.fromItemsPickedSection = true
       self.navigationController?.pushViewController(controller, animated: false)
    }
    //MARK: - End
    //MARK: - Private Method
    func getProductQuantity(product_uuid:String)->Int{
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and product_uuid='\(product_uuid)'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                
                if let quantity = (arr as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                   return quantity.intValue
                }
                
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        
        return 0
    }
    //MARK: - End
    //MARK: - IBAction

    //MARK: - End
    //MARK: - Api call
    
    func getShipmentItemDetails(){
        let shipmentId = defaults.object(forKey: "outboundShipemntuuid")
        let appendStr = "to_pick/\(shipmentId ?? "")?is_open_picking_session=false"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                  
                        if let items = responseDict["items_to_pick"] as? Array<Any> {
                            Utility.saveObjectTodefaults(key: "items_to_pick", dataObject: items)
                            if let items = Utility.getObjectFromDefauls(key: "items_to_pick") as? [Any]{
                                self.tempuniqueitemsList = items
                                self.itemsList = items
                                
                                if self.filterButton.isSelected {
                                    self.searchFilterData(productUuid: self.searchDict["product_uuid"] as! String, productName: self.searchDict["product_name"] as! String, lot: self.searchDict["lot"] as! String, serial: self.searchDict["serial"] as! String, ndc: self.searchDict["NDC"] as! String, dateStr: self.searchDict["expirationDate"] as! String)
                                }
                                self.listTable.reloadData()
                            }
                        }
                    }
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                       Utility.showAlertWithPopAction(Title: App_Title, Message: message, InViewC: self, isPop: true, isPopToRoot: false)
                   }
                       
                       
                }
                  
            }
        }
        
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
        return itemsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.pickItemsButton.setRoundCorner(cornerRadious: cell.pickItemsButton.frame.height/2)
        
        let dataDict:NSDictionary = itemsList?[indexPath.section] as! NSDictionary
            
        
        if isFromViewItems {
            cell.qtyView.isHidden = true
            cell.productUuidView.isHidden = false
            cell.expirationView.isHidden = true
        }else{
            cell.qtyView.isHidden = false
            cell.productUuidView.isHidden = true
            cell.expirationView.isHidden = false
        }
        
        var dataStr:String = ""
        
        if let name = dataDict["product_name"]  as? String{
            dataStr = name
        }
        
        
        cell.productNameLabel.text = dataStr
        
        var product_uuid = ""
        dataStr = ""
        if let uuid = dataDict["product_uuid"]  as? String{
            dataStr = uuid
            product_uuid = dataStr
        }
        
        cell.udidValueLabel.text = dataStr
        
        if let storageAreaName = dataDict["storage_area_name"]  as? String{
            cell.storageArealLabel.text = storageAreaName
        }
        if let shelfAreaName = dataDict["shelf_area_name"]  as? String{
            cell.shelfLabel.text = shelfAreaName
        }
        
        dataStr = ""
        if let quantity = dataDict["quantity_to_pick"]  as? NSString{
            dataStr = "\(quantity.intValue)"
        }else if let quantity = dataDict["total_quantity"]  as? Int{
            dataStr = "\(quantity)"
        }
        
        if isFromViewItems{
           cell.quantityLabel.text = dataStr
        }else{
            cell.quantityLabel.text = ""
            cell.qtyToPickedLabel.text = dataStr
            
            var qty = "0"
            
            if !product_uuid.isEmpty{
                qty = "\(getProductQuantity(product_uuid: product_uuid))"
            }
            
            cell.qtyPickedLabel.text = qty
            
            
        }
        
       
        dataStr = ""
        if let ndc = dataDict["product_upc"]  as? String{
            dataStr = ndc
        }else if let ndc = dataDict["upc"]  as? String{
            dataStr = ndc
        }
        
        cell.upcValueLabel.text = dataStr
        
        dataStr = ""
        
        if let sku = dataDict["product_sku"]  as? String{
            dataStr = sku
        }else if let ndc = dataDict["sku"]  as? String{
            dataStr = ndc
        }
        
        cell.skuValueLabel.text = dataStr
        
        
        dataStr = ""
        
        if let lot = dataDict["lot_number"]  as? String{
            dataStr = lot
        }else if let lot = dataDict["lot"]  as? String{
            dataStr = lot
        }
        
        cell.lotValueLabel.text = dataStr
        
        dataStr = ""
        if let expirationDate = dataDict["expiration_date"] as? String{
            dataStr = expirationDate
        }
        cell.expirationDateLabel.text = dataStr
        
        if let identifiers = dataDict["product_identifiers"]  as? [[String:Any]],!identifiers.isEmpty{
            
            if let firstObj = identifiers.first,!firstObj.isEmpty {
                if let type = firstObj["identifier_code"] as? String,!type.isEmpty{
                    cell.ndcLabel.text = type
                }
                
                if let value = firstObj["value"] as? String,!value.isEmpty{
                    cell.ndcValueLabel.text = value
                }
            }
        }else if let identifiers = dataDict["identifiers"]  as? [[String:Any]],!identifiers.isEmpty{
            
            if let firstObj = identifiers.first,!firstObj.isEmpty {
                if let type = firstObj["type"] as? String,!type.isEmpty{
                    cell.ndcLabel.text = type
                }
                
                if let value = firstObj["value"] as? String,!value.isEmpty{
                    cell.ndcValueLabel.text = value
                }
            }
        }
        cell.pickItemsButton.tag = indexPath.section
        return cell
        
    }
    //MARK: - End
    

    
}
extension PickingManuallySOItemsViewController : PickingFilterItemsViewDelegate{
    func searchFilterData(productUuid: String, productName: String, lot: String, serial: String, ndc: String, dateStr: String) {
        if let items = Utility.getObjectFromDefauls(key: "items_to_pick"){
            itemsList = items as? Array<Any>
            
            if itemsList!.count > 0 {

            searchDict.setValue(productUuid, forKey: "product_uuid")
            searchDict.setValue(productName, forKey: "product_name")
            searchDict.setValue(serial, forKey: "serial")
            searchDict.setValue(lot, forKey: "lot")
            searchDict.setValue(ndc, forKey: "NDC")
            searchDict.setValue(dateStr, forKey: "expirationDate")

            
            filterButton.isSelected = true
            
            if !productUuid.isEmpty{
                let predicate = NSPredicate(format: "product_uuid = '\(productUuid)'")
                itemsList = (itemsList! as NSArray).filtered(using: predicate)
            }
            if !productName.isEmpty{
                let predicate = NSPredicate(format: "product_name CONTAINS[c] '\(productName)'")
                itemsList = (itemsList! as NSArray).filtered(using: predicate)
            }
            if !lot.isEmpty{
                let predicate = NSPredicate(format: "lot_number = '\(lot)'")
                itemsList = (itemsList! as NSArray).filtered(using: predicate)
            }
                
            if !ndc.isEmpty{
                let ndcmainArr = NSMutableArray()
                let uniqueArr = itemsList! as NSArray

                for item in uniqueArr {
                    let itemdict = item as? NSDictionary
                    let arr = itemdict?["product_identifiers"] as? NSArray
                    if let ndcDict = arr?.firstObject as? NSDictionary{
                        var ndcStr = ndcDict["value"] as? String
                                ndcStr = ndcStr?.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                        let ndcSerach = ndc.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                                if ndcStr == ndcSerach {
                                    ndcmainArr.add(item)
                              }
                           }
                     }
                    itemsList = ndcmainArr.mutableCopy() as? [Any]
                 }
                if !dateStr.isEmpty && (dateStr != "Expiration Date"){
                    let predicate = NSPredicate(format: "expiration_date = '\(dateStr)'")
                    itemsList = (itemsList! as NSArray).filtered(using: predicate)
                }
             }
          
            tempuniqueitemsList = itemsList
            listTable.reloadData()
        }
    
    }
    func clearAll(){
        searchDict = NSMutableDictionary()
        filterButton.isSelected = false
        self.getShipmentItemDetails()
    }
}
extension PickingManuallySOItemsViewController:DPPickingItemsDelegate{
    func refreshItemsList() {
        self.getShipmentItemDetails()
    }
}
