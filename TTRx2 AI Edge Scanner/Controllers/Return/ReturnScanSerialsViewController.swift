//
//  ReturnScanSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 24/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnScanSerialsViewController: BaseViewController {
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var resalableView: UIView!
    @IBOutlet weak var quarantineView: UIView!
    @IBOutlet weak var notResalableView: UIView!
    @IBOutlet weak var resalableButton: UIButton!
    @IBOutlet weak var quarantineButton: UIButton!
    @IBOutlet weak var notResalableButton: UIButton!
    @IBOutlet weak var viewProductListButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var resalableCountLabel: UILabel!
    @IBOutlet weak var quarantineCountLabel: UILabel!
    @IBOutlet weak var notResalableCountLabel: UILabel!
    @IBOutlet weak var verifiedButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var errorButton: UIButton!
    var itemsList:[Return_Serials]?
    var isOnVRS = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        quarantineView.setRoundCorner(cornerRadious: 8)
        notResalableView.setRoundCorner(cornerRadious: 8)
        resalableView.setRoundCorner(cornerRadious: 8)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateData()
    }
    //MARK: - End
    //MARK: - Private Method
    func populateData(){
        fetchValidProducts()
        let resalable = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Resalable.rawValue)
        resalableCountLabel.text = "\(resalable)"
        
        let quarantine = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Quarantine.rawValue)
        quarantineCountLabel.text = "\(quarantine)"
        
        let destruct = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Destruct.rawValue)
        notResalableCountLabel.text = "\(destruct)"
        
    }
    func fetchValidProducts(status:String = ""){
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            
            do{
                var predicate:NSPredicate!
                if status.isEmpty{
                    predicate = NSPredicate(format: "return_uuid == '\(txt)'")
//                    predicate = NSPredicate(format: "return_uuid == '\(txt)' and status !='\(Return_Serials.Status.Removed.rawValue)'")
                    
                }else{
                    predicate = NSPredicate(format: "return_uuid == '\(txt)' and status = '\(status)'")
                }
                
                let return_obj = try PersistenceService.context.fetch(Return_Serials.fetchRequestWithPredicate(predicate: predicate))
                
                //print(return_obj as NSArray)
                if !return_obj.isEmpty{
                    itemsList = return_obj
                    listTable.reloadData()
                    
                }else{
                    itemsList = []
                    listTable.reloadData()
                }
                
            }catch let error {
                print(error.localizedDescription)
                
            }
        }
    }
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func resalableButtonPressed(_ sender: UIButton) {}
    @IBAction func quarantineButtonPressed(_ sender: UIButton) {}
    @IBAction func notResalableButtonPressed(_ sender: UIButton) {}
    @IBAction func viewProductListButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnProductSummaryView") as! ReturnProductSummaryViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    //    @IBAction func verifiedButtonPressed(_ sender: UIButton) {}
    //    @IBAction func pendingButtonPressed(_ sender: UIButton) {}
    //    @IBAction func errorButtonPressed(_ sender: UIButton) {}
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        let popUpAlert = UIAlertController(title: "", message: "Filter serials by Status".localized(), preferredStyle: .actionSheet)
      
        let allAction = UIAlertAction(title: "All".localized(), style: .default, handler:  { (UIAlertAction) in
            self.fetchValidProducts()
        })
        
        let verifyAction = UIAlertAction(title: "Verified".localized(), style: .default, handler:  { (UIAlertAction) in
            self.fetchValidProducts(status:Return_Serials.Status.Verified.rawValue)
        })
        
        let pendingAction = UIAlertAction(title: "Pending".localized(), style: .default, handler:  { (UIAlertAction) in
            self.fetchValidProducts(status:Return_Serials.Status.Pending.rawValue)
        })
        
        let errorAction = UIAlertAction(title: "Error".localized(), style: .default, handler:  { (UIAlertAction) in
            self.fetchValidProducts(status:Return_Serials.Status.Failed.rawValue)
        })
        
        let removedAction = UIAlertAction(title: "Removed".localized(), style: .default, handler:  { (UIAlertAction) in
            self.fetchValidProducts(status:Return_Serials.Status.Removed.rawValue)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
        })
        
        popUpAlert.addAction(allAction)
        popUpAlert.addAction(verifyAction)
        popUpAlert.addAction(pendingAction)
        popUpAlert.addAction(errorAction)
        popUpAlert.addAction(removedAction)
        popUpAlert.addAction(cancelAction)
        
        if let popoverController = popUpAlert.popoverPresentationController{
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            
        }
        self.present(popUpAlert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton){
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to remove this serial?".localized()
        controller.delegate = self
        controller.isIndexRequired = true
        controller.indexNumber = sender.tag
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        
    }
    //MARK: - End
    
    //MARK: - API CALL
    func removeSerial_WebServiceCall(serial:Return_Serials){
        if serial.status == "VERFIED" {
        var requestDict = [String:Any]()
        requestDict["return_uuid"] = defaults.object(forKey: "current_returnuuid") as? String
        requestDict["format"] = "GS1_BARCODE"
        requestDict["action"] = "REMOVE"
        requestDict["serial"] = serial.barcode ?? ""
        requestDict["condition"] = serial.condition ?? ""
        requestDict["is_vrs_check_enabled"] = self.isOnVRS ? "1" : "0"
        
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "RemoveReturnSerial", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self,appendStr: "", isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        PersistenceService.context.delete(serial)
                        PersistenceService.saveContext()
                        self.populateData()
                        Utility.showPopup(Title: Success_Title, Message: "Serial successfully removed.".localized() , InViewC: self)
                        return
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
        }else{
            if let _ = serial.product_uuid {
            PersistenceService.context.delete(serial)
            PersistenceService.saveContext()
            self.populateData()
            Utility.showPopup(Title: Success_Title, Message: "Serial successfully removed.".localized() , InViewC: self)
            return
        }
     }
   }
}
//MARK: - Tableview Delegate and Datasource
extension ReturnScanSerialsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReturnScanSerialsCell") as! ReturnScanSerialsCell
        
        let product = itemsList?[indexPath.section]
        if product != nil {
            
            
            cell.serialLabel.text = product?.serial ?? ""
            if product?.condition == Return_Serials.Condition.Resalable.rawValue {
                cell.conditionLabel.text = "Resalable".localized()
            }else if product?.condition == Return_Serials.Condition.Destruct.rawValue {
                cell.conditionLabel.text = "Not Resalable".localized()
            }else{
                cell.conditionLabel.text = product?.condition?.capitalized ?? ""
            }
            
//               cell.failedReasonLabel.text = product?.failed_reason ?? ""
            
                if product?.status == Return_Serials.Status.Pending.rawValue {
                            cell.setBorder(width: 1, borderColor: UIColor(red: 1.00, green: 0.85, blue: 0.45, alpha: 1.00), cornerRadious: 10)
                            cell.failedReasonLabel.text = product?.failed_reason ?? ""
                        }else if product?.status == Return_Serials.Status.Verified.rawValue{
                            cell.setBorder(width: 1, borderColor: UIColor(red: 0.22, green: 0.87, blue: 0.65, alpha: 1.00), cornerRadious: 10)
                            cell.failedReasonLabel.text = product?.failed_reason ?? ""
                        }else if product?.status == Return_Serials.Status.Failed.rawValue{
                            
                            cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex:"F25E5E"), cornerRadious: 10)
                            cell.failedReasonLabel.text = product?.failed_reason ?? ""
                        }else if product?.status == Return_Serials.Status.Removed.rawValue{
                            
                            cell.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex:"C51212"), cornerRadious: 10)
                            cell.failedReasonLabel.text = product?.error ?? ""
                        }
            
            
            
            if product?.status == Return_Serials.Status.Pending.rawValue && product?.is_send_for_verification ?? false {
                cell.deleteButton.isHidden = true
            }else{
                cell.deleteButton.isHidden = false
            }
            
            cell.deleteButton.tag = indexPath.section
            
        }
        return cell
    }
    //MARK: - End
}

//MARK: - ConfirmationViewDelegate
extension ReturnScanSerialsViewController : ConfirmationViewDelegate{
    func doneButtonPressed() {
    }
    func doneButtonPressedWithIndex(index: Int) {
        if let product = itemsList?[index]{
            if product.status == Return_Serials.Status.Pending.rawValue && (product.event_id ?? "") == ""{
                PersistenceService.context.delete(product)
                PersistenceService.saveContext()
                self.populateData()
            }else{
                self.removeSerial_WebServiceCall(serial:product)
            }
        }
    }
}
class ReturnScanSerialsCell: UITableViewCell {
    
    
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var failedReasonLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
    }
    
}
//MARK: - End

