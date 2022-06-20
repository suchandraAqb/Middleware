//
//  ARSFProductFoundSerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 13/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFProductFoundSerialListViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var lotSerialTable: UITableView!
    @IBOutlet weak var productName:UILabel!
    @IBOutlet weak var lotNumber:UILabel!
    @IBOutlet weak var exportLabel: UILabel!//,,,sb7
    @IBOutlet weak var exportButton : UIButton!//,,,sb3
    
    var product_uuid : NSString!
    var lot_number : NSString!
    var product : [[String : Any]]!
    var uniqueSerialArr : [String]!
    var product_detailsArr = Array<Dictionary<String,Any>>()
    var filterArray : [[String:Any]] = []//,,,sb10
    
    var selectedDetailsDict = [String:Any]()//,,,sb11-10

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
//        print("selectedDetailsDict.....",selectedDetailsDict)//,,,sb11-10 //,,,sb11-12
        
        filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: lot_number as String)//,,,sb10 set global filterArray
//        print ("filterArray",filterArray)
        
        if let unique = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.simple_serial") as? [String]{
            uniqueSerialArr = unique
        }
//        print ("uniqueSerialArr>><<",uniqueSerialArr,uniqueSerialArr.count)
        
        if filterArray.count>0 {
            let dict = filterArray.first
            productName.text = dict!["product_name"] as? String
            lotNumber.text = "Lot".localized() + " \(lot_number ?? "")" //,,,sb-lang1
        }
        lotSerialTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func exportButtonPressed(_ sender:UIButton){
        self.prepareExportData()
//        print ("self.selectedDetailsDict.....",self.selectedDetailsDict)//,,,sb11-10 //,,,sb11-12
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard.init(name:"AugmentedReality",bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ARExportProductThirdView") as! ARExportProductThirdViewController
            controller.productDetailsArr = self.product_detailsArr
            controller.productNameString = self.productName.text as NSString?
            controller.lot = self.lotNumber.text as NSString?
            controller.selectedDetailsDict = self.selectedDetailsDict//,,,sb11-10
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func eventLogButtonPressed(_ sender: UIButton) {
        let simpleSerialPredicate = NSPredicate(format: "simple_serial like %@",uniqueSerialArr[sender.tag]);
        let tempFilteredArray = filterArray.filter { simpleSerialPredicate.evaluate(with: $0) };
        if tempFilteredArray.count>0 {
            let dict = tempFilteredArray.first
            if let gs1Serial = dict!["gs1_serial"] as? String{
                let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
                let controller = storyboard.instantiateViewController(withIdentifier: "SFSerialDetailsView") as! SFSerialDetailsViewController
                controller.serial = gs1Serial
                if let serial = dict!["simple_serial"] as? String {
                    controller.simple_serial = serial
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }//,,,sb10
    
    @IBAction func deleteButtonPressed(_ sender:UIButton){
        //,,,sb3
        /*
        let msg = "You are about to delete the serial?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if self.uniqueSerialArr.count > 0 {
                self.uniqueSerialArr.remove(at:sender.tag)
                if self.uniqueSerialArr.isEmpty {
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
            }else{
                self.exportButton.alpha = 1
                self.exportButton.isUserInteractionEnabled = true
            }
                self.lotSerialTable.reloadData()
            }
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
         */
        
        let msg = "You are about to delete the serial?".localized()
        
        let confirmAlert = UIAlertController(title: "Confrimation".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (UIAlertAction) in
            if self.uniqueSerialArr.count > 0 {
                self.uniqueSerialArr.remove(at:sender.tag)
                if self.uniqueSerialArr.isEmpty {
                    self.exportLabel.alpha = 0.5
                    self.exportButton.alpha = 0.5
                    self.exportButton.isUserInteractionEnabled = false
            }else{
                self.exportLabel.alpha = 1
                self.exportButton.alpha = 1
                self.exportButton.isUserInteractionEnabled = true
            }
                self.lotSerialTable.reloadData()
            }
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        //,,,sb3
}
    //MARK:- End
    
    
    //MARK: - Privete Method
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
//            var uniqueArr = NSArray()
           // var uniqueSerialArr = NSArray()
            var lotDetailsArray = Array<Dictionary<String,Any>>()
            var productDetailsDict = [String:Any]()
            
//            if let unique = (product as NSArray).value(forKeyPath: "@distinctUnionOfObjects.lot_number") as? [String]{
//                uniqueArr = unique as NSArray
//            }
//            for lotNumeber in uniqueArr{
                lotDict["lot_no"] = lot_number
            
//                let filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: lotNumeber as! String)
//                    if let unique = (filterArray as NSArray).value(forKeyPath: "@distinctUnionOfObjects.simple_serial") as? [String]{
//                        uniqueSerialArr = unique as NSArray
//                }
                lotDict["serials"] = uniqueSerialArr
                lotDetailsArray.append(lotDict)
//            }
            productDetailsDict["product_uuid"] = product_uuid
            productDetailsDict["lot_details"] = lotDetailsArray
            product_detailsArr.append(productDetailsDict)
        */
        
        var lotDict = [String:Any]()
        var lotDetailsArray = Array<Dictionary<String,Any>>()
        var productDetailsDict = [String:Any]()
        
        product_detailsArr = []
        
        let filterArray = self.getInvidualProductLotList(uuid: product_uuid as String, lot: lot_number as String)
        var serialArray = Array<Dictionary<String,Any>>()
        for lotDict in filterArray {
            let simple_serial = lotDict["simple_serial"]  as? String
            if self.uniqueSerialArr .contains(simple_serial!) {
                let gs1_serial = lotDict["gs1_serial"]  as? String
                let serial_format = "PRODUCT_SIMPLE_SERIAL"

                var serialDict = [String:Any]()
                serialDict["serial"] = simple_serial
                serialDict["serial_format"] = serial_format
                serialDict["barcode"] = gs1_serial
                serialArray.append(serialDict)
            }//,,,sb3
        }
        lotDict["serials"] = serialArray
        lotDict["lot_no"] = lot_number
        lotDetailsArray.append(lotDict)

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
        if !uniqueSerialArr.isEmpty {
            return uniqueSerialArr.count
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
        cell.eventLogButton.tag = indexPath.row //,,,sb10
        
        
        let isdeleteShow = defaults.object(forKey: "collect_result") as! Bool
        if isdeleteShow {
            cell.deleteButton.isHidden = false
        }else{
            cell.deleteButton.isHidden = true
        }
        if uniqueSerialArr.count>0 {
            
            //,,,sb10
//            cell.lotNumber.text = uniqueSerialArr[indexPath.row]
            cell.serialNumberLabel.text = uniqueSerialArr[indexPath.row]

            let simpleSerialPredicate = NSPredicate(format: "simple_serial like %@",uniqueSerialArr[indexPath.row]);
            let tempFilteredArray = filterArray.filter { simpleSerialPredicate.evaluate(with: $0) };
            if tempFilteredArray.count>0 {
                let dict = tempFilteredArray.first
                
                //,,,sb13
                cell.statusLabel.text = ""
                cell.gtinLabel.text =  ""
                cell.expirationDateLabel.text = ""
                //,,,sb13

                
                if let status = dict!["status"] as? String {
                    cell.statusLabel.text = ((SFStatus[status] ?? "")?.localized())!
                }
                
                if let product_gtin14 = dict!["product_gtin14"] as? String {
                    cell.gtinLabel.text =  product_gtin14
                }
                
                if let expiration_date = dict!["expiration_date"] as? String {
                    cell.expirationDateLabel.text = expiration_date
                }
                
            }
            //,,,sb10
        }
        return cell
    }
}
