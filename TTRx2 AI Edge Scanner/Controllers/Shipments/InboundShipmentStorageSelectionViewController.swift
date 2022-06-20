//
//  InboundShipmentStorageSelectionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 29/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  InboundShipmentStorageSelectionDelegate: AnyObject {
    @objc optional func didSelectStorage(storage_uuid:String,shelf_uuid:String)
    @objc optional func shipmentUpdated()
}


class InboundShipmentStorageSelectionViewController: BaseViewController,SingleSelectDropdownDelegate {
    
    weak var delegate: InboundShipmentStorageSelectionDelegate?
    
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var storageSelectionView: UIView!
    @IBOutlet weak var storageLabel: UILabel!
    
    @IBOutlet weak var shelfView: UIView!
    @IBOutlet weak var shelfSelectionView: UIView!
    @IBOutlet weak var shelfLabel: UILabel!
    @IBOutlet weak var SaveButton: UIButton!
    
    
    var shipmentId = ""
    var isStorageSelected:Bool!
    var isShelfSelected:Bool!
    var storageAreas:Array<Any>?
    var shelfsArray:Array<Any>?
    var storage_location_uuid:String?
    
    
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isStorageSelected = false
        isShelfSelected = false
        sectionView.roundTopCorners(cornerRadious: 40)
        selectionContainer.setRoundCorner(cornerRadious: 10)
        SaveButton.setRoundCorner(cornerRadious: SaveButton.frame.size.height/2.0)
        storageSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        shelfSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        getShipmentDetails()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func storageLocationButtonPressed(_ sender: UIButton) {
        if storageAreas == nil {
            return
        }
        sender.tag = 1
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
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
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = shelfsArray as! Array<[String:Any]>
        controller.type = "Storage Shelf".localized()
        controller.delegate = self
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !storageView.isHidden && !isStorageSelected {
            Utility.showPopup(Title: App_Title, Message: "Please select a storage area".localized(), InViewC: self)
            return
        }else if !shelfView.isHidden && !isShelfSelected {
            Utility.showPopup(Title: App_Title, Message: "Please a select shelf".localized(), InViewC: self)
            return
        }
        
        let otherDetailsDict = NSMutableDictionary()
        if let txt = storageLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_area_uuid")
        }
        if let txt = shelfLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "storage_shelf_uuid")
        }
        setShipmentReceived(requestData: otherDetailsDict)




//        delegate?.didSelectStorage?(storage_uuid: storageLabel.accessibilityHint ?? "", shelf_uuid: shelfLabel.accessibilityHint ?? "")
//        self.navigationController?.popViewController(animated: false)
    }
    //MARK: - End
    
    
    //MARK: - Api Call
    func getShipmentDetails(){
        self.showSpinner(onView: self.view)
        let appendStr = "\(shipmentId)"
          Utility.GETServiceCall(type: "InboundShipmentDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    if let responseDict = responseData as? NSDictionary {
                        if let location_uuid:String = responseDict["location_uuid"] as? String{
                            self.getStorageAreaList(location_uuid: location_uuid)
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
    
    func setShipmentReceived(requestData:NSMutableDictionary){
        let appendStr = "Inbound/\(shipmentId)/set_shipment_verified"
        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "UpdateShipment", serviceParam: requestData, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    
                    if let _ = responseDict["uuid"] as? String {
                        self.delegate?.shipmentUpdated?()
                        Utility.showAlertWithPopAction(Title: Success_Title, Message: "Shipment Received Successfully".localized(), InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
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
    
    
    //MARK: - Private Method
    func populateDefaultStorageData(){
       if storageAreas?.count ?? 0 > 0 {
           let button = UIButton()
           button.tag = 1
           selecteditem(data: (storageAreas?.first as! NSDictionary), sender: button)
       }
    }
    
    func getStorageAreaList(location_uuid:String){
        storage_location_uuid = location_uuid
        let allLocations = UserInfosModel.getLocations()
        if allLocations != nil{
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
        populateDefaultStorageData()
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
            if let name = data["name"] as? String{
                storageLabel.text = name
                if let uuid = data["uuid"] as? String{
                    storageLabel.accessibilityHint = uuid
                }
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
                }
                isShelfSelected = true
            }
        }
    }
    //MARK: - End
    
}
