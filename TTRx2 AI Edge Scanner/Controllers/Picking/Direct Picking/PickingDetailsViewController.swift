//
//  PickingDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 24/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class PickingDetailsViewController: BaseViewController {
    
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var pickerNameLabel: UILabel!
    @IBOutlet weak var pickingStartDateLabel: UILabel!
    @IBOutlet weak var tradingPartnerNameLabel: UILabel!
    @IBOutlet weak var poLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var shipToLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var cancelPickingView:UIView!
    @IBOutlet weak var voidPickingButton:UIButton!
    @IBOutlet weak var postponeButton:UIButton!
    @IBOutlet weak var shipementUUID:UILabel!
    @IBOutlet var buttonViews:[UIView]!
    //MARK: - End
    
    var shipmentId:String?
    var isTodo = false

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        removePickingDefaults()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.setRoundCorner(cornerRadious: 10)
        voidPickingButton.setRoundCorner(cornerRadious: voidPickingButton.frame.size.height/2)
        postponeButton.setRoundCorner(cornerRadious: postponeButton.frame.size.height/2)
        cancelPickingView.roundTopCorners(cornerRadious: 40)
        for button in buttonViews{
            button.setRoundCorner(cornerRadious: 20)
        }
        cancelPickingView.isHidden = true
        getShipmentItemDetails()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func populateDetails(data:NSDictionary){
        
        Utility.saveObjectTodefaults(key: "DirectPickingData", dataObject: data)
        
        var uuid = ""
        if let txt = data["uuid"] as? String{
            uuid = txt
            defaults.set(txt, forKey: "SOPickingUUID")
        }
        shipementUUID.text = uuid

        if let txt = data["outbound_shipment_uuid"] as? String{
            defaults.set(txt, forKey: "outboundShipemntuuid")
        }
            
        if let txt = data["location_uuid"] as? String{
            defaults.set(txt, forKey: "SOPickingLocationUUID")
        }
        if let items = data["items"] as? NSArray,items.count>0 {
            if let arr = (items as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid") as? [String]{
                let soProductUuid = arr as NSArray
                defaults.setValue(soProductUuid, forKey: "SOProductUuid")
            }
        }
        
        var dataStr = ""
        if let txt = data["status"] as? String{
            dataStr = txt
            if txt == "TO_PICK" {
                dataStr = "To Do"
            }else if txt == "PICKING_IN_PROGRESS"{
                dataStr = "In Progress"
            }
            
        }
        statusLabel.text = dataStr
        pickerNameLabel.text = UserInfosModel.UserInfoShared.userName ?? ""
        
        dataStr = ""
        if let txt = data["created_on"] as? String{
            dataStr = txt
            if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.sZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: dataStr){
                dataStr = formattedDate
            }
        }
        createdDateLabel.text = dataStr
        pickingStartDateLabel.text = dataStr
        
        
        dataStr = ""
        if let txt = data["trading_partner_name"] as? String{
            dataStr = txt
        }
        
        tradingPartnerNameLabel.text = dataStr
        
        dataStr = ""
        if let txt = data["notes"] as? String{
            dataStr = txt
        }
        
        notesLabel.text = dataStr
        
        dataStr = ""
        if let txt = data["notes"] as? String{
            dataStr = txt
        }
        
        
        dataStr = ""
        if let shipping_data = data["shipping_address"] as? NSDictionary {
            
            var addressStr:String = ""
            
            if let line1:String = shipping_data["line1"] as? String , !line1.isEmpty{
                addressStr = addressStr + line1 + ", "
            }
            
            
            
            if let line2:String = shipping_data["line2"] as? String, !line2.isEmpty{
                addressStr = addressStr + line2 + "\n"
            }
            
            if let line3:String = shipping_data["line3"] as? String, !line3.isEmpty{
                addressStr = addressStr + line3 + "\n\n"
            }
            
            if let city:String = shipping_data["city"] as? String, !city.isEmpty{
                addressStr = addressStr + city + ", "
            }
            
            if let state_name:String = shipping_data["state_name"] as? String, !state_name.isEmpty{
                addressStr = addressStr + state_name + ", "
            }
            
            if let country_name:String = shipping_data["country_name"] as? String, !country_name.isEmpty{
                addressStr = addressStr + country_name
            }
            
            if let phone:String = shipping_data["phone"] as? String, !phone.isEmpty{
                addressStr =  addressStr + "\n" + phone
            }
            
            dataStr = addressStr
            
        }
        
        shipToLabel.text = dataStr
        
        if let transationArr = data["transactions"] as? NSArray{
            let transationDict = transationArr.firstObject as? NSDictionary
            
            dataStr = ""
            if let customOrder = transationDict!["custom_id"] as? String,!customOrder.isEmpty{
                dataStr = customOrder
            }
            if dataStr == "" {
                if let customuuid = transationDict!["uuid"] as? String,!customuuid.isEmpty{
                    dataStr = customuuid
                }
            }
            orderNoLabel.text = dataStr
            
            dataStr = ""
            if let poNumber = transationDict!["po_number"] as? String, !poNumber.isEmpty{
                dataStr = poNumber
            }
            poLabel.text = dataStr
        }
        

        
    }
    func getShipmentItemDetails(){
     
        let appendStr = "to_pick/\(shipmentId ?? "")?is_open_picking_session=\(isTodo)"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "ShipmentPickings", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                    if let responseDict = responseData as? NSDictionary {
                        
                        if let picking_data = responseDict["picking_data"] as? NSDictionary {
                            self.populateDetails(data: picking_data)

                        }
                       
                        if let items = responseDict["items_to_pick"] as? Array<Any> {
                            Utility.saveObjectTodefaults(key: "items_to_pick", dataObject: items)
                        }
                    }
                }else{
                   
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       
                    Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                       
                   }else{
                      
                    Utility.showAlertWithPopAction(Title: App_Title, Message: message, InViewC: self, isPop: true, isPopToRoot: false)
                   }
                       
                       
                }
                  
            }
        }
        
    }
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "picSO_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "picSO_2ndStep")
        
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
       if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
           
        }else if isFirstStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
        
        
    }
    func removePickingDefaults(){
        defaults.removeObject(forKey: "SOPickingUUID")
        defaults.removeObject(forKey: "SOPickingLocationUUID")
        defaults.removeObject(forKey: "picSO_1stStep")
        defaults.removeObject(forKey: "picSO_2ndStep")
        defaults.removeObject(forKey: "DirectPickingData")
        defaults.removeObject(forKey: "items_to_pick")
        
        defaults.removeObject(forKey: "DPSelectedShipmentStatus")
        defaults.removeObject(forKey: "DPSelectedStorageArea")
        defaults.removeObject(forKey: "DPSelectedStorageShelf")
        defaults.removeObject(forKey: "PickedItemCount")
    
        Utility.removeDPFromDB()
        
    }
    //MARK: - End
    //MARK: - IBAction
    @IBAction func pickingBackPressed(_ sender: UIButton) {
        if cancelPickingView.isHidden{
            cancelPickingView.isHidden = false
        }else{
            cancelPickingView.isHidden = true
        }
        /*
        let msg = "Your picking will be voided and picked items will be put back to the original location in the inventory. Continue?"
               
       let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
       let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: { (UIAlertAction) in
           
           self.navigationController?.popToRootViewController(animated: true)
           
           
       })
       let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
           
            Utility.void_SOpicking_session(controller: self)
            self.navigationController?.popToRootViewController(animated: true)
           
           
       })
       
       confirmAlert.addAction(action)
       confirmAlert.addAction(okAction)
       self.navigationController?.present(confirmAlert, animated: true, completion: nil)
         */
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        defaults.set(true, forKey: "picSO_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DirectPickingScanView") as! DirectPickingScanViewController
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
     
    
     @IBAction func stepButtonsPressed(_ sender: UIButton) {
       if sender.tag == 2 {
           nextButtonPressed(UIButton())
           
       }else if sender.tag == 3 {
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "DPConfirmationView") as! DPConfirmationViewController
         self.navigationController?.pushViewController(controller, animated: false)
           
       }
         
     }
    @IBAction func voidPickingButtonPressed(_ sender:UIButton){
        cancelPickingView.isHidden = true
        Utility.void_SOpicking_session(controller: self)
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func postponePickingButtonPressed(_ sender:UIButton){
        cancelPickingView.isHidden = true
        self.navigationController?.popToRootViewController(animated: true)

    }
    //MARK: - End
}


