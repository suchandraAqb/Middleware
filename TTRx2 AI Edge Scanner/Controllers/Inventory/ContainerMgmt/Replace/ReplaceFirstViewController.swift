//
//  ReplaceFirstViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 03/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReplaceFirstViewController: BaseViewController {
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var viewItemsButton: UIButton!
        
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
    
    @IBOutlet weak var uniqueSerialLabel: UILabel!
    @IBOutlet weak var gsiidLabel: UILabel!
    @IBOutlet weak var containerTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var storageAreaLabel: UILabel!
    @IBOutlet weak var storageShelfLabel: UILabel!
    @IBOutlet weak var dispositionLabel: UILabel!
    @IBOutlet weak var businessStepLabel: UILabel!
    
    var disPatchGroup = DispatchGroup()
    var containerDetailsDict = [String:Any]()
    var serialNumber = ""

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        viewItemsButton.setRoundCorner(cornerRadious: viewItemsButton.frame.size.height/2.0)
        removeReplaceDefaults()
        populateContainerDetails()
        self.disPatchGroup.notify(queue: .main) {
            print("BothApi is called")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //populateGeneralInfo()
        setup_stepview()
    }
    //MARK: - End
    
    //MARK: - Private Method
    func removeReplaceDefaults(){
        defaults.removeObject(forKey: "replace_1stStep")
        defaults.removeObject(forKey: "replace_2ndStep")
        defaults.removeObject(forKey: "destination_serial")
        
    }
    
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "replace_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "replace_2ndStep")
        
        
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
            
        }else{
            getContainerDetails()
        }
    }
    
    //MARK: - End
    
    //MARK: Call Api
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
                        self.populateContainerDetails()
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
    
    
    //MARK: - IBAction
    
    @IBAction func replaceBackButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        defaults.set(true, forKey: "replace_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceSecondView") as! ReplaceSecondViewController
        controller.sourceSerial = self.serialNumber
        controller.containerDetailsDict = self.containerDetailsDict
        self.navigationController?.pushViewController(controller, animated: false)
    }
        
       
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
      if sender.tag == 2 {
          nextButtonPressed(UIButton())
          
      }else if sender.tag == 3 {
         
         let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceConfirmView") as! ReplaceConfirmViewController
        controller.sourceSerial = self.serialNumber
        controller.destinationSerial = (defaults.object(forKey: "destination_serial") as? String) ?? ""
        controller.containerDetailsDict = self.containerDetailsDict
         self.navigationController?.pushViewController(controller, animated: false)
          
      }
        
    }
    
    @IBAction func viewItemButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsListViewController") as! ItemsListViewController
        controller.serialNumber = serialNumber
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - End
    
    

    

}
