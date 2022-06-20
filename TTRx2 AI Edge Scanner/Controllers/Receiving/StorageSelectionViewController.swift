//
//  StorageSelectionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 30/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class StorageSelectionViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSelectionView: UIView!
    @IBOutlet weak var storageLabel: UILabel!
    
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfSelectionView: UIView!
    @IBOutlet weak var shelfLabel: UILabel!
    
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
    
    var isStorageSelected:Bool!
    var isShelfSelected:Bool!
    var storageAreas:Array<Any>?
    var shelfsArray:Array<Any>?
    var storage_location_uuid:String?
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStorageSelected = false
        isShelfSelected = false
        sectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
       
        
        if let shipmentData = defaults.object(forKey: ttrShipmentDetails){
            do{
                let shipmentDict:NSDictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(shipmentData as! Data) as! NSDictionary
                
                if let uuid:String = shipmentDict["location_uuid"] as? String{
                    storage_location_uuid = uuid
                }
                
                let allLocations = UserInfosModel.getLocations()
                if allLocations != nil{
                    if let location_uuid = shipmentDict["location_uuid"] as? String{
                                       
                        if let locationData = allLocations![location_uuid] as? NSDictionary{
                            
                            if let sa = locationData["sa"] as? Array<Any>, !sa.isEmpty{
                                storageAreas = sa
                            }else{
                                
                                if let sa_count = locationData["sa_count"]as? Int {
                                    
                                    if sa_count > 0 {
                                        let userinfo = UserInfosModel.UserInfoShared
                                        self.showSpinner(onView: self.view)
                                        userinfo.getStorageAreasOfALocation(location_uuid: location_uuid, ServiceCompletion:{ (isDone:Bool? , sa:Array<Any>?) in
                                           self.removeSpinner()
                                            
                                            if sa != nil && !(sa?.isEmpty ?? false){
                                                self.storageAreas = sa
                                            }
                                            
                                        })
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
               
                
             }catch{
                print("Shipment Data Not Found")
            }
        }
        
         populateDefaultStorageData()
        
        
        //TODO: - Test Sample Storage
       /* if let path = Bundle.main.path(forResource: "storage_areas", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? NSDictionary{
                       storageAreas = jsonResult
                  }
              } catch {
                   print("JSON parsing Error")
              }
        }*/
        //TODO: - End
        
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           setup_stepview()
           
    }
    //MARK: - End
    
    //MARK: - Private Method
    func populateDefaultStorageData(){
        
        var tempStorageDict:NSDictionary?
        
        if let storageDict = Utility.getObjectFromDefauls(key: "selected_storage") as? NSDictionary{
                tempStorageDict = storageDict
                if let uuid = storageDict["uuid"] as? String {
                    storageLabel.accessibilityHint = uuid
                    getShelfList(storageAreaUUID: uuid)
                }
                
                if let name = storageDict["name"] as? String {
                    storageLabel.text = name
                }
                
                isStorageSelected = true
             
            
        }else{
            if storageAreas?.count ?? 0 > 0 {
                let button = UIButton()
                button.tag = 1
                selecteditem(data: (storageAreas?.first as! NSDictionary), sender: button)
            }
        }
        
        
        
        
        if let shelfDict = Utility.getObjectFromDefauls(key: "selected_shelf") as? NSDictionary {
            
                if let uuid = shelfDict["storage_shelf_uuid"] as? String {
                    shelfLabel.accessibilityHint = uuid
                }
                
                if let name = shelfDict["name"] as? String {
                    shelfLabel.text = name
                }
                
                Utility.saveObjectTodefaults(key: "selected_shelf", dataObject: shelfDict)
                
                shelfView.isHidden = false
                isShelfSelected = true
                
             
        }else{
            if tempStorageDict != nil {
                let button = UIButton()
                button.tag = 1
                selecteditem(data:tempStorageDict!, sender: button)
            }
        }
        
        
        
    }
    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "rec_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "rec_2ndStep")
        let isThirdStepCompleted = defaults.bool(forKey: "rec_3rdStep")
        let isFourthStepCompleted = defaults.bool(forKey: "rec_4thStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step3Button.isUserInteractionEnabled = true
        step4Button.isUserInteractionEnabled = false
        step5Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step4Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step5Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step4BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted && isFourthStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step4Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step4Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step3BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            step5Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted && isThirdStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            step4Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted && isSecondStepCompleted{
            
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            //step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            //step4Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step5Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
    }
    func getShelfList(storageAreaUUID:String){
        
        let appendStr:String! = (storage_location_uuid ?? "") as String + "/storage_areas/" + storageAreaUUID + "/storage_shelfs"
        
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: "GetShelfList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                        let responseDict: NSDictionary = responseData as! NSDictionary
                    
                        if let list = responseDict["data"] as? Array<[String : Any]>{
                            self.shelfsArray = list
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
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if !storageView.isHidden && !isStorageSelected {
            Utility.showPopup(Title: App_Title, Message: "Please select a storage area".localized(), InViewC: self)
            return
        }else if !shelfView.isHidden && !isShelfSelected {
            Utility.showPopup(Title: App_Title, Message: "Please select a shelf".localized(), InViewC: self)
            return
        }
        
        
        defaults.set(true, forKey: "rec_4thStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func storageLocationButtonPressed(_ sender: UIButton) {
        if storageAreas == nil {
           return
        }
        sender.tag = 1
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = storageAreas as! Array<[String:Any]>
        controller.delegate = self
        controller.type = "Storage Area".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
          
    }
    
    @IBAction func shelfButtonPressed(_ sender: UIButton) {
        if shelfsArray == nil || shelfsArray?.count == 0 {
            getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
            return
        }
        sender.tag = 2
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shelfsArray as! Array<[String:Any]>
        controller.type = "Storage Shelf".localized()
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
          
    }
    
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
      if sender.tag == 1 {
         guard let controllers = self.navigationController?.viewControllers else { return }
         for  controller in controllers {
             
             if controller.isKind(of: ShipmentDetailsViewController.self){
                 self.navigationController?.popToViewController(controller, animated: false)
                 return
             }
             
         }
         
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "ShipmentDetailsView") as! ShipmentDetailsViewController
         self.navigationController?.pushViewController(controller, animated: false)
         
      }else if sender.tag == 2 {
        
        guard let controllers = self.navigationController?.viewControllers else { return }
        for  controller in controllers {
            
            if controller.isKind(of: PurchaseOrderVC.self){
                self.navigationController?.popToViewController(controller, animated: false)
                return
            }
            
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseOrderVC") as! PurchaseOrderVC
        self.navigationController?.pushViewController(controller, animated: false)
        
        
     }else if sender.tag == 3 {
         guard let controllers = self.navigationController?.viewControllers else { return }
         for  controller in controllers {
             
             if controller.isKind(of: SerialVerificationViewController.self){
                 self.navigationController?.popToViewController(controller, animated: false)
                 return
             }
             
         }
         
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialVerificationView") as! SerialVerificationViewController
         self.navigationController?.pushViewController(controller, animated: false)
         
         
      }else if sender.tag == 5 {
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingConfirmationView") as! ReceivingConfirmationViewController
          self.navigationController?.pushViewController(controller, animated: false)
      }
        
    }
    //MARK: - End
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        
        
    }
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        
        if sender != nil && sender?.tag ?? 0 == 1 {
            
            shelfView.isHidden = true
            shelfLabel.text = "Select Shelf".localized()
            shelfLabel.accessibilityHint = ""
            isShelfSelected = false
            defaults.removeObject(forKey: "selected_shelf")
            
            
            
            if let name = data["name"] as? String{
                storageLabel.text = name
                if let uuid = data["uuid"] as? String{
                    storageLabel.accessibilityHint = uuid
                }
                
               Utility.saveObjectTodefaults(key: "selected_storage", dataObject: data)
               isStorageSelected = true
            }
            
            let isShelf = data["is_have_shelf"] as! Bool
            
            if isShelf {
                shelfView.isHidden = false
                isShelfSelected = false
                getShelfList(storageAreaUUID: storageLabel.accessibilityHint ?? "")
            }
            
        }else if sender != nil && sender?.tag ?? 0 == 2 {
            
            if let name = data["name"] as? String{
                shelfLabel.text = name
                
                if let uuid = data["storage_shelf_uuid"] as? String {
                    shelfLabel.accessibilityHint = uuid
                    
                    Utility.saveObjectTodefaults(key: "selected_shelf", dataObject: data)
                   
                }
                
                isShelfSelected = true
                
            }
        }
    }
    //MARK: - End
    
    
    
    
    

    

}
