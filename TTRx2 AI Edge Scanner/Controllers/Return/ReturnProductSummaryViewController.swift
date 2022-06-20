//
//  ReturnProductSummaryViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnProductSummaryViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var listTable: UITableView!
    var itemsList:[Any]?
    var uniqueitemsList:[Any]?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        fetchValidProducts()
    }
    //MARK: - End
    //MARK: - Private Method
    func fetchValidProducts(){
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            
            do{
                
                let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchValidSerialRequest(uuid: txt,isDistinct:true ))
                
                //print(return_obj as NSArray)
                if !return_obj.isEmpty{
                    
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: return_obj)
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
                
            }catch let error {
                print(error.localizedDescription)
                
            }
            
        }
    }
    
    
    func getProductConditionCount(return_uuid:String,product_uuid:String,condition:String)->Int{
        var count = 0
        
        do{
            let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithConditionRequest(return_uuid: return_uuid, product_uuid:product_uuid, condition:condition))
            
            if !return_obj.isEmpty{
                
                count = return_obj.count
            }
            
        }catch let error {
            print(error.localizedDescription)
            
        }
        
        return count
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
        //return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductSummaryCell") as! ProductSummaryCell
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
        if !filterArray.isEmpty && filterArray.count>0 {
            dataDict = filterArray.first as? NSDictionary
        }
        
        
        
        var dataStr = ""
        
        if let name = dataDict?["product_name"]  as? String{
            dataStr = name
        }
        
        cell.productNameLabel.text = dataStr
        dataStr = ""
        
        if let gtin = dataDict?["gtin"]  as? String{
            dataStr = gtin
        }
        
        cell.gtinLabel.text = dataStr
        
        
        var resalable = 0
        var quarantine = 0
        var destruct = 0
        
        if let uuid = defaults.object(forKey: "current_returnuuid") as? String{
            
            resalable = getProductConditionCount(return_uuid: uuid, product_uuid: product_uuid, condition: Return_Serials.Condition.Resalable.rawValue)
            
            quarantine = getProductConditionCount(return_uuid: uuid, product_uuid: product_uuid, condition: Return_Serials.Condition.Quarantine.rawValue)
            
            destruct = getProductConditionCount(return_uuid: uuid, product_uuid: product_uuid, condition: Return_Serials.Condition.Destruct.rawValue)
            
        }
        
        cell.toReturnedLabel.text = "\(resalable+quarantine+destruct)"
        cell.resalableCountLabel.text = "\(resalable)"
        cell.quarantineCountLabel.text = "\(quarantine)"
        cell.notResalableCountLabel.text = "\(destruct)"
        
        
        return cell
        
    }
    //MARK: - End
}

class ProductSummaryCell: UITableViewCell
{
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var toReturnedLabel: UILabel!
    @IBOutlet weak var resalableCountLabel: UILabel!
    @IBOutlet weak var quarantineCountLabel: UILabel!
    @IBOutlet weak var notResalableCountLabel: UILabel!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
