//
//  VerifiedSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 29/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class VerifiedSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    var itemsList:Array<Any>?
    var shipmentItems:NSArray?
    var shipmentId:String?
    var allproducts:NSDictionary?
    var failedSerials = Array<Dictionary<String,Any>>()
    var isLotBased : Bool!
    var verfiedLotSerials = Array<Dictionary<String,Any>>()
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.shipmentId = defaults.string(forKey: "shipmentId")
        filterButton.isSelected = true
        sectionView.roundTopCorners(cornerRadious: 40)
        allproducts = UserInfosModel.getAllProducts()
        if let shipmentData = defaults.object(forKey: ttrShipmentDetails){
            do{
                let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData as! Data) as! NSDictionary
                if let uuid:String = shipmentDict["uuid"] as? String{
                    shipmentId = uuid
                    if (isLotBased != nil) && isLotBased{
                        itemsList = verfiedLotSerials
                        listTable.reloadData()
                    }else{
                        getVerifiedSerials()
                    }
                }
                
                if let items:NSArray = shipmentDict["ship_lines_item"] as? NSArray{
                    shipmentItems = items
                }
                
            }catch{
                print("Shipment Data Not Found")
            }
        }
    }
    //MARK: - End
    //MARK: - Private Method
    func getVerifiedSerials(){
        
        let appendStr:String! = (shipmentId ?? "") + "/verify"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ReceivingVerifiedSerials", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let serials_validated:Array<Any> = responseDict["serials_validated"] as? Array<Any>{
                        self.itemsList = serials_validated
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
    func deleteVerifiedSerial(requestData:NSDictionary){
        print(requestData)
        let appendStr:String! = (shipmentId ?? "") + "/verify"
        
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ReceivingVerifiedSerials", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let result:String = responseDict["result"] as? String{
                        if result == "OK"{
                            Utility.showPopup(Title: Success_Title, Message:"Resource Deleted.", InViewC: self)
                            self.getVerifiedSerials()
                            NotificationCenter.default.post(name: Notification.Name("UpdateVerifiedSerials"), object: nil)
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
    //MARK: - IBAction
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let dataDict:NSDictionary = itemsList?[sender.tag] as! NSDictionary
        
        var requestParam = [String:Any]()
        requestParam["type"] = "GS1_BARCODE"
        
        if let serial = dataDict["serial"]{
            requestParam["serial"] = serial
        }
        
        let msg = "You are about to delete the resource.\nThis operation can’t be undone.\n\nProceed to the deletion?"
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            if self.isLotBased{
                self.itemsList?.remove(at: sender.tag)
                Utility.saveObjectTodefaults(key: "\(self.shipmentId ?? "")_verifiedArray", dataObject: self.itemsList as Any)
                self.listTable.reloadData()

            }else{
               self.deleteVerifiedSerial(requestData: requestParam as NSDictionary)
            }
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        
    }
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        filterButton.isSelected = !filterButton.isSelected
        listTable.reloadData()
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if filterButton.isSelected {
            return itemsList?.count ?? 0
        }else{
            return failedSerials.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var dataDict:NSDictionary
        
        if !filterButton.isSelected{
            dataDict = failedSerials[indexPath.section] as NSDictionary
        }else{
            dataDict = itemsList?[indexPath.section] as! NSDictionary
        }
        
        if let is_ok = dataDict["is_ok"] as? Bool{
            if !is_ok {
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = Utility.hexStringToUIColor(hex: "F25E5E").cgColor
                cell.statusButton.setImage(UIImage(named: "error"), for: .normal)
                cell.deleteButton.isHidden = true
            }else{
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.statusButton.setImage(UIImage(named: "check"), for: .normal)
                cell.deleteButton.isHidden = false
            }
        }
        
        var dataStr:String = ""
        
        if let product_uuid = dataDict["product_uuid"] as? String{
            dataStr = product_uuid
            if allproducts != nil{
                if let dict = allproducts![product_uuid] as? NSDictionary{
                    if let name = dict["name"] as? String{
                        dataStr = name
                    }
                }
            }else if shipmentItems != nil{
                let predicate = NSPredicate(format: "uuid='\(dataStr)'")
                if let array = shipmentItems?.filtered(using: predicate) as NSArray? {
                    if let dict = (array.firstObject as? NSDictionary){
                        if let name = dict["name"] as? String{
                            dataStr = name
                        }
                    }
                }
            }
        }
        cell.productNameLabel.text = dataStr
        
        dataStr = ""
        if let serial = dataDict["serial"] as? String{
            dataStr = serial
        }else if let serial = dataDict["serial"] as? NSNumber{
            dataStr = "\(serial)"
        }
        
        cell.udidValueLabel.text = dataStr
        
        dataStr = ""
        if let lot = dataDict["lot"] as? String{
            dataStr = lot
        }
        
        cell.lotValueLabel.text = dataStr
        
        dataStr = ""
        if let lot = dataDict["gtin14"] as? String{
            dataStr = lot
        }
        
        cell.gtin14Label.text = dataStr
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        cell.expirationDateLabel.text = ""
        if let exDate = dataDict["expiration_date"] as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                
                cell.expirationDateLabel.text = formattedDate
                
            }
        }
        cell.deleteButton.tag = indexPath.section
        return cell
    }
    //MARK: - End
}
