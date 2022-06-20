//
//  MISPurchaseOrderItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 17/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISPurchaseOrderItemsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    var itemsList:Array<Any>?
    

    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    //MARK: - End
    
    //MARK: - IBAction
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MISPurchaseItemsTableViewCell") as! MISPurchaseItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        let dataDict:NSDictionary = itemsList?[indexPath.section] as! NSDictionary
        
        var dataStr:String = ""
        
        if let product = dataDict["product"] as? [String:Any]{
            
            dataStr = ""
            if let descriptions = product["descriptions"] as? [[String:Any]], let description = descriptions.first { 
                if let name = description["name"]  as? String{
                    dataStr = name
                }
            }
            cell.productNameLabel.text = dataStr
            
            dataStr = ""
            if let uuid = product["uuid"]  as? String{
                dataStr = uuid
            }
            cell.productUuidLabel.text = dataStr
            
            
            dataStr = ""
            if let ndc = product["gtin14"]  as? String{
                dataStr = ndc
            }
            cell.gtinLabel.text = dataStr
            
            dataStr = ""
            if let sku = product["sku"]  as? String{
                dataStr = sku
            }
            cell.skuLabel.text = dataStr
            
        }
        
        let formater = NumberFormatter()
        formater.locale = Locale(identifier: "en_US")
        
        var dataquantity = 0
        if let quantity = dataDict["quantity"] {
            if let quantitystr = quantity as? String {
                if let quantityint = formater.number(from: quantitystr)?.intValue , quantityint > 0{
                    dataquantity = quantityint
                }
            }
        }        
        cell.quantityLabel.text = "\(dataquantity)"
        
        
        
        return cell
        
    }
    //MARK: - End
    

    
}


//MARK: - Tableview Cell
class MISPurchaseItemsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var productUuidLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End
