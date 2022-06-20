//
//  ReturnConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 16/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReturnConfirmationViewController: BaseViewController,ConfirmationViewDelegate {
    
    
    @IBOutlet weak var shipmentView: UIView!
    @IBOutlet weak var customerDetailsView: UIView!
    @IBOutlet weak var returnItemsView: UIView!
    @IBOutlet weak var toReturnedView: UIView!
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var orderDateTimeLabel: UILabel!
    @IBOutlet weak var shipmentDateLabel: UILabel!
    @IBOutlet weak var goodsConditionLabel: UILabel!
    @IBOutlet weak var scLabel: UILabel!
    @IBOutlet weak var smLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerUuidLabel: UILabel!
    @IBOutlet weak var toReturnItemLabel: UILabel!
    @IBOutlet weak var resalableCountLabel: UILabel!
    @IBOutlet weak var quarantineCountLabel: UILabel!
    @IBOutlet weak var notResalableCountLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var pendingItemsLabel: UILabel!
    
    
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step4Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step3BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step4Label: UILabel!
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotificationForRefreshVerificationSTatus), name: Notification.Name("Return_RefreshProducts"), object: nil)
        sectionView.roundTopCorners(cornerRadious: 40)
        setup_initialview()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
        populateData()
        populatePendingCount()
    }
    
    //MARK: - End
    
    //MARK: - Remove Observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - End
    
    //MARK: - Private Method
    
    func populatePendingCount(){
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return
        }
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Pending.rawValue))
            
            
            if !serial_obj.isEmpty{
                pendingItemsLabel.isHidden = false
                pendingItemsLabel.text = "\(serial_obj.count) " + "Item(s) is pending for verifications.".localized()
            }else{
                pendingItemsLabel.isHidden = true
                pendingItemsLabel.text = "0 " + "Item(s) is pending for verifications.".localized()
                
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
    }
    
    func isVerificationPending()->Bool{
        var isPending = true
        
        guard let return_uuid = defaults.object(forKey: "current_returnuuid") as? String , !return_uuid.isEmpty else {
            return isPending
        }
        
        
        
        do{
            
            let serial_obj = try PersistenceService.context.fetch(Return_Serials.fetchSerialWithStatusRequest(uuid: return_uuid, status: Return_Serials.Status.Pending.rawValue))
            
            
            if serial_obj.isEmpty{
                isPending = false
            }
            
            
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        return isPending
        
    }
    
    func populateData(){
        
        if let dataDict = Utility.getDictFromdefaults(key: "return_general_info") {
            
            if let txt =  dataDict["reception_date_label"] as? String, !txt.isEmpty {
                
                if let time =  dataDict["reception_time_label"] as? String, !time.isEmpty {
                    orderDateTimeLabel.text = "\(txt) \(time)"
                }
                
            }
            
            if let txt =  dataDict["shipment_date_label"] as? String, !txt.isEmpty{
                shipmentDateLabel.text = txt
            }
            
            if let txt =  dataDict["shipping_carrier__custom"] as? String, !txt.isEmpty{
                scLabel.text = txt
            }
            
            if let txt =  dataDict["shipping_method__custom"] as? String, !txt.isEmpty{
                smLabel.text = txt
            }
            
            if let txt =  dataDict["shipment_general_condition_label"] as? String, !txt.isEmpty{
                goodsConditionLabel.text = txt
            }
            
            
        }
        
        if let dataDict = Utility.getDictFromdefaults(key: "selected_outbound_shipment") {
            if let uuid:String = dataDict["shipment_uuid"] as? String{
                uuidLabel.text = uuid
            }
            
            if let name:String = dataDict["trading_partner_name"] as? String{
                customerNameLabel.text = name
            }
            
            if let uuid:String = dataDict["trading_partner_uuid"] as? String{
                customerUuidLabel.text = uuid
            }
        }
        
        
        let resalable = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Resalable.rawValue)
        resalableCountLabel.text = "\(resalable)"
        
        let quarantine = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Quarantine.rawValue)
        quarantineCountLabel.text = "\(quarantine)"
        
        let destruct = Utility.getProductConditionCountForReturn(condition: Return_Serials.Condition.Destruct.rawValue)
        notResalableCountLabel.text = "\(destruct)"
        
        populateReturnedLabel(product: "\(resalable+quarantine+destruct)")
        
        
        
    }
    func populateReturnedLabel(product:String?){
        
        let custAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 13.0)!]
        let productString = NSMutableAttributedString(string: "To be returned".localized() + " ", attributes: custAttributes)
        
        
        let custTypeAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "00AFEF"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 30.0)!]
        
        let productStr = NSAttributedString(string: product ?? "0", attributes: custTypeAttributes)
        
        
        productString.append(productStr)
        
        toReturnItemLabel.attributedText = productString
        
        
    }
    
    func setup_initialview(){
        shipmentView.setRoundCorner(cornerRadious: 10)
        customerDetailsView.setRoundCorner(cornerRadious: 10)
        returnItemsView.setRoundCorner(cornerRadious: 10)
        toReturnedView.setRoundCorner(cornerRadious: 5)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
    }
    func setup_stepview(){
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        
        
        step3Button.isUserInteractionEnabled = true
        step4Button.isUserInteractionEnabled = false
        step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        
        
    }
    
    func prepareReturnSaveRequestData(){
        let requestDict = NSMutableDictionary()
        
        requestDict.setValue("COMPLETE", forKey: "status")
        //requestDict.setValue(true, forKey: "is_close_rma")
        
        if let dataDict = Utility.getObjectFromDefauls(key: "selected_outbound_shipment") as? NSDictionary {
            
            if let uuid:String = dataDict["shipment_uuid"] as? String{
                requestDict.setValue(uuid, forKey: "shipment_uuid")
            }
            
            if let uuid:String = dataDict["trading_partner_uuid"] as? String{
                requestDict.setValue(uuid, forKey: "customer_uuid")
            }
            
        }
        
        if let dataDict = Utility.getDictFromdefaults(key: "return_general_info") {
            
            if let txt =  dataDict["reception_date"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "reception_date")
            }
            
            
            if let txt =  dataDict["reception_time"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "reception_time")
            }
            
            
            if let txt =  dataDict["shipment_date"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipment_date")
            }
            
            if let txt =  dataDict["tracking_number"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "tracking_number")
            }
            
            if let txt =  dataDict["shipping_carrier__preset_uuid"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_carrier__preset_uuid")
                
            }else if let txt =  dataDict["shipping_carrier__custom"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_carrier__custom")
            }
            
            if let txt =  dataDict["shipping_method__preset_uuid"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_method__preset_uuid")
                
            }else if let txt =  dataDict["shipping_method__custom"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipping_method__custom")
            }
            
            if let txt =  dataDict["shipment_general_condition"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "shipment_general_condition")
            }
            
            if let txt =  dataDict["notes"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "notes")
            }
            
        }
        
        if let dataDict = Utility.getDictFromdefaults(key: "return_summary_info") {
            
            if let txt =  dataDict["resalable_items__location_uuid"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "resalable_items__location_uuid")
            }
            
            
            if let txt =  dataDict["resalable_items__storage_area_uuid"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "resalable_items__storage_area_uuid")
            }
            
            if let txt =  dataDict["resalable_items__storage_shelf_uuid"] as? String, !txt.isEmpty {
                requestDict.setValue(txt, forKey: "resalable_items__storage_shelf_uuid")
            }
            
            if let txt =  dataDict["quarantine_reason__preset_uuid"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "quarantine_reason__preset_uuid")
                
            }else if let txt =  dataDict["quarantine_reason__custom"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "quarantine_reason__custom")
            }
            
            if let txt =  dataDict["destruction_reason__preset_uuid"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "destruction_reason__preset_uuid")
            }else if let txt =  dataDict["destruction_reason__custom"] as? String, !txt.isEmpty{
                requestDict.setValue(txt, forKey: "destruction_reason__custom")
            }
            
        }
        
        
        confirmReturn(requestData: requestDict)
        
        
    }
    
    func confirmReturn(requestData:NSMutableDictionary){
        
        var appendStr =  ""
        if let txt = defaults.object(forKey: "current_returnuuid") as? String{
            appendStr = "/\(txt)"
        }
        
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "InitiateReturn", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                    
                    if let _ = responseDict["uuid"] as? String {
                        Utility.removeReturnFromDB()
                        Utility.removeReturnLotDB()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Return process successful.".localized(), InViewC: self, isPop: true, isPopToRoot: true)
                    }
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else if let errorMsg = responseDict["message"] as? String{
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }
                        else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                        
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }
    }
    
    //MARK: - End
    //MARK: - IBAction
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnGeneralInfoViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnGeneralInfoView") as! ReturnGeneralInfoViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnSerialVerificationViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSerialVerificationView") as! ReturnSerialVerificationViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }else if sender.tag == 3 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReturnSummaryViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnSummaryView") as! ReturnSummaryViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
    }
    
    @IBAction func viewOutboundShipmentDetailsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "OutboundShipmentDetailsView") as! OutboundShipmentDetailsViewController
        controller.isFromConfirmation = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func viewAllProductSummaryButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnProductSummaryView") as! ReturnProductSummaryViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnCancelView") as! ReturnCancelViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        
        if isVerificationPending(){
            Utility.showPopup(Title: App_Title, Message: "Items verification is in process.".localized() , InViewC: self)
            return
        }
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want confirm Return?".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        prepareReturnSaveRequestData()
    }
    
    func cancelConfirmation() {
        
    }
    //MARK: - End
    
    //MARK: - Local Notification Receiver Method
    @objc func receiveNotificationForRefreshVerificationSTatus(_ notification: NSNotification) {
        // Take Action on Notification
        populatePendingCount()
    }
    
    //MARK: - End
    
    
    
}
