//
//  PickingItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 29/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingItemsViewController:  BaseViewController,UITableViewDataSource, UITableViewDelegate {

   @IBOutlet weak var listTable: UITableView!
   @IBOutlet weak var itemsButton: UIButton!
   var itemsList:Array<Any>?
   
   

   //MARK: - Update Status Bar Style
   override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
   }
   //MARK: - End

   //MARK: - View Life Cycle
   override func viewDidLoad() {
       super.viewDidLoad()
       sectionView.roundTopCorners(cornerRadious: 40)
        getPickingItemsList()
   }
   //MARK: - End
   
   //MARK: - IBAction
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        
        let dataDict:NSDictionary = itemsList?[sender.tag] as! NSDictionary
        
        if let uuid = dataDict["product_uuid"] as? String{
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemLotsView") as! ItemLotsViewController
            controller.productId = uuid
            controller.expDate = dataDict["expiration_date"] as? String ?? ""
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
        
        
    }
    //MARK: - End
    //MARK: - Private Method
    func getPickingItemsList(){
        var requestDict = [String:Any]()
        requestDict["type"] = "sales_order_by_picking"
        requestDict["session_uuid"] = defaults.value(forKey: "picking_session_id") ?? ""
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetPickingItems", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "",isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        
                        if let dataArray = responseDict["sales_order_content"] as? Array<Any> {
                            self.itemsList = dataArray
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
       
       var dataStr:String = ""
       
       if let name = dataDict["product_name"]  as? String{
           dataStr = name
       }
       
       
       cell.productNameLabel.text = dataStr
       
       dataStr = ""
       
       if let quantity = dataDict["quantity"] {//as? Int
           dataStr = "\(quantity)"
       }
       
       cell.quantityLabel.text = dataStr
       
       dataStr = ""
       if let uuid = dataDict["product_uuid"]  as? String{
           dataStr = uuid
       }
       
       cell.udidValueLabel.text = dataStr
       
       dataStr = ""
       if let ndc = dataDict["ndc"] as? String{
           dataStr = ndc
       }
       
       cell.ndcValueLabel.text = dataStr
       
       dataStr = ""
       
       if let gtin14 = dataDict["gtin14"]  as? String{
           dataStr = gtin14
       }
       
       cell.skuValueLabel.text = dataStr
       
       cell.viewSerialButton.tag = indexPath.section
       
       
       return cell
       
   }
   //MARK: - End
       

}
