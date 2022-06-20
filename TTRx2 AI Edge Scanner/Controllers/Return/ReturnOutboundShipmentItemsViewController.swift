//
//  ReturnOutboundShipmentItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 18/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnOutboundShipmentItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {

     
      @IBOutlet weak var listTable: UITableView!
      @IBOutlet weak var itemsButton: UIButton!
      var itemsList:Array<Any>?
      var shipmentId = ""
      

      //MARK: - Update Status Bar Style
      override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
      }
      //MARK: - End

      //MARK: - View Life Cycle
      override func viewDidLoad() {
          super.viewDidLoad()
          sectionView.roundTopCorners(cornerRadious: 40)
          getShipmentItemDetails()
      }
      //MARK: - End
    
    func getShipmentItemDetails(){
        
        let appendStr = "Outbound/\(shipmentId)/items/"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ConfirmShipment", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseArr = responseData as? Array<Any> {
                        self.itemsList = responseArr
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
      
      
      @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
          
          let dataDict:NSDictionary = itemsList?[sender.tag] as! NSDictionary
          
          if let uuid = dataDict["product_uuid"] as? String{
              
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialsView") as! SerialsViewController
                controller.shipmentId = shipmentId
                controller.itemUuid = uuid
                controller.isOutbound = true
                self.navigationController?.pushViewController(controller, animated: false)
                     
          }
          
         
      }
      
      
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
          
          if let quantity = dataDict["quantity"]  as? Int{
              dataStr = "\(quantity)"
          }
          
          cell.quantityLabel.text = dataStr
          
          dataStr = ""
          if let uuid = dataDict["product_uuid"]  as? String{
              dataStr = uuid
          }
          
          cell.udidValueLabel.text = dataStr
          
          dataStr = ""
          if let ndc = dataDict["ndc"]  as? String{
              dataStr = ndc
          }
          
          cell.ndcValueLabel.text = dataStr
          
          dataStr = ""
          
          if let sku = dataDict["sku"]  as? String{
              dataStr = sku
          }
        
          if let is_having_serial = dataDict["is_having_serial"] as? Bool{
             cell.viewSerialButton.isHidden = !is_having_serial
          }
          
          cell.skuValueLabel.text = dataStr
          
          cell.viewSerialButton.tag = indexPath.section
          
          
          return cell
          
      }
      //MARK: - End
}
