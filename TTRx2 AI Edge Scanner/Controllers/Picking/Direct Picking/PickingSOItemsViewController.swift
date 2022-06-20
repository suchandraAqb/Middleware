//
//  PickingSOItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingSOItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    var itemsList:Array<Any>?
    var shipmentId:String?
    var isFromViewItems =  false

    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        if isFromViewItems{
            getShipmentItemDetails()
        }else{
            shipmentId = defaults.object(forKey: "outboundShipemntuuid") as? String
            getShipmentItemDetails()

//            if let items = Utility.getObjectFromDefauls(key: "items_to_pick") as? [Any]{
//                itemsList = items
//                listTable.reloadData()
//            }
        }
        
    }
    //MARK: - End
    //MARK: - API Call
    func getShipmentItemDetails(){
     
        let appendStr = "to_pick/\(shipmentId ?? "")?is_open_picking_session=false"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                        
//                        if let items = responseDict["items_to_pick"] as? Array<Any> {
//                            self.itemsList = items
//                            self.listTable.reloadData()
//                        }
                        if let picking_data = responseDict["picking_data"] as? [String:Any]{
                            if let items = picking_data["items"] as? Array<Any> {
                                self.itemsList = items
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
    
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        
        let dataDict:NSDictionary = itemsList?[sender.tag] as! NSDictionary
        
        if let uuid = dataDict["uuid"] as? String{
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialsView") as! SerialsViewController
            controller.shipmentId = shipmentId
            controller.itemUuid = uuid
            self.navigationController?.pushViewController(controller, animated: false)
                   
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
        
        let dataDict:NSDictionary = itemsList?[indexPath.section] as! NSDictionary
            
        if isFromViewItems {
            cell.qtyView.isHidden = true
            cell.productUuidView.isHidden = false
            cell.expirationView.isHidden = true
        }else{
            cell.qtyView.isHidden = false
            cell.productUuidView.isHidden = true
            cell.expirationView.isHidden = true
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
        
        cell.udidValueLabel.text = product_uuid
        
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
            
            var dataStr = ""
            if let quantity = dataDict["total_quantity"] as? Int{
                dataStr = "\(quantity)"
            }
            cell.qtyToPickedLabel.text = dataStr
            
            dataStr = ""
            if let quantity = dataDict["qty_picked"] as? Int{
                dataStr = "\(quantity)"
            }
            cell.qtyPickedLabel.text = dataStr

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
        
        return cell
        
    }
    //MARK: - End
    

    
}
