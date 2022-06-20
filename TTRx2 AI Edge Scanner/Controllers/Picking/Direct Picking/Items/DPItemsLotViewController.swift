//
//  DPItemsLotViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 03/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class DPItemsLotViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    var quantityList:Array<Any>?
    var lotListDict:NSDictionary?
    var uniqueitemsList:[Any]?
    var productId:String!
    
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        fetchProductLots()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func fetchProductLots(){
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and product_uuid='\(productId ?? "")'")
            let serial_obj = try PersistenceService.context.fetch(DirectPicking.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let unique =  (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_no") as? Array<Any>{
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
        return uniqueitemsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var lot_no = ""
        if let lot = uniqueitemsList?[indexPath.section]  as? String{
            lot_no = lot
        }
        
        let predicate = NSPredicate(format:"lot_no='\(lot_no)'")
        let arr = itemsList! as NSArray
        let filterArray = arr.filtered(using: predicate)
        
        
        
        var quantity = ""
        var dataDict:NSDictionary?
        if !filterArray.isEmpty && filterArray.count>0 {
            dataDict = filterArray.first as? NSDictionary
            if let qty = (filterArray as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                quantity = "\(qty.intValue)"
            }
        }
        
        var dataStr:String = ""
        
        if let name = dataDict?["lot_no"]  as? String{
            dataStr = name
        }
        
        
        cell.productNameLabel.text = dataStr
        
        cell.expirationDateLabel.text = ""
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        if let exDate = dataDict?["expiration_date"]  as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                cell.expirationDateLabel.text = formattedDate
            }
        }
        
        
        cell.quantityLabel.text = quantity
        return cell
        
    }
    
    
    
    //MARK: - End
    
    
    
}

