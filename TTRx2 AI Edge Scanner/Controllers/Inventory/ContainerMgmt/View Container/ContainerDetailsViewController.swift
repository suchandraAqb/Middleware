//
//  ContainerDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 19/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ContainerDetailsViewDelegate: class {
    func doneDelete()
}

class ContainerDetailsViewController: BaseViewController,ConfirmationViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var replaceButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var uniqueSerialLabel: UILabel!
    @IBOutlet weak var gsiidLabel: UILabel!
    @IBOutlet weak var containerTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageAreaLabel: UILabel!
    @IBOutlet weak var storageShelfLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
    
    var serialNumber = ""
    var disPatchGroup = DispatchGroup()
    var containerDetailsDict = [String:Any]()
    var fromList:Bool = false
    
    weak var delegate: ContainerDetailsViewDelegate?
    
    var detailsViewFor:String = "Normal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        
        deleteButton.setRoundCorner(cornerRadious: deleteButton.frame.size.height/2.0)
        replaceButton.setRoundCorner(cornerRadious: replaceButton.frame.size.height/2.0)
        getContainerDetails()
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
        }
        
        deleteButton.isHidden = true
        replaceButton.isHidden = true
        editButton.isHidden = true
        if detailsViewFor == "Normal" {
            deleteButton.isHidden = false
            replaceButton.isHidden = false
            editButton.isHidden = false
        }else if detailsViewFor == "Delete"{
            deleteButton.isHidden = false
        }else if detailsViewFor == "Replace"{
            deleteButton.isHidden = true
            replaceButton.isHidden = true
            editButton.isHidden = true
            backButton.setTitle("Destination Container".localized(), for: .normal)
        }

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.object(forKey: "InventoryVerifiedArray") != nil){
            defaults.removeObject(forKey: "InventoryVerifiedArray")
        }
        if (defaults.object(forKey: "ScanFailedItemsArray") != nil){
            defaults.removeObject(forKey: "ScanFailedItemsArray")
        }
    }
    
    //MARK: - Action
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsListViewController") as! ItemsListViewController
        controller.serialNumber = serialNumber
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func deleteContainerButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to delete this Container?".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerEditView") as! ContainerEditViewController
        controller.serialNumber = serialNumber
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func replaceButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceFirstView") as! ReplaceFirstViewController
        controller.containerDetailsDict = self.containerDetailsDict
        controller.serialNumber = self.serialNumber
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: End
    
    // MARK Call Api
    func getContainerDetails() {
        print("call Api")
        let url = "SERIAL/\(serialNumber)?_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ContainersDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        self.containerDetailsDict = responseDict
                        self.populateDtails()
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
    
    func ContainerIsEmpty() {
        let url = "SERIAL/\(serialNumber)/empty?_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        self.disPatchGroup.enter()
        Utility.GETServiceCall(type: "ContainersDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.disPatchGroup.leave()
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let is_empty = responseDict["is_empty"] as? Bool{
                            if is_empty == true {
                                self.EmptyContainerDelete()
                            }else{
                                Utility.showPopup(Title: App_Title, Message: "This container cannot be deleted because it’s not empty".localized(), InViewC: self)
                                //self.ContainerDelete()
                            }
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
    
    func ContainerDelete() {
        let url = "SERIAL/\(serialNumber)/empty?_=\(Date().currentTimeMillis())"
        let requestParam = NSMutableDictionary()
        requestParam.setValue(true, forKey: "is_delete_container")
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ContainersDetails", serviceParam: requestParam, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["task_queue_uuid"] as? String{
                        self.afterDelete()
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
    
    func EmptyContainerDelete() {
        let url = "SERIAL/\(serialNumber)"
        self.showSpinner(onView: self.view)
        Utility.DELETEServiceCall(type: "ContainersDetails", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["task_queue_uuid"] as? String{
                        self.afterDelete()
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
    
    
    //MARK: End
    
    //MARK: Privae method
    func populateDtails() {
        if !containerDetailsDict.isEmpty {
            var dataStr = ""
            if let txt = containerDetailsDict["serial"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            uniqueSerialLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["gs1_unique_id"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            gsiidLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["packaging_type_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            containerTypeLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["location_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            locationLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["storage_area_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            storageAreaLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["storage_shelf_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            storageShelfLabel.text = dataStr
            
            dataStr = ""
            if let txt = containerDetailsDict["disposition_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            dispositionLabel.text = dataStr.capitalized
            
            dataStr = ""
            if let txt = containerDetailsDict["business_step_name"] as? String,!txt.isEmpty{
                dataStr = txt.capitalized
            }
            businessStepLabel.text = dataStr
            
        }
    }
    
    func afterDelete(){
        if fromList {
            self.delegate?.doneDelete()
            self.navigationController?.popViewController(animated: true)
        }else{
            self.delegate?.doneDelete()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //MARK: End
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        ContainerIsEmpty()
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End

}
