//
//  AdjustmentViewItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class AdjustmentViewItemsViewController:  BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var itemsButton: UIButton!
    var itemsList:Array<Any>?
    var uniqueitemsList:[Any]?
    var isFromContainer = false
    @IBOutlet weak var viewExistingItems: UIButton!
    @IBOutlet weak var viewExistingItemsView: UIView!
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        viewExistingItems.setRoundCorner(cornerRadious: viewExistingItems.frame.size.height/2.0)
        if isFromContainer{
            viewExistingItemsView.isHidden = false
        }else{
            viewExistingItemsView.isHidden = true
        }
        fetchScannedSerials()
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func viewSerialButtonPressed(_ sender: UIButton) {
        
        var product_uuid = ""
        if let uuid = uniqueitemsList?[sender.tag]  as? String{
            product_uuid = uuid
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentItemsLotView") as! AdjustmentItemsLotViewController
        controller.productId = product_uuid
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
    
    @IBAction func viewExistingItemsButtonPressed(_ sender: UIButton) {
        if let dataDict = Utility.getDictFromdefaults(key: "container_edit_details") {
           if let txt = dataDict["serial"] as? String,!txt.isEmpty{
                let storyboard = UIStoryboard(name: "Inventory", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "ItemsListViewController") as! ItemsListViewController
                controller.serialNumber = txt
                self.navigationController?.pushViewController(controller, animated: true)
           }
        }
    }
    //MARK: - End
    //MARK: - Private Method
    func fetchScannedSerials(){
        
        do{
            let predicate = NSPredicate(format:"is_valid=true")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let unique =  (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? Array<Any>{
                    itemsList = arr
                    uniqueitemsList = unique
                    //print(itemsList as Any)
                }else{
                    itemsList = []
                    uniqueitemsList = []
                }
            }else{
                itemsList = []
                uniqueitemsList = []
            }
            listTable.reloadData()
        }catch let error{
            print(error.localizedDescription)
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
        return uniqueitemsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var product_uuid = ""
        if let uuid = uniqueitemsList?[indexPath.section]  as? String{
            product_uuid = uuid
        }
        
        let predicate = NSPredicate(format:"product_uuid='\(product_uuid)'")
        let arr = itemsList! as NSArray
        let filterArray = arr.filtered(using: predicate)
        
        
        var dataDict:NSDictionary?
        
        var quantity = ""
        if !filterArray.isEmpty && filterArray.count>0 {
            dataDict = filterArray.first as? NSDictionary
            if let qty = (filterArray as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                quantity = "\(qty.intValue)"
            }
        }
        
        var dataStr:String = "Container".localized()
        
        if let name = dataDict?["product_name"]  as? String , !name.isEmpty{
            dataStr = name
            cell.viewSerialButton.isHidden = false
        }else{
            cell.viewSerialButton.isHidden = true
        }
        
        
        cell.productNameLabel.text = dataStr
        
        dataStr = ""
        
        cell.quantityLabel.text = quantity
        
        dataStr = ""
        if let uuid = dataDict?["product_uuid"]  as? String{
            dataStr = uuid
        }
        
        cell.udidValueLabel.text = dataStr
        
        dataStr = ""
        if let ndc = dataDict?["identifier_value"]as? String{
            dataStr = ndc
        }
        
        cell.ndcValueLabel.text = dataStr
        
        dataStr = ""
        
        if let gtin14 = dataDict?["gtin"]  as? String{
            dataStr = gtin14
        }
        
        cell.skuValueLabel.text = dataStr
        
        cell.viewSerialButton.tag = indexPath.section
        
        
        return cell
        
    }
    //MARK: - End
    
    
}

