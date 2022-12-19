//
//  MWPickingViewItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 02/11/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm3

import UIKit

class MWPickingViewItemsViewController: BaseViewController {
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var soNumberButton: UIButton!
    @IBOutlet weak var viewItemsTableView: UITableView!
    
    var erpUUID = ""
    var erpName = ""
    var soNumber = ""
    var soUniqueID = ""
    
    var itemsListArray : [MWPickingViewItemsModel] = []
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        mainView.layer.cornerRadius = 10
        soNumberButton.setTitle("SO: \(soNumber)", for: UIControl.State.normal)
        
        soNumberButton.backgroundColor = UIColor.white
        soNumberButton.setTitleColor(Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
        
        headerTitleButton.setTitle("View Items for".localized() + " " + erpName, for: UIControl.State.normal)
        self.listLineItemsBySaleOrderWebServiceCall()
    }
    //MARK: - End
    
    //MARK: - Webservice call
    func listLineItemsBySaleOrderWebServiceCall() {
        /*
         List Line Items By Sale Order
         05e1919a-20a5-4acc-b7e8-9caf1f8ba799
         https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/list-line-items-by-sale-order
         
        POST
         {
                 "action_uuid": "05e1919a-20a5-4acc-b7e8-9caf1f8ba799",
                 "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43",
                 "source_erp": "f6cd53e9-ebc6-4aad-820d-117c52cec266",
                 "so_id": "20"
         }
        */
                
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"listLineItemsBySaleOrder")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["source_erp"] = erpUUID
        
        //,,,sbm5
        /*
        if self.erpName == "odoo" {
            requestDict["so_id"] = soUniqueID
        }
        else if self.erpName == "ttrx" {
//            requestDict["so_uuid"] = soUniqueID
            requestDict["so_id"] = soUniqueID
        }
         */
        requestDict["so_id"] = soUniqueID
        //,,,sbm5

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ListLineItemsBySaleOrder", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
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
//                                if self.erpName == "odoo" { //,,,sbm5
                                    for dict in dataArray {
                                        var product_id = ""
                                        if let value = dict["product_id"] as? String {
                                            product_id = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_delivered_quantity = ""
                                        if let value = dict["product_delivered_quantity"] as? String {
                                            product_delivered_quantity = value
                                        }
                                        var product_qty_to_deliver = ""
                                        if let value = dict["product_qty_to_deliver"] as? String {
                                            product_qty_to_deliver = value
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
                                        var transaction_type = ""
                                        if let value = dict["transaction_type"] as? String {
                                            transaction_type = value
                                        }
                                                                                
                                        let mwPickingViewItemsModel = MWPickingViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                soNumber: self.soNumber,
                                                                                soUniqueID: self.soUniqueID,
                                                                                productUniqueID: product_id,
                                                                                productName: product_name,
                                                                                productCode: product_code,
                                                                                productDeliveredQuantity: product_delivered_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToDeliver: product_qty_to_deliver,
                                                                                productTracking: product_tracking,
                                                                                transactionType: transaction_type)
                                        
                                        self.itemsListArray.append(mwPickingViewItemsModel)
                                    }
                                    
                                    //,,,sbm5
                                    /*
                                }
                                else if self.erpName == "ttrx" {
                                    for dict in dataArray {
                                        var product_id = ""
                                        if let value = dict["product_id"] as? String {
                                            product_id = value
                                        }
                                        var product_demand_quantity = ""
                                        if let value = dict["product_demand_quantity"] as? String {
                                            product_demand_quantity = value
                                        }
                                        var product_delivered_quantity = ""
                                        if let value = dict["product_delivered_quantity"] as? String {
                                            product_delivered_quantity = value
                                        }
                                        var product_qty_to_deliver = ""
                                        if let value = dict["product_qty_to_deliver"] as? Int {
                                            product_qty_to_deliver = String(value)
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
                                        var transaction_type = ""
                                        if let value = dict["transaction_type"] as? String {
                                            transaction_type = value
                                        }

                                        let mwPickingViewItemsModel = MWPickingViewItemsModel(erpUUID: self.erpUUID,
                                                                                erpName: self.erpName,
                                                                                soNumber: self.soNumber,
                                                                                soUniqueID: self.soUniqueID,
                                                                                productUniqueID: product_id,
                                                                                productName: product_name,
                                                                                productCode:product_code,
                                                                                productDeliveredQuantity: product_delivered_quantity,
                                                                                productDemandQuantity: product_demand_quantity,
                                                                                productQtyToDeliver: product_qty_to_deliver,
                                                                                productTracking: product_tracking,
                                                                                transactionType: transaction_type)
                                        
                                        self.itemsListArray.append(mwPickingViewItemsModel)
                                    }
                                }*/
                                //,,,sbm5
                                
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
extension MWPickingViewItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MWPickingViewItemsTableCell") as! MWPickingViewItemsTableCell
        
        cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "959596"), cornerRadious: 0)
        
        if let item = itemsListArray[indexPath.section] as MWPickingViewItemsModel? {
            cell.productNameLabel.text = item.productName
            cell.productCodeLabel.text = item.productCode
            cell.productDeliveredQuantityLabel.text = item.productDeliveredQuantity
            cell.productDemandQuantityLabel.text = item.productDemandQuantity
            cell.productQtyToDeliverLabel.text = item.productQtyToDeliver
            cell.productTrackingLabel.text = item.productTracking
        }
                
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       
    }
}
//MARK: - End

//MARK: - Tableview Cell
class MWPickingViewItemsTableCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCodeLabel: UILabel!
    @IBOutlet weak var productDeliveredQuantityLabel: UILabel!
    @IBOutlet weak var productDemandQuantityLabel: UILabel!
    @IBOutlet weak var productQtyToDeliverLabel: UILabel!
    @IBOutlet weak var productTrackingLabel: UILabel!

    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        productNameLabel.text = ""
        productCodeLabel.text = ""
        productDeliveredQuantityLabel.text = ""
        productDemandQuantityLabel.text = ""
        productQtyToDeliverLabel.text = ""
        productTrackingLabel.text = ""
        
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
//MARK: - End

//MARK: - Model
struct MWPickingViewItemsModel {
    var primaryID : Int16!
    var erpUUID : String!
    var erpName : String!
    var soNumber : String!
    var soUniqueID: String!
    
    var productUniqueID : String!
    var productName: String!
    var productCode : String!
    var productDeliveredQuantity: String!
    var productDemandQuantity: String!
    var productQtyToDeliver: String!
    var productTracking: String!
    var transactionType: String!
    var productFlowType: String!
    var isEdited: Bool!
}
//MARK: - End

    
