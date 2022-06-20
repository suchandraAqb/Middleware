//
//  FailedItemsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 19/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol FailedItemsViewDelegate: AnyObject{
    @objc optional func failedProductDetails(itemArr : Array<Any>)
}

class FailedItemsViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var listTable:UITableView!
    @IBOutlet weak var itemsButton:UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var filterButton: UIButton!
    var itemList:Array<Any>?
    var itemListShowArray:Array<Any>?
    var isFromGs1BacodeApi:Bool = false
    var indexArr = NSMutableArray()
    weak var delegate : FailedItemsViewDelegate?
    var listArray = NSMutableArray()
    var searchDict = NSMutableDictionary()

    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if itemList!.count > 0 {
            self.createItemDetailsArray()
        }
            //self.deleteButtonShowHide()
            deleteButton.isHidden = true
            self.activeInactiveButton()
        }

    //MARK: -IBAction
    
    @IBAction func deleteButtonPressed(_ sender:UIButton){
        /*
        let msg = "Are you sure you want to delete the failed item details?".localized()
        let alert = UIAlertController(title: "Confirmation", message: msg, preferredStyle: UIAlertController.Style.alert)
        let okaction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            for item in self.indexArr{
                if ((((self.itemList! as NSArray).index(of: item))) != 0) {
//                    let value = item as! Int
                   // let dictToBeRemove = self.itemList?[value] as? NSDictionary
                        self.itemList?.remove(at: item as! Int)
                        self.indexArr.remove(item)
                        self.listArray.removeObject(at: item as! Int)
                    
                    if let item = Utility.getObjectFromDefauls(key: "ScanFailedItemsArray"){
                        self.itemList = item as! Array<Any>?
                    }
                }
            }
            self.activeInactiveButton()
            self.deleteButtonShowHide()
            self.listTable.reloadData()
                      
           // Utility.saveObjectTodefaults(key: "ScanFailedItemsArray", dataObject: self.itemList!)
           // self.delegate?.failedProductDetails!(itemArr: self.itemList!)

        }
        let action = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.indexArr.removeAllObjects()
            self.deleteButton.isHidden = true
            self.listTable.reloadData()
        }
        alert.addAction(okaction)
        alert.addAction(action)
        self.navigationController?.present(alert, animated: true, completion: nil)
                        *///,,,temp sb11
    }
    @IBAction func filterButtonPressed(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FailedItemsFilterView") as! FailedItemsFilterViewController
            controller.delegate = self
        if filterButton.isSelected {
            controller.searchDict = searchDict
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func checkUncheckButtonPressed(_ sender:UIButton){
        if sender.isSelected {
            sender.isSelected = false
            indexArr.remove(sender.tag)
        }else{
            sender.isSelected = true
            indexArr.add(sender.tag)
        }
           self.deleteButtonShowHide()
        
    }
    
    //MARK: - Private function
    
    func deleteButtonShowHide(){
        if indexArr.count > 0 {
            deleteButton.isHidden = false
        }else{
            deleteButton.isHidden = true
        }
    }
    func createItemDetailsArray(){
        listArray = NSMutableArray()
        for itemDetails in itemList!{
            let itemdict = itemDetails as? NSDictionary
            let dict1 = NSMutableDictionary()
        
           
            
            //Serial------
            var str1 = ""
            if let serialNumber = itemdict?["serial"] as? String{
                str1 = serialNumber
            }else if let serialNumber = itemdict?["serial_number"] as? String{
                str1 = serialNumber
            }
            dict1.setValue(str1, forKey: "serial")
            
            //LOT Number-----
            var str2 = ""
            if let lot = itemdict?["lot_number"] as? String{
                str2 = lot
            }else if let lot = itemdict?["lot"] as? String{
                str2 = lot
            }
            dict1.setValue(str2, forKey: "lot")
            
            //Gtin14
            var str3 = ""
            if let gtin14 = itemdict?["gtin14"] as? String{
                str3 = gtin14
            }
            if str3 == ""{
                if let value = itemdict?["gs1_barcode"] as? String, !value.isEmpty {
                    let details = UtilityScanning(with:value).decoded_info
                    if(details.keys.contains("01")){
                        if let gtin14 = details["01"]?["value"] as? String{
                            str3 = gtin14
                        }
                    }
               }
            }
            dict1.setValue(str3, forKey: "gtin14")
            
            //Product_uuid
            
            var str4 = ""
            if let product_uuid = itemdict?["product_uuid"] as? String{
                str4 = product_uuid
            }
            if str4 == "" {
                if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                   let filteredArray = allproducts.filter { $0["gtin14"] as? String == str3 }
                    if filteredArray.count > 0 {
                        let dict = filteredArray.first
                        str4 = dict!["uuid"] as? String ?? ""
                    }
                }
            }
            dict1.setValue(str4, forKey: "product_uuid")

            
            //Product_name
            var str5 = ""
            if let name = itemdict?["product_name"] as? String{
                str5 = name
            }
            if str5 == "" {
                if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                   let filteredArray = allproducts.filter { $0["gtin14"] as? String == str3 }
                    if filteredArray.count > 0 {
                        let dict = filteredArray.first
                        str5 = dict!["name"] as? String ?? ""
                    }
                }
            }
            dict1.setValue(str5, forKey: "product_name")
            
            
            //NDC-----
            var str = ""
            if let ndc = itemdict?["product_ndc"] as? String{
                str = ndc
            }else if let ndc = itemdict?["ndc"] as? String{
                str = ndc
            }
            if str == "" {
                if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                   let filteredArray = allproducts.filter { $0["gtin14"] as? String == str3 }
                    if filteredArray.count > 0 {
                        let dict = filteredArray.first
                        str = dict!["identifier_us_ndc"] as? String ?? ""
                    }
                }
            }
            var ndcValue = str
            ndcValue = ndcValue.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
            dict1.setValue(ndcValue, forKey: "NDC")
            //
            
            var errorStr = ""
            if let failedreason = itemdict?["error_msg"] as? String{
                errorStr = failedreason
            }
            
            if let avalable = itemdict?["is_available_for_sale"] as? Bool{
                if errorStr == "" && !avalable{
                    errorStr = "Insufficient stock in inventory."
                }
            }
            if errorStr.isEmpty {
                if let failedreason = itemdict?["error"] as? String{
                    errorStr = failedreason
                }
            }
            dict1.setValue(errorStr, forKey: "error_msg")
            
            listArray.add(dict1)
        }
        itemListShowArray = listArray as? Array<Any>
        Utility.saveObjectTodefaults(key: "ScanFailedItemsArray", dataObject: itemList!)
        listTable.reloadData()
    }
    func activeInactiveButton(){
        if itemList!.count > 0 {
            //deleteButton.alpha = 1
           // deleteButton.isUserInteractionEnabled = true
            
            filterButton.alpha = 1
            filterButton.isUserInteractionEnabled = true
        }else{
            //deleteButton.alpha = 0.5
            //deleteButton.isUserInteractionEnabled = false
            
            filterButton.alpha = 0.5
            filterButton.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - UItableViewDataSource & UITableviewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemListShowArray?.count ?? 0
   }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        if !itemListShowArray!.isEmpty && itemListShowArray!.count>0 {
        let dict : NSDictionary = itemListShowArray![indexPath.section] as! NSDictionary
        
            var str = ""
            
            if let product_uuid = dict["product_uuid"] as? String{
                str = product_uuid
            }
            cell.udidValueLabel.text = str
            
            
            str = ""
            if let name = dict["product_name"] as? String{
                str = name
            }
            cell.productNameLabel.text = str
            
            str = ""
            if let ndc = dict["NDC"] as? String{
                str = ndc
            }
            cell.ndcValueLabel.text = str
            
            
            str = ""
            if let serialNumber = dict["serial"] as? String{
                str = serialNumber
            }
            cell.serialNumberText.text = str
            
            
            str = ""
            if let failedreason = dict["error_msg"] as? String{
                str = failedreason
            }
            cell.failedReasonText.text = str
            
            str = ""
            if let lot = dict["lot"] as? String{
                str = lot
            }
            cell.lotNumberText.text = str
            
            str = ""
            if let gtin14 = dict["gtin14"] as? String{
                str = gtin14
            }
            cell.skuValueLabel.text = str
 
        }
//        if indexArr.contains(indexPath.section){
//            cell.checkUncheckButton.isSelected = true
//        }else{
//            cell.checkUncheckButton.isSelected = false
//        }
        //cell.checkUncheckButton.tag = indexPath.section
        return cell
    }
   
}
extension FailedItemsViewController : FailedItemsFilterViewDelegate{
    func searchFilterData(productUuid: String, productName: String, lot: String, serial: String, ndc: String, gtin14: String) {
        if itemListShowArray!.count > 0 {
        
            searchDict.setValue(productUuid, forKey: "product_uuid")
            searchDict.setValue(productName, forKey: "product_name")
            searchDict.setValue(serial, forKey: "serial")
            searchDict.setValue(lot, forKey: "lot")
            searchDict.setValue(ndc, forKey: "NDC")
            searchDict.setValue(gtin14, forKey: "gtin14")

            
            filterButton.isSelected = true
            if !productUuid.isEmpty{
                let predicate = NSPredicate(format: "product_uuid = '\(productUuid)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
            if !productName.isEmpty{
                let predicate = NSPredicate(format: "product_name = '\(productName)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
            if !lot.isEmpty{
                let predicate = NSPredicate(format: "lot = '\(lot)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
            if !serial.isEmpty{
                let predicate = NSPredicate(format: "serial = '\(serial)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
            if !ndc.isEmpty{
                let predicate = NSPredicate(format: "NDC = '\(ndc)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
            if !gtin14.isEmpty{
                let predicate = NSPredicate(format: "gtin14 = '\(gtin14)'")
                itemListShowArray = (itemListShowArray! as NSArray).filtered(using: predicate)
            }
        }
            listTable.reloadData()
 
    }
    func clearAll(){
        /*
        searchDict = NSMutableDictionary()
        filterButton.isSelected = false

        if let item = Utility.getObjectFromDefauls(key: "ScanFailedItemsArray"){
            itemList = item as! Array<Any>?
            self.createItemDetailsArray()
        }
        *///,,,temp sb11
    }
       
}
