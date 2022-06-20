//
//  PPShipmentItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 11/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PPShipmentItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    var itemsList:Array<Any>?
    var shipmentId:String?
    var type = ""
    

    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PPItemSerialsView") as! PPItemSerialsViewController
        controller.shipmentId = shipmentId!
        controller.type = type
        
    if let dataDict = itemsList?[sender.tag] as? [String:Any] {
        if type.capitalized != "Inbound"{
            if let product = dataDict["product"] as? [String:Any]{
                if let uuid = product["uuid"]  as? String{
                    controller.product_uuid = uuid
                }
            }
            }else{
                if let uuid = dataDict["uuid"] as? String{
                    controller.product_uuid = uuid
                }
            }
        }
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    @IBAction func viewLotListButtonPressed(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LotListView") as! LotListViewController
        if type.capitalized == "Inbound"{
            let dict = itemsList![sender.tag] as! NSDictionary
            controller.lotArr = dict["lots"] as! NSArray
        }else{
            let dict = itemsList![sender.tag] as! NSDictionary
            let details = dict["details"] as! NSArray
            let lotdetails = details.firstObject as! NSDictionary
            let lotdetailsArr = lotdetails["lots"] as! NSArray
            controller.lotArr = lotdetailsArr

        }
        controller.type = type
        self.navigationController?.pushViewController(controller, animated: false)
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
        
        if type.capitalized != "Inbound" {
        
        if let product = dataDict["product"] as? [String:Any]{
            
            if let name = product["name"]  as? String{
                dataStr = name
            }
            
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let uuid = product["uuid"]  as? String{
                dataStr = uuid
            }
            
            cell.udidValueLabel.text = dataStr
            
            if let sku = product["sku"]  as? String{
                dataStr = sku
            }
            cell.skuValueLabel.text = dataStr

            if let quantity = dataDict["quantity"]  as? Int{
                dataStr = "\(quantity)"
            }
            
            cell.quantityLabel.text = dataStr
            
            dataStr = ""
            let product_identifierarr = product["product_identifiers"] as! NSArray
            if product_identifierarr.count>0 {
                let product_identifierDict = product_identifierarr.firstObject  as! NSDictionary
                if let ndc = product_identifierDict["value"]  as? String{
                    dataStr = ndc
                   }
                    cell.ndcValueLabel.text = dataStr
                }
          }
        }else{
            if let name = dataDict["name"]  as? String{
                dataStr = name
            }
            
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let uuid = dataDict["uuid"]  as? String{
                dataStr = uuid
            }
            
            cell.udidValueLabel.text = dataStr
        
            dataStr = ""
            
            if let quantity = dataDict["quantity"]  as? Int{
                dataStr = "\(quantity)"
            }
            
            cell.quantityLabel.text = dataStr
        
        
        
            dataStr = ""
            if let ndc = dataDict["ndc"]  as? String{
                dataStr = ndc
            }
            
            cell.ndcValueLabel.text = dataStr
        
            dataStr = ""
            
            if let sku = dataDict["sku"]  as? String{
                dataStr = sku
                }
                cell.skuValueLabel.text = dataStr

            }
            if let is_having_serial = dataDict["is_having_serial"] as? Bool{
                cell.viewSerialButton.isHidden = !is_having_serial
            }else{
                cell.viewSerialButton.isHidden = true
            }
            
        
        cell.viewSerialButton.tag = indexPath.section
        cell.lotDetails.tag =  indexPath.section
        
        return cell
        
    }
    //MARK: - End
    

    
}
