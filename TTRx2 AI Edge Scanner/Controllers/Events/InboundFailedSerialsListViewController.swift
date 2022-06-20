//
//  InboundFailedSerialsListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by AQB Solutions Private Limited on 14/12/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData

class InboundFailedSerialsListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var shipmentCountLabel: UILabel!
    
    @IBOutlet weak var productAddedView : UIView!
    @IBOutlet weak var productAddedSubView : UIView!
    @IBOutlet weak var gtin14Label : UILabel!
    @IBOutlet weak var lotLabel : UILabel!
    @IBOutlet weak var serialLabel : UILabel!
    @IBOutlet weak var expirationDateLabel : UILabel!
    @IBOutlet weak var productNameTextFiled : UITextField!
    @IBOutlet weak var updateButton : UIButton!
    
    
    
    var itemsList: [InboundFailedSerials] = []
    var totalResult = 0
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shipmentCountLabel.text = "0 " + "found".localized()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        updateButton.setRoundCorner(cornerRadious: updateButton.frame.height/2.0)
        productAddedSubView.setRoundCorner(cornerRadious: 20)
        createInputAccessoryView()
        productNameTextFiled.inputAccessoryView = inputAccView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        productAddedView.isHidden = true
        getDataFromDB()
    }
    //MARK: - End
    

    //MARK: - IBActions
    
    @IBAction func closeAddProductViewButtonPressed(_ sender:UIButton){
        productAddedView.isHidden = true
    }
    @IBAction func updateButtonPressed(_ sender:UIButton){
        if let str = productNameTextFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines),str.isEmpty{
            Utility.showPopup(Title: "", Message: "Enter the product name", InViewC: self)
        }else{
            self.setUpforProductAdd(scannedCode: sender.accessibilityHint!)
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if sender.accessibilityHint == "AddProduct" {
            let dataDict = itemsList[sender.tag]
            productNameTextFiled.text = ""
            if let txt = dataDict.serial_number {
                serialLabel.text = txt
            }
            if let txt = dataDict.lot_number {
                lotLabel.text = txt
            }
            if let txt = dataDict.gtin14 {
               gtin14Label.text = txt
            }
            if let txt = dataDict.expiration_date {
                if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy", dateStr: txt){
                    expirationDateLabel.text = formattedDate
                }
            }
            if let txt = dataDict.scanned_code {
                updateButton.accessibilityHint = txt
            }
            
            productAddedView.isHidden = false
        }else{
//            let productDict = NSMutableDictionary()
//            let dataDict = itemsList[sender.tag]
//            if let txt = dataDict.product_name {
//                productDict.setValue(txt, forKey: "product_name")
//            }
//            if let txt = dataDict.product_uuid {
//                productDict.setValue(txt, forKey: "product_uuid")
//            }
//            if let txt = dataDict.serial_number {
//                productDict.setValue(txt, forKey: "serial_number")
//            }
//            if let txt = dataDict.lot_number {
//                productDict.setValue(txt, forKey: "lot_number")
//            }
//            if let txt = dataDict.gtin14 {
//                productDict.setValue(txt, forKey: "gtin14")
//            }
//            if let txt = dataDict.expiration_date {
//                productDict.setValue(txt, forKey: "expiration_date")
//            }
//            
//            
//            let controller = self.storyboard?.instantiateViewController(withIdentifier: "FailedSerialSendQuarantineView") as! FailedSerialSendQuarantineViewController
//            controller.adjustmentType = Adjustments_Types.Quarantine.rawValue
//            controller.productDetailsDict = productDict as! [String : Any]
//            self.navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete this entry from database?".localized()
        let confirmAlert = UIAlertController(title: "Delete?".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            let obj = self.itemsList[sender.tag]
            PersistenceService.context.delete(obj)
            PersistenceService.saveContext()
            self.itemsList.remove(at: sender.tag)
            self.getDataFromDB()
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    //MARK: - End
    
    //MARK: - PrivateMethod
    
    func setUpforProductAdd(scannedCode : String){
        let requestDict = NSMutableDictionary()
        requestDict.setValue("Pharmaceutical", forKey: "type")
        requestDict.setValue("AVAILABLE", forKey: "status")
        requestDict.setValue(true, forKey: "is_active")
        requestDict.setValue(false, forKey: "is_send_copy_outbound_shipments_to_2nd_party")
        requestDict.setValue(false, forKey: "is_override_products_packaging_type_validation")
        requestDict.setValue(gtin14Label.text, forKey: "gtin14")
        
        let dict = NSMutableDictionary()
        let arr = [] as NSMutableArray
        dict.setValue("en", forKey: "language_code")
        dict.setValue(productNameTextFiled.text, forKey: "name")
        dict.setValue("", forKey: "description")
        dict.setValue("", forKey: "composition")
        dict.setValue("", forKey: "product_long_name")
        arr.add(dict)
        requestDict.setValue(Utility.json(from: arr) ,forKey: "product_descriptions")
        var productName = ""
        if let txt = productNameTextFiled.text {
            productName = txt
        }
        self.addProductApiCall(requestDict: requestDict , scannedCode: scannedCode , productName: productName)
    }
    func getDataFromDB(){
        do {
            let fetchRequest = NSFetchRequest<InboundFailedSerials>(entityName: "InboundFailedSerials")
            let serial_obj = try PersistenceService.context.fetch(fetchRequest)
            self.itemsList = serial_obj
            if !itemsList.isEmpty{
                self.shipmentCountLabel.text = "\(self.itemsList.count) " + "found".localized()
            }else{
                self.shipmentCountLabel.text = "\(self.itemsList.count) " + "found".localized()
            }
            listTable.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: - End
    
    
    //MARK: Api call
    func addProductApiCall(requestDict : NSDictionary , scannedCode : String , productName : String){
        DispatchQueue.main.async { [self] in
            productAddedView.isHidden = true
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "AddNewProduct", serviceParam: requestDict, parentViewC: self, willShowLoader: false, viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async { [self] in
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if (responseDict["uuid"] as? String) != nil {
                        let predicate = NSPredicate(format:"scanned_code='\(scannedCode)'")
                        do{
                            let serial_obj = try PersistenceService.context.fetch(InboundFailedSerials.fetchRequestWithPredicate(predicate: predicate))
                            if let obj = serial_obj.first {
                                obj.product_name = productName
                                obj.product_uuid = responseDict["uuid"] as? String
                                PersistenceService.saveContext()
                            }
                        }catch let error{
                            print(error.localizedDescription)
                            
                        }
                        self.getDataFromDB()
                    }
            }else{
                let dict = responseData as! NSDictionary
                let error = dict["message"] as! String
                    Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                }
            }
        }
    }
    
    //MARK: End
    
    
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 2))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 2))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return itemsList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboundFailedSerialListTableViewCell") as! InboundFailedSerialListTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        let dataDict = itemsList[indexPath.section]
        
        if let txt = dataDict.shipment_id {
            cell.shipmentUuidLabel.text = txt
        }
        if let txt = dataDict.product_name , txt != ""{
            cell.productNameLabel.text = txt
            cell.actionButton.setTitle("Quarantine", for: .normal)
            cell.actionButton.accessibilityHint = "Quarantine"
        }else{
            cell.actionButton.setTitle("Add Product", for: .normal)
            cell.actionButton.accessibilityHint = "AddProduct"
        }
        if let txt = dataDict.product_uuid {
            cell.productUuidLabel.text = txt
        }
        if let txt = dataDict.serial_number {
            cell.productSerialLabel.text = txt
        }
        if let txt = dataDict.lot_number {
            cell.productLotLabel.text = txt
        }
        if let txt = dataDict.gtin14 {
            cell.productGtinLabel.text = txt
        }
        if let txt = dataDict.expiration_date {
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy", dateStr: txt){
                cell.productExpirationLabel.text = formattedDate
            }
        }
        if let txt = dataDict.scanned_code {
            cell.scannedCodeLabel.text = txt
        }
        if let txt = dataDict.reason {
            cell.reasonLabel.text = txt
        }

        cell.deleteButton.tag = indexPath.section
        cell.actionButton.tag = indexPath.section
        
        return cell
        
    }
    //MARK: - End
}




//MARK: table cell class
class InboundFailedSerialListTableViewCell: UITableViewCell {
    @IBOutlet weak var shipmentUuidLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productUuidLabel: UILabel!
    @IBOutlet weak var productSerialLabel: UILabel!
    @IBOutlet weak var productLotLabel: UILabel!
    @IBOutlet weak var productGtinLabel: UILabel!
    @IBOutlet weak var productExpirationLabel: UILabel!
    @IBOutlet weak var scannedCodeLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        Utility.UpdateUILanguage(multiLingualViews)
    }
    
}


