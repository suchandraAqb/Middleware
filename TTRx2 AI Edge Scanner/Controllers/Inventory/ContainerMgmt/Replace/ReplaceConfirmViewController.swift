//
//  ReplaceConfirmViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 03/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReplaceConfirmViewController: BaseViewController,ConfirmationViewDelegate {
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    //MARK: - End
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
    
    @IBOutlet weak var uniqueSerialLabel: UILabel!
    @IBOutlet weak var gsiidLabel: UILabel!
    @IBOutlet weak var containerTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageAreaLabel: UILabel!
    @IBOutlet weak var storageShelfLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
    
    @IBOutlet weak var destinationContainerView: UIView!
    @IBOutlet weak var viewContainerDetailsButton: UIButton!
    @IBOutlet weak var destinationContainerSerialLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var disPatchGroup = DispatchGroup()
    var containerDetailsDict = [String:Any]()
    
    var sourceSerial:String = ""
    var destinationSerial:String = ""

    //MARK: - View Life Cysle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.size.height/2.0)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        destinationContainerView.layer.cornerRadius = 15.0
        destinationContainerView.clipsToBounds = true
        
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        viewContainerDetailsButton.setRoundCorner(cornerRadious: viewContainerDetailsButton.frame.size.height/2.0)
        populateContainerDetails()
        populateDestinationView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup_stepview()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func populateDestinationView(){
        destinationContainerSerialLabel.text = self.destinationSerial
    }
    func setup_stepview(){
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = true
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        
        step3Button.isUserInteractionEnabled = false
        step3Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        
    }
    
    func populateContainerDetails() {
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
    //MARK: - End
    
    //MARK: - Call Api
    func replaceContainerContainer(){
        let appendStr = "SERIAL/\(sourceSerial)/replace"
        
        let requestParam = NSMutableDictionary()
        requestParam.setValue("SERIAL", forKey: "destination_container_id_type")
        requestParam.setValue(destinationSerial, forKey: "destination_container_identifier")
        
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "ContainersDetails", serviceParam: requestParam, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    let responseDict: NSDictionary = responseData as! NSDictionary
                    if let _ = responseDict["task_queue_uuid"] as? String{
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func viewContainerDetailsButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerDetailsViewController") as! ContainerDetailsViewController
        controller.serialNumber = destinationSerial
        controller.detailsViewFor = "Replace"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Replace Container".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to confirm Replace Container".localized()
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: UIButton) {
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AdjustmentViewItemsView") as! AdjustmentViewItemsViewController
        self.navigationController?.pushViewController(controller, animated: true)
       
    }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReplaceFirstViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceFirstView") as! ReplaceFirstViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
        }else if sender.tag == 2 {
            guard let controllers = self.navigationController?.viewControllers else { return }
            for  controller in controllers {
                
                if controller.isKind(of: ReplaceSecondViewController.self){
                    self.navigationController?.popToViewController(controller, animated: false)
                    return
                }
                
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceSecondView") as! ReplaceSecondViewController
            self.navigationController?.pushViewController(controller, animated: false)
            
            
        }
        
        
    }
    //MARK: - End
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        replaceContainerContainer()
    }
    func cancelConfirmation() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - End
    

    

}

