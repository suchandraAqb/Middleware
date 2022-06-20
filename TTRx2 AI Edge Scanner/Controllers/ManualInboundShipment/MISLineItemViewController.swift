//
//  MISLineItemViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 15/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISLineItemViewController: BaseViewController, AddProductDelegate {
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step5Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step4BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    @IBOutlet weak var step5Label: UILabel!
    //MARK: - End
    
    
    @IBOutlet weak var listTable: UITableView!
    
    @IBOutlet weak var quantityUpdateView: UIView!
    @IBOutlet weak var quantityUpdateContainer: UIView!
    @IBOutlet weak var quantityUpdateTextField: UITextField!
    @IBOutlet weak var quantityUpdateButton: UIButton!
    
    
    @IBOutlet weak var noRecordLabel: UILabel!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var checkUncheckButton:UIButton! 
    @IBOutlet weak var lineItemAutomaticAddview:UIView!
    
    var itemsList:Array<Any>?
    
    var productCount = 0
    var isClearAggreationdata : Bool = false
    var isOnlyLotBasedProduct :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_initialview()
        addProductButton.setRoundCorner(cornerRadious: addProductButton.frame.height/2.0)
        quantityUpdateContainer.setRoundCorner(cornerRadious: 20)
        quantityUpdateButton.setRoundCorner(cornerRadious: quantityUpdateButton.frame.size.height/2.0)
        quantityUpdateTextField.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        createInputAccessoryView()
        quantityUpdateTextField.inputAccessoryView = inputAccView
        if (defaults.object(forKey: "lineItemCheck") != nil){
        if ((defaults.object(forKey: "lineItemCheck")) as! Int == 0) {
            checkUncheckButton.isSelected = false
        }else{
            checkUncheckButton.isSelected = true
        }
    }
}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateProductCount()
        
        let createNew = defaults.bool(forKey: "MIS_create_new")
        if !createNew {
            addProductButton.isHidden = true
            lineItemAutomaticAddview.isHidden = true
            defaults.setValue(0, forKey: "lineItemCheck")
        }
        isClearAggreationdata = false
        setupList()
    }
    
    
    //MARK: - Private Method
    func populateProductCount(){
        var tempProductCount = "0"
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let count = serial_obj.count
                tempProductCount = "\(count)"
                productCount = count
            }else{
                productCount = 0
            }
        }catch let error{
            print(error.localizedDescription)
            productCount = 0
        }
