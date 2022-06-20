//
//  ARSFProductFoundDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 13/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFProductFoundDetailsViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var listDetailsTable: UITableView!
    @IBOutlet weak var productName : UILabel!
    @IBOutlet weak var exportLabel: UILabel!//,,,sb7
    @IBOutlet weak var exportButton : UIButton!//,,,sb3

    var product_uuid : NSString!
    var product : [[String : Any]]!
    var uniqueArr : [String]!
    var product_detailsArr = Array<Dictionary<String,Any>>()
    
    var selectedDetailsDict = [String:Any]()//,,,sb11-10

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
//        print("selectedDetailsDict.....",selectedDetailsDict)//,,,sb11-10 //,,,sb11-12
        
        if let unique = (product as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
            uniqueArr = unique
        }
        if !product.isEmpty && product.count>0 {
            let dict = product.first! as NSDictionary
            productName.text = dict["product_name"] as? String
        }
        listDetailsTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func deleteButtonPressed(_ sender:UIButton) {
        //,,,sb3
        /*
        let msg = "You are about to delete the lot?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if self.uniqueArr.count > 0 {
                self.uniqueArr.remove(at:sender.tag)
                if self.uniqueArr.isEmpty {
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
            }else{
                self.exportButton.alpha = 1
                self.exportButton.isUserInteractionEnabled = true
            }
                self.listDetailsTable.reloadData()
          }
        }
            confirmAlert.addAction(noAction)
            confirmAlert.addAction(yesAction)
            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        */
        let msg = "You are about to delete the lot?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (UIAlertAction) in
            if self.uniqueArr.count > 0 {
                self.uniqueArr.remove(at:sender.tag)
                if self.uniqueArr.isEmpty {
                    self.exportLabel.alpha = 0.5
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
            }else{
                self.exportLabel.alpha = 1
                self.exportButton.alpha = 1
                self.exportButton.isUserInteractionEnabled = true
            }
                self.listDetailsTable.reloadData()
          }
        }
            confirmAlert.addAction(noAction)
            confirmAlert.addAction(yesAction)
            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        //,,,sb3
    }
    
    @IBAction func exportButtonPressed(_ sender:UIButton){
        self.prepareExportData()
//        print ("self.selectedDetailsDict.....",self.selectedDetailsDict)//,,,sb11-10 //,,,sb11-12
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name:"AugmentedReality",bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARExportProductSecondView") as! ARExportProductSecondViewController
            controller.productDetailsArr = self.product_detailsArr
            controller.productNameString = self.productName.text as NSString?
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //MARK:- End
    
    
    //MARK: - Privete Method
    func getInvidualProductLotcount(uuid:String,lot:String)->Int{
        var filterList = [[String:Any]]()
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)' and lot_number='\(lot)'")
        filterList = (product as NSArray).filtered(using: predicate) as! [[String : Any]]
        return filterList.count
    }
    func getInvidualProductLotList(uuid:String,lot:String)->[[String:Any]]{
        var filterList = [[String:Any]]()
        let predicate = NSPredicate(format: "product_uuid = '\(uuid)' and lot_number='\(lot)'")
        filterList = (product as NSArray).filtered(using: predicate) as! [[String : Any]]
        return filterList
    }
    
    func prepareExportData() {
        //,,,sb3
        /*
            var lotDict = [String:Any]()
            // var uniqueArr = NSArray()
            var uniqueSerialArr = NSArray()
            var lotDetailsArray = Array<Dictionary<String,Any>>()
            var productDetailsDict = [String:Any]()
            product_detailsArr = []
            //            if let unique = (product as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
            //                uniqueArr = unique as NSArray
            //            }
            for lotNumeber in uniqueArr{
                lotDict["lot_no"] = lotNumeber

                let filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: lotNumeber )
                    if let unique = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.simple_serial") as? [String]{
                        uniqueSerialArr = unique as NSArray
                }
                lotDict["serials"] = uniqueSerialArr
                lotDetailsArray.append(lotDict)
            }
            productDetailsDict["product_uuid"] = product_uuid
            productDetailsDict["lot_details"] = lotDetailsArray
            product_detailsArr.append(productDetailsDict)
        */
              
        
        var lotDict = [String:Any]()
        var lotDetailsArray = Array<Dictionary<String,Any>>()
        var productDetailsDict = [String:Any]()
        product_detailsArr = []
        
        for lotNumeber in uniqueArr {
            let filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: lotNumeber)
            var serialArray = Array<Dictionary<String,Any>>()
            for lotDict in filterArray {
                let simple_serial = lotDict["simple_serial"]  as? String
                let gs1_serial = lotDict["gs1_serial"]  as? String
                let serial_format = "PRODUCT_SIMPLE_SERIAL"
                
                var serialDict = [String:Any]()
                serialDict["serial"] = simple_serial
                serialDict["serial_format"] = serial_format
                serialDict["barcode"] = gs1_serial
                serialArray.append(serialDict)
            }
            lotDict["serials"] = serialArray
            lotDict["lot_no"] = lotNumeber
            lotDetailsArray.append(lotDict)
        }
        productDetailsDict["product_uuid"] = product_uuid
        productDetailsDict["lot_details"] = lotDetailsArray
        product_detailsArr.append(productDetailsDict)
        //,,,sb3
    }
    //MARK:- End
    
    
    //MARK: - Webservice Call
    
    //MARK:- End
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !uniqueArr.isEmpty {
            return uniqueArr.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SFProductDetalscell") as! SFProductDetalscell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.deleteButton.tag = indexPath.row
        let isdeleteShow = defaults.object(forKey: "collect_result") as! Bool
        if isdeleteShow {
            cell.deleteButton.isHidden = false
        }else{
            cell.deleteButton.isHidden = true
        }

        if uniqueArr.count>0 {
            cell.lotNumber.text = uniqueArr[indexPath.row]
            let value = (getInvidualProductLotcount(uuid: product_uuid as String, lot: cell.lotNumber.text!))
            cell.quantityLabel.text = "\(value)"
            
            //,,,sb10
            
            //,,,sb13
            cell.gtinLabel.text =  ""
            cell.expirationDateLabel.text = ""
            //,,,sb13
            
            let filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: uniqueArr[indexPath.row])
            
            var expirationDateArr : [String]!
            if let expiration_date = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.expiration_date") as? [String]{
                expirationDateArr = expiration_date
            }
