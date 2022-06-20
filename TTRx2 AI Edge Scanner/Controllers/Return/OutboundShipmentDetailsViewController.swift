//
//  OutboundShipmentDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 09/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class OutboundShipmentDetailsViewController: BaseViewController,ConfirmationViewDelegate {
    
    @IBOutlet weak var viewShipmentItemsButton: UIButton!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var customerDetailsView: UIView!
    @IBOutlet weak var scanAgainView: UIView!
    @IBOutlet weak var udidValueLabel: UILabel!
    @IBOutlet weak var etaValueLabel: UILabel!
    @IBOutlet weak var poValueLabel: UILabel!
    @IBOutlet weak var shipDateValueLabel: UILabel!
    @IBOutlet weak var deliveryDateValueLabel: UILabel!
    @IBOutlet weak var cOrderIdValueLabel: UILabel!
    @IBOutlet weak var invoiceValueLabel: UILabel!
    @IBOutlet weak var orderValueLabel: UILabel!
    @IBOutlet weak var releaseValueLabel: UILabel!
    @IBOutlet weak var tradingPartnerNameLabel: UILabel!
    @IBOutlet weak var tradingPartnerUUIDLabel: UILabel!
    
    var shipmentBarcode:String?
    var returnUuid:String?
    var isFromConfirmation:Bool?
    var outboundShipment:NSDictionary?
    var shipmentuuid:String?
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // shipmentBarcode = "urn:epc:id:sgtin:0834913.031240.015322133622380" // f88c1515-9262-4f60-b30d-23078b94e743
        sectionView.roundTopCorners(cornerRadious: 40)
        viewShipmentItemsButton.setRoundCorner(cornerRadious: viewShipmentItemsButton.frame.size.height/2.0)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        customerDetailsView.layer.cornerRadius = 15.0
        customerDetailsView.clipsToBounds = true
        
        if isFromConfirmation != nil && isFromConfirmation!{
            tickButton.isHidden = true
            scanAgainView.isHidden = true
            if let dataDict = Utility.getObjectFromDefauls(key: "selected_outbound_shipment") as? NSDictionary {
                populateDetails(dataDict: dataDict)
            }
        }else{
            getShipmentDetails()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - End
    
    //MARK: - IBAction
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to proceed with this shipment?".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func scanAgainButtonsPressed(_ sender: UIButton) {
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
        //self.delegate?.willScanAgain()
    }
    
    @IBAction func shipmentViewItemsButtonPressed(_ sender: UIButton){
        if self.shipmentuuid != nil {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnOutboundShipmentItemsView") as! ReturnOutboundShipmentItemsViewController
            controller.shipmentId = shipmentuuid!
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "Shipment UUID not found.".localized(), InViewC: self)
        }
    }
    //MARK: - End
    
    //MARK: - Private Method
    func getShipmentDetails(){
        if (self.outboundShipment != nil){
            self.populateDetails(dataDict: self.outboundShipment)
        }
        /*
         var requestDict = [String:Any]()
         requestDict["source_type"] = "PRODUCT_SERIAL"
         requestDict["serial_type"] = "GS1_URN"
         requestDict["value"] = shipmentBarcode ?? ""
         
         
         self.showSpinner(onView: self.view)
         Utility.POSTServiceCall(type: "InitiateReturn", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
         DispatchQueue.main.async{
         self.removeSpinner()
         if isDone! {
         
         let responseDict: NSDictionary = responseData as! NSDictionary
         
         if let uuid = responseDict["uuid"] as? String{
         self.returnUuid = uuid
         
         if let source_shipment = responseDict["source_shipment"] as? NSDictionary {
         self.outboundShipment = source_shipment
         self.populateDetails(dataDict: source_shipment)
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
         */
        
    }
    
    func getReturnSession(){
        
        let appendStr = "/\(self.returnUuid!)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "InitiateReturn", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    let _: NSDictionary = responseData as! NSDictionary
                    self.moveToReturnSteps()
                    
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
    
    func populateDetails(dataDict:NSDictionary?){
        
        if dataDict != nil{
            
            let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let shipDate:String = dataDict!["shipment_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: shipDate){
                    shipDateValueLabel.text = formattedDate
                }
            }
            
            
            if let ship_delivery_date:String = dataDict!["order_date"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: ship_delivery_date){
                    deliveryDateValueLabel.text = formattedDate
                }
            }
            
            if let uuid:String = dataDict!["shipment_uuid"] as? String{
                udidValueLabel.text = uuid
                shipmentuuid = uuid
            }
            
            if let custom_order_id:String = dataDict!["custom_order_id"] as? String{
                etaValueLabel.text = custom_order_id
            }
            
            if let po:String = dataDict!["po_number"] as? String{
                poValueLabel.text = po
            }
            
            
            if let interRef:String = dataDict!["internal_ref_num"] as? String{
                cOrderIdValueLabel.text = interRef
            }
            
            
            if let invoice_number:String = dataDict!["invoice_number"] as? String{
                invoiceValueLabel.text = invoice_number
            }
            
            if let order_number:String = dataDict!["order_number"] as? String{
                orderValueLabel.text = order_number
            }
            
            if let release_number:String = dataDict!["release_number"] as? String{
                releaseValueLabel.text = release_number
            }
            
            if let name:String = dataDict!["trading_partner_name"] as? String{
                tradingPartnerNameLabel.text = name
            }
            
            if let uuid:String = dataDict!["trading_partner_uuid"] as? String{
                tradingPartnerUUIDLabel.text = uuid
            }
            
        }
        
    }
    
    func moveToReturnSteps(){
        removeReturnDefaults()
        updateReturnToDB()
        defaults.set(self.returnUuid!, forKey: "current_returnuuid")
        Utility.saveObjectTodefaults(key: "selected_outbound_shipment", dataObject: outboundShipment!)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReturnGeneralInfoView") as! ReturnGeneralInfoViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func removeReturnDefaults(){
        defaults.removeObject(forKey: "current_returnuuid")
        defaults.removeObject(forKey: "return_1stStep")
        defaults.removeObject(forKey: "return_2ndStep")
        defaults.removeObject(forKey: "return_3rdStep")
        defaults.removeObject(forKey: "selected_outbound_shipment")
        defaults.removeObject(forKey: "return_general_info")
        defaults.removeObject(forKey: "return_summary_info")
        
    }
    
    func updateReturnToDB(){
        
        do{
            
            let return_obj = try PersistenceService.context.fetch(Return.fetchReturnRequest(serial: self.returnUuid!))
            print("Existing Return Fetched")
            
            
            if !return_obj.isEmpty{
                //print(return_obj.first!.uuid!)
                print("Active Return Existt")
                return_obj.first!.is_active = true
                
            }else{
                let return_obj = Return(context: PersistenceService.context)
                return_obj.uuid = self.returnUuid!
                return_obj.is_active = true
                
            }
            PersistenceService.saveContext()
            
        }catch let error {
            print(error.localizedDescription)
            
        }
    }
    
    
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        if self.returnUuid != nil {
            getReturnSession()
        }else{
            Utility.showPopup(Title: App_Title, Message: "Return UUID not found.".localized(), InViewC: self)
        }
        
    }
    
    func cancelConfirmation() {
        
    }
    //MARK: - End
}
