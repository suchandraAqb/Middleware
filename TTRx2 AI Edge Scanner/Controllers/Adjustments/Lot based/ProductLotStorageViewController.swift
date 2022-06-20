//
//  ProductLotStorageViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ProductLotStorageDelegate: class {
    @objc optional func didSelectStorage(data:NSDictionary)
    @objc optional func didSelectStorage(data:NSDictionary,productLot:String,product_uuid:String)
}

class ProductLotStorageViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    weak var delegate: ProductLotStorageDelegate?
    @IBOutlet weak var listTable: UITableView!
    var itemsList:Array<Any>?
    var uniqueitemsList:[Any]?
    var productLot = ""
    var product_uuid = ""
    var isFromList = false
    var isFromInventory: Bool = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        /*itemsList = [
          [
            "location_uuid": "string",
            "location_name": "string",
            "storage_area_uuid": "string",
            "storage_area_name": "string",
            "storage_area_code": "string",
            "storage_shelf_uuid": "string",
            "storage_shelf_name": "string",
            "storage_shelf_code": "string",
            "quantity": 1
          ]
        ]*/
        
        getProductLotStorageList()
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    
    //MARK: - End
    //MARK: - Private Method
    func getProductLotStorageList(){
        var location_uuid = ""
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
           if let txt =  dataDict["location_uuid"] as? String, !txt.isEmpty {
             location_uuid = txt
            }
        }
        
        let appendStr = "\(product_uuid)/lot/per_storage?lot=\(productLot)&restrict=LOT_BASED_ONLY&location_uuid=\(location_uuid)"
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetProducts", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                        if let responseArr = responseData as? Array<Any> {
                            self.itemsList = responseArr
                            self.listTable.reloadData()
                        }
                    
                    if self.itemsList?.count == 0 {
                        if self.isFromInventory {
                            Utility.showAlertWithPopAction(Title:App_Title , Message: "No Lot available in the selected location. ".localized() + "Please select different location or remove this lot.", InViewC: self, isPop: true, isPopToRoot: false)
                        }else{
                            Utility.showAlertWithPopAction(Title:App_Title , Message: "No Lot available in the selected location to".localized() + " \(defaults.value(forKey: "current_adjustment") ?? ""). " + "Please select different location or remove this lot.", InViewC: self, isPop: true, isPopToRoot: false)
                        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductLotStorageCell") as! ProductLotStorageCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        if let dataDict = itemsList?[indexPath.section] as? NSDictionary {
            
            cell.lotNameLabel.text = productLot
            
            var dataStr = ""
            
            if let txt = dataDict["quantity"] as? String{
                
                dataStr = "\(Int(Float(txt) ?? 0))"
            }
            
            cell.quantityLabel.text = dataStr
            
            dataStr = ""
            
            if let txt = dataDict["location_name"] as? String{
                dataStr = txt
            }
            
            cell.locationLabel.text = dataStr
            
            dataStr = ""
            
            if let txt = dataDict["storage_area_name"] as? String{
                dataStr = txt
            }
            
            cell.storageLabel.text = dataStr
            
            dataStr = ""
            
            if let txt = dataDict["storage_shelf_name"] as? String , !txt.isEmpty{
                dataStr = txt
                cell.shelfLabel.text = dataStr
                cell.shelfView.isHidden = false
            }else{
                cell.shelfView.isHidden = true
            }
            
        }
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let dataDict = itemsList?[indexPath.section] as? NSDictionary {
            //if isFromList {
            self.delegate?.didSelectStorage?(data: dataDict, productLot: productLot, product_uuid: product_uuid)
//            }else{
//               self.delegate?.didSelectStorage?(data: dataDict)
//            }
            
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    //MARK: - End
}

class ProductLotStorageCell: UITableViewCell
{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lotNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet var multiLingualViews: [UIView]!
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
        
    }
}
