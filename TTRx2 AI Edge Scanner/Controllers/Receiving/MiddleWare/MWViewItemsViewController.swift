//
//  MWViewItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 28/07/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

class MWViewItemsViewController: BaseViewController {
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var poNumberButton: UIButton!
    @IBOutlet weak var viewItemsTableView: UITableView!
    
    var erpUUID = ""
    var erpName = ""
    var poNumber = ""
    var poUniqueID = ""
    
    var itemsListArray : [MWViewItemsModel] = []
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        mainView.layer.cornerRadius = 10
        poNumberButton.setTitle("PO: \(poNumber)", for: UIControl.State.normal)
        
//        poNumberButton.layer.cornerRadius = poNumberButton.frame.height/4
        poNumberButton.backgroundColor = UIColor.white
        poNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
//        poNumberButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "276A44"), cornerRadious: poNumberButton.frame.height/4)
        
        
        headerTitleButton.setTitle("View Items for".localized() + " " + erpName, for: UIControl.State.normal)
        self.listLineItemsByPurchaseOrderWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Webservice call
    func listLineItemsByPurchaseOrderWebServiceCall() {
        /*
         List Line Items By Purchase Order
         4032b2bb-3b29-4fe1-b384-4a76b30101eb
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-line-items-by-purchase-order
         
        POST
         {
                 "action_uuid": "4032b2bb-3b29-4fe1-b384-4a76b30101eb",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "po_id": "184"
         }
        */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsByPurchaseOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = erpUUID
        
        if self.erpName == "odoo" {
            requestDict["po_id"] = poUniqueID
        }
        else if self.erpName == "ttrx" {
            requestDict["po_uuid"] = poUniqueID
        }

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListLineItemsByPurchaseOrder", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict: NSDictionary = responseData as? NSDictionary {
                        let statusCode = responseDict["status_code"] as? Bool
                        if statusCode! {
                            let dataArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if dataArr.count > 0 {
                                let dataArray = dataArr as! [[String:Any]]
                                //                                                print("dataArray....>>>>>",dataArray)
                                if self.erpName == "odoo" {
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
                                        
                                        let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                poNumber: self.poNumber,
                                                                                poUniqueID: self.poUniqueID,
                                                                                productUniqueID: product_id,
                                                                                productName: product_name,
                                                                                productCode: product_code,
                                                                                productReceivedQuantity: product_received_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToReceive: product_qty_to_receive,
                                                                                productTracking: product_tracking,
                                                                                lineItemUUID: "",
                                                                                productUomID: product_uom_id)
                                        
                                        self.itemsListArray.append(mwViewItemsModel)
                                    }
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var product_uuid = ""
                                        if let value = dict["product_uuid"] as? String {
                                            product_uuid = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_received_quantity = ""
                                        if let value = dict["product_received_quantity"] as? String {
                                            product_received_quantity = value
                                        }
                                        var product_qty_to_receive = ""
                                        if let value = dict["product_qty_to_receive"] as? Int {
                                            product_qty_to_receive = String(value)
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
                                        
                                        var line_item_uuid = ""
                                        if let value = dict["line_item_uuid"] as? String {
                                            line_item_uuid = value
                                        }

                                        let mwViewItemsModel = MWViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                poNumber: self.poNumber,
                                                                                poUniqueID: self.poUniqueID,
                                                                                productUniqueID: product_uuid,
                                                                                productName: product_name,
                                                                                productCode:product_code,
                                                                                productReceivedQuantity: product_received_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToReceive: product_qty_to_receive,
                                                                                productTracking: product_tracking,
                                                                                lineItemUUID: line_item_uuid,
                                                                                productUomID: "")
                                        
                                        self.itemsListArray.append(mwViewItemsModel)
                                    }
                                }
                                
                                self.viewItemsTableView.reloadData()
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
}

//MARK: - Tableview Delegate and Datasource
extension MWViewItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWViewItemsTableCell") as! MWViewItemsTableCell
        
        cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "959596"), cornerRadious: 0)
        
        if let item = itemsListArray[indexPath.section] as MWViewItemsModel? {
            cell.productNameLabel.text = item.productName
            cell.productCodeLabel.text = item.productCode
            cell.productReceivedQuantityLabel.text = item.productReceivedQuantity
            cell.productDemandQuantityLabel.text = item.productDemandQuantity
            cell.productQtyToReceiveLabel.text = item.productQtyToReceive
            cell.productTrackingLabel.text = item.productTracking
        }
                
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       
    }
}
//MARK: - End

//MARK: - Tableview Cell
class MWViewItemsTableCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCodeLabel: UILabel!
    @IBOutlet weak var productReceivedQuantityLabel: UILabel!
    @IBOutlet weak var productDemandQuantityLabel: UILabel!
    @IBOutlet weak var productQtyToReceiveLabel: UILabel!
    @IBOutlet weak var productTrackingLabel: UILabel!

    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        productNameLabel.text = ""
        productCodeLabel.text = ""
        productReceivedQuantityLabel.text = ""
        productDemandQuantityLabel.text = ""
        productQtyToReceiveLabel.text = ""
        productTrackingLabel.text = ""
        
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End

//MARK: - Model
struct MWViewItemsModel {
    var primaryID : Int16!
    var erpUUID : String!
    var erpName : String!
    var poNumber : String!
    var poUniqueID: String!
    
    var productUniqueID : String!
    var productName: String!
    var productCode : String!
    var productReceivedQuantity: String!
    var productDemandQuantity: String!
    var productQtyToReceive: String!
    var productTracking: String!
    var lineItemUUID: String! //For TTRx
    var productUomID: String! //For odoo
    var productFlowType: String! //For odoo
    var isEdited: Bool!
}
//MARK: - End

    