//            if expirationDateArr.count > 0 {
            if expirationDateArr != nil && expirationDateArr.count > 0 {//,,,sb13
                let expirationDateString = expirationDateArr.joined(separator: ",") // "1-2-3"
//                print ("expirationDateArr..",expirationDateArr!,expirationDateString)
                cell.expirationDateLabel.text = "\(expirationDateString )"
            }
            
            var productGtin14Arr : [String]!
            if let product_gtin14 = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_gtin14") as? [String]{
                productGtin14Arr = product_gtin14
            }
//            if productGtin14Arr.count > 0 {
            if productGtin14Arr != nil && productGtin14Arr.count > 0 {//,,,sb13
                let productGtin14String = productGtin14Arr.joined(separator: ",") // "1-2-3"
//                print ("productGtin14Arr..",productGtin14Arr!,productGtin14String)
                cell.gtinLabel.text = "\(productGtin14String )"
            }
            //,,,sb10
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name:"AugmentedReality",bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARSFProductFoundSerialListView") as! ARSFProductFoundSerialListViewController
            controller.product_uuid = self.product_uuid
            controller.product = self.product
            controller.lot_number = self.uniqueArr[indexPath.row] as NSString
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
class SFProductDetalscell: UITableViewCell {
    
    @IBOutlet weak var lotNumber: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var deleteButton : UIButton!
    @IBOutlet var quantityLabel : UILabel!    
    //,,,sb10
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var eventLogButton: UIButton!
    //,,,sb10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
