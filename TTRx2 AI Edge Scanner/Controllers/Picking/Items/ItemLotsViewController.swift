//
//  ItemLotsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 29/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ItemLotsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    var quantityList:Array<Any>?
    var lotListDict:NSDictionary?
    var productId:String!
    var expDate: String?
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        getItemsLotList()
        
    }
    //MARK: - End
    
    //MARK: - Private Method
     func getItemsLotList(){
         var requestDict = [String:Any]()
         requestDict["type"] = "sales_order_by_picking"
         requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
         requestDict["product_uuid"] = productId
         
         self.showSpinner(onView: self.view)
           Utility.GETServiceCall(type: "GetPickingItems", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "lot_breakdown",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
               DispatchQueue.main.async{
                   self.removeSpinner()
                   if isDone! {
                     
                         let responseDict: NSDictionary = responseData as! NSDictionary
                         
                         if let dataDict = responseDict["lot_breakdown"] as? NSDictionary {
                            self.lotListDict = dataDict
                            self.itemsList = dataDict.allKeys
                            self.quantityList = dataDict.allValues
                            self.listTable.reloadData()
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
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
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
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        
        if let lot = itemsList?[indexPath.section] as? String {
            cell.productNameLabel.text = lot
        }
        
        if let quantity = quantityList?[indexPath.section] as? Int {
            cell.quantityLabel.text = "\(quantity)"
        }
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        if let exDate = expDate{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                cell.expirationDateLabel.text = formattedDate
            }
        }
        return cell
        
    }
    
   
    
    //MARK: - End

    

}