//        productCountLabel.text = tempProductCount + " Product"
    }
    
    func setup_initialview(){
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "MIS_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "MIS_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "MIS_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "MIS_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = false
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted {
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
            step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted {
            step4Button.isUserInteractionEnabled = true
        }
        
    }
    
    func getInfoFilledValue(Id:NSNumber, totalQuantity:NSNumber) -> String {
        var infoStr = "No"
        do{
            let predicate = NSPredicate(format:"misitem_id='\(Id)'")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                if let avalableQuantity = (arr as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
                    if avalableQuantity == totalQuantity {
                        infoStr = "Yes"
                    }
                }
            }
            
        }catch let error{
            print(error.localizedDescription)

        }
        return infoStr
    }
    
    func allProductInfoDone()->Bool{
        var allInfoDone = true
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                for lineItem in arr {
                    if let lineItemdict = lineItem as? NSDictionary {
                        if let id = lineItemdict["id"] as? NSNumber, let quantity = lineItemdict["quantity"] as? NSNumber {
                            let info = getInfoFilledValue(Id: id, totalQuantity: quantity)
                            if info == "No"{
                                allInfoDone = false
                                break
                            }
                        }
                    }
                }
            }else{
                allInfoDone = false
            }
        }catch let error{
            print(error.localizedDescription)
            allInfoDone = false
        }
        return allInfoDone
    }
    
    func setupList(){
        do{
            let predicate = NSPredicate(format:"TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            
            
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                itemsList = arr
                self.checkLotBased()
                listTable.reloadData()
                self.noRecordLabel.isHidden = true
            }else{
                isOnlyLotBasedProduct = false
                itemsList = nil
                listTable.reloadData()
                self.noRecordLabel.isHidden = false
            }
        }catch let error{
            isOnlyLotBasedProduct = false
            print(error.localizedDescription)
            itemsList = nil
            listTable.reloadData()
            self.noRecordLabel.isHidden = false
        }
        
    }
    func checkLotBased(){
            do{
                let predicate = NSPredicate(format:"lot_type='LOT_BASED' || lot_type='LOT_FOUND'")
                let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                    if arr.count == itemsList?.count {
                        isOnlyLotBasedProduct = true
                    }else{
                        isOnlyLotBasedProduct = false
                    }
                }else{
                    isOnlyLotBasedProduct = false
                }
            }catch let error{
                print(error.localizedDescription)
                isOnlyLotBasedProduct = false
            }
        
    }
    
    func removeProduct(data:NSDictionary){
        if let id = data["id"] {
            do{
                let predicate = NSPredicate(format:"id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                if !serial_obj.isEmpty{
                    if let obj = serial_obj.first {
                        PersistenceService.context.delete(obj)
                        PersistenceService.saveContext()
                    }
                }
                
                do{
                    let predicate = NSPredicate(format:"misitem_id='\(id)'")
                    let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
                    if !serial_obj.isEmpty{
                        for obj in serial_obj {
                            PersistenceService.context.delete(obj)
                            PersistenceService.saveContext()
                        }
                    }
                }catch let error{
                    print(error.localizedDescription)
                }
                
                setupList()
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    func checkingLineItemAggregationAndRemove(container_content:[String:Any]){
        if let id = container_content["id"] {
            do{
                let predicate = NSPredicate(format:"id='\(id)'")
                let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                if  serial_obj.isEmpty{
                    do{
                        let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                        if !serial_obj.isEmpty{
                            let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                            self.removeaggregation(data: arr[0] as! NSDictionary)
                        }
                    }catch let error{
                        print(error.localizedDescription)
                    }
                    
                }
        }catch let error{
            print(error.localizedDescription)
            }
        }
    }
    
    
 func removeaggregation(data:NSDictionary){
     if let id = data["id"] as? Int{
         var allid = [Int]()
         var complete = [Int]()
         allid.append(id)
         repeat {
             for tempId in allid {
                 if !complete.contains(tempId) {
                     complete.append(tempId)
                     do{
                         let predicate = NSPredicate(format:"parent_id='\(tempId)'")
                         let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
                         if !serial_obj.isEmpty{
                             let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                             for tempSubDetails in arr {
                                 if let dict = tempSubDetails as? NSDictionary {
                                     if let subid = dict["id"] as? Int{
                                         allid.append(subid)
                                     }
                                 }
                             }
                         }
                     }catch let error{
                         print(error.localizedDescription)
                     }
                 }
             }
         }while !allid.containsSameElements(as: complete)
         
         do{
             let predicate = NSPredicate(format:"sdi IN %@", allid)
             let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
             if !serial_obj.isEmpty{
                 for obj in serial_obj {
                     PersistenceService.context.delete(obj)
                     PersistenceService.saveContext()
                 }
             }
         }catch let error{
             print(error.localizedDescription)
         }
     }
 }
//    func getInfoFilledValue(Id:NSNumber, totalQuantity:NSNumber) -> String {
//        var infoStr = "No"
//        do{
//            let predicate = NSPredicate(format:"misitem_id='\(Id)'")
//            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
//            if !serial_obj.isEmpty{
//                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
//                if let avalableQuantity = (arr as NSArray).value(forKeyPath: "@sum.quantity")  as? NSNumber{
//                    if avalableQuantity == totalQuantity {
//                        infoStr = "Yes"
//                    }
//                }
//            }
//            
//        }catch let error{
//            print(error.localizedDescription)
//
//        }
//        return infoStr
//    }
    
    //MARK: - End

    //MARK: - IBAction
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProductLotListView") as! ProductLotListViewController
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            controller.productDict = dict
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func quantityUpdateButtonPressed(_ sender: UIButton) {
        
        let quantity =   quantityUpdateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        
        if (quantity as NSString).intValue <= 0 {
            quantityUpdateView.isHidden = true
            self.deleteButtonPressed(sender)
           // Utility.showPopup(Title: App_Title, Message: "Enter quantity more than 0".localized(), InViewC: self)
            return
        }
        
        let createNew = defaults.bool(forKey: "MIS_create_new")
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary, !createNew {
            if let maxquantity = dict["maxquantity"] as? Int, (quantity as NSString).intValue > maxquantity {
                Utility.showPopup(Title: App_Title, Message: "Maximum allowed quantity is \(maxquantity) as it is taken in the items of the selected purchase order.".localized(), InViewC: self)
                return
            }
        }
        
        if (quantity as NSString).intValue > 0 {
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                if let id = dict["id"] {
                    let predicate = NSPredicate(format:"id='\(id)'")
                    do{
                        let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
                        if let obj = serial_obj.first {
                            
                            obj.quantity = Int16(quantity)!
                            
                            PersistenceService.saveContext()
                            Utility.showAlertWithPopAction(Title: Success_Title, Message: "quantity update".localized(), InViewC: self, isPop: false, isPopToRoot: false)
                            
                            setupList()
                            quantityUpdateView.isHidden = true
                        }
                    }catch let error{
                        print(error.localizedDescription)
                        
                    }
                }
            }
        }
        
    }
    

    
    @IBAction func cancelQuantityUpdateButtonPressed(_ sender: UIButton) {
        quantityUpdateView.isHidden = true
    }
    
    
    @IBAction func addProductButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddProductView") as! AddProductViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            if let dict = self.itemsList![sender.tag] as? NSDictionary {
                self.removeProduct(data: dict)
                self.checkingLineItemAggregationAndRemove(container_content: dict as! [String : Any])
            }
        })
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        
       
    }
    
    
    @IBAction func productQuantityUpdateButtonPressed(_ sender: UIButton) {
        
        if let dict = self.itemsList![sender.tag] as? NSDictionary {
            let prvQuan = dict["quantity"] as! Int16
            quantityUpdateTextField.text = "\(prvQuan)"
            quantityUpdateButton.tag = sender.tag
        }
        
        quantityUpdateView.isHidden = false
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
//
//            if productCount == 0 {
//                Utility.showPopup(Title: App_Title, Message: "Line item must be filled up before proceed.".localized(), InViewC: self)
//                return
//            }
//
//            if allProductInfoDone() == false {
//                Utility.showPopup(Title: App_Title, Message: "Enter all Products Lot Info.".localized(), InViewC: self)
//                return
//            }
        
        //,,,sb12
        /*
        if isOnlyLotBasedProduct {
            defaults.set(true, forKey: "MIS_4thStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            defaults.set(true, forKey: "MIS_3rdStep")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAggregationView") as! MISAggregationViewController
            controller.lineitemArr = itemsList
            if ((itemsList?.isEmpty) == nil){
            if (defaults.object(forKey: "lineItemCheck") != nil){
                if ((defaults.object(forKey: "lineItemCheck")) as! Int == 1) {
                    controller.isfromLineitemNextClick = true
                }else{
                    controller.isfromLineitemNextClick = false
                    }
                }
            }
            self.navigationController?.pushViewController(controller, animated: false)
        }
        */
        
        let createNew = defaults.bool(forKey: "MIS_create_new")
        if createNew {
            //Create a Purchase Order based from the Shipment
            
            if isOnlyLotBasedProduct {
                defaults.set(true, forKey: "MIS_4thStep")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }else{
                defaults.set(true, forKey: "MIS_3rdStep")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAggregationView") as! MISAggregationViewController
                controller.lineitemArr = itemsList
                if ((itemsList?.isEmpty) == nil){
                if (defaults.object(forKey: "lineItemCheck") != nil){
                    if ((defaults.object(forKey: "lineItemCheck")) as! Int == 1) {
                        controller.isfromLineitemNextClick = true
                    }else{
                        controller.isfromLineitemNextClick = false
                        }
                    }
                }
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
        else {
            //Select an existing Purchase Order
            
            //Check Info.Filled No Or Yes
            if allProductInfoDone() == false {
                Utility.showPopup(Title: App_Title, Message: "Enter all Products Lot Info.".localized(), InViewC: self)
                return
            }
            else {
                defaults.set(true, forKey: "MIS_3rdStep")
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISAggregationView") as! MISAggregationViewController
                controller.lineitemArr = itemsList
                if ((itemsList?.isEmpty) == nil){
                if (defaults.object(forKey: "lineItemCheck") != nil){
                    if ((defaults.object(forKey: "lineItemCheck")) as! Int == 1) {
                        controller.isfromLineitemNextClick = true
                    }else{
                        controller.isfromLineitemNextClick = false
                        }
                    }
                }
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
        //,,,sb12
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISPurchaseOrderViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderView") as! MISPurchaseOrderViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: MISShipmentDetailsViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISShipmentDetailsView") as! MISShipmentDetailsViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 4 {
            nextButtonPressed(UIButton())
        }else if sender.tag == 5 {
            //,,,sb12
            /*
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
            self.navigationController?.pushViewController(controller, animated: false)
            */
            
            let createNew = defaults.bool(forKey: "MIS_create_new")
            if createNew {
                //Create a Purchase Order based from the Shipment

                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                self.navigationController?.pushViewController(controller, animated: false)
            }
            else {
                //Select an existing Purchase Order
                
                //Check Info.Filled No Or Yes
                if allProductInfoDone() == false {
                    Utility.showPopup(Title: App_Title, Message: "Enter all Products Lot Info.".localized(), InViewC: self)
                    return
                }
                else {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISConfirmView") as! MISConfirmViewController
                    self.navigationController?.pushViewController(controller, animated: false)
                }
            }
            //,,,sb12
        }
    }
    @IBAction func checkUncheckPressed(_sender:UIButton){
        _sender.isSelected = !_sender.isSelected
        defaults.setValue(_sender.isSelected, forKey: "lineItemCheck")
    }
    
    //MARK: - End
    
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - End
    
    
    

}


//MARK: - Tableview Delegate and Datasource
extension MISLineItemViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "MISLineProductListCell") as! MISLineProductListCell
        
        cell.customView.setRoundCorner(cornerRadious: 10)
        
        if let dict = self.itemsList![indexPath.row] as? NSDictionary {
            
            var dataStr = ""
            if let txt = dict["product_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.productName.text = dataStr
            
            dataStr = ""
            if let txt = dict["gtin14"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            cell.gtinLabel.text = dataStr
            
            dataStr = ""
            if let txt = dict["quantity"] as? NSNumber{
                dataStr = "\(txt)"
            }
            cell.quantityLabel.text = dataStr
            
        
            if let id = dict["id"] as? NSNumber, let quantity = dict["quantity"] as? NSNumber {
                let info = getInfoFilledValue(Id: id, totalQuantity: quantity)
                cell.infoFilledValueLabel.text = info
            }
        }
        
        cell.updateQuantityButton.tag = indexPath.row
        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        
        return cell
    }
}
//MARK: - End



//MARK: - Tableview Cell
class MISLineProductListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var gtinLabel: UILabel!
    @IBOutlet weak var infoFilledValueLabel: UILabel!
    
    
    @IBOutlet weak var updateQuantityButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
//MARK: - End


