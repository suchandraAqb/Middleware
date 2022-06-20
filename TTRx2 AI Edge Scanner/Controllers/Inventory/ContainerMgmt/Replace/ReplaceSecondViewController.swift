//
//  ReplaceSecondViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 03/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ReplaceSecondViewController: BaseViewController {
    


    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var destinationContainerSerialLabel: UILabel!
    @IBOutlet weak var destinationContainerView: UIView!
    
    @IBOutlet weak var viewContainerDetailsButton: UIButton!
    
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
    
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    
    var containerDetailsDict = [String:Any]()
    var sourceSerial:String = ""
    var destinationSerial:String = ""
    
    //MARK: - Update Status Bar Style
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionView.roundTopCorners(cornerRadious: 40)
        cameraView.setRoundCorner(cornerRadious: 10)
        destinationContainerView.setRoundCorner(cornerRadious: 10)
        viewContainerDetailsButton.setRoundCorner(cornerRadious: viewContainerDetailsButton.frame.size.height/2.0)
        viewContainerDetailsButton.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let serial = defaults.object(forKey: "destination_serial") as? String {
            destinationSerial = serial
            populateDestinationView()
        }
        
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        setup_stepview()
    }
    //MARK: - End
    //MARK: - Private Method
    func populateDestinationView(){
        viewContainerDetailsButton.isHidden = true
        if destinationSerial != "" {
            viewContainerDetailsButton.isHidden = false
            destinationContainerSerialLabel.text = destinationSerial
        }
        
    }

    func setup_stepview(){
        
        let isFirstStepCompleted = defaults.bool(forKey: "replace_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "replace_2ndStep")
        
        step1Button.isUserInteractionEnabled = true
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        
        step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            //step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.isUserInteractionEnabled = true
            
            
        }else if isFirstStepCompleted {
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
            
        }
        
    }
    func getContainerSerial(code : String){
        if !code.isEmpty{
            let  appendStr = "?gs1_barcode=\(code)&is_include_inbound_shipment_informations=true" //"?gs1_barcode=*0101369120751100211000007*1720112910LOTB00002&is_include_suggested_inbound_shipments=true&is_include_inbound_shipment_informations=true"
                
            self.showSpinner(onView: self.view)
            let escapedString = appendStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            Utility.GETServiceCall(type: "GetIndividualProduct", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: escapedString) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        
                        let responseArray: NSArray = responseData as! NSArray
                        if responseArray.count > 0{
                            if let responseDict: NSDictionary = responseArray.firstObject as? NSDictionary{
                                if let container = responseDict["type"] as? String, container == "CONTAINER" {
                                    
                                    if let serial = responseDict["serial"] as? String, !serial.isEmpty{
                                        
                                        if serial != self.sourceSerial{
                                            self.destinationSerial = serial
                                            defaults.set(serial, forKey: "destination_serial")
                                            self.populateDestinationView()
                                                                                        
                                        }else{
                                            Utility.showPopup(Title: App_Title, Message: "Source and Destination container can't be same.".localized() , InViewC: self)
                                            
                                        }
                                        
                                    }
                                    
                                }else{
                                    Utility.showPopup(Title: App_Title, Message: "Container not found.".localized() , InViewC: self)
                                }
                            }
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                        }
                        print(Utility.json(from: [responseArray])!)
             
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
            
        }
        
    }
    //MARK: - End
    
    //MARK: - IBAction
    
    @IBAction func toggleSingleMultiScan(_ sender: UIButton) {
        sender.isSelected.toggle()
        defaults.set(sender.isSelected, forKey: "IsMultiScan")
        multiButton.isSelected = sender.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        //00AFEF
    }
    
    @IBAction func viewContainerDetailsButtonPressed(_ sender: UIButton) {
        if destinationSerial == "" {
            Utility.showPopup(Title: App_Title, Message: "Please scan Destination Container before proceed.".localized(), InViewC: self)
            return
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerDetailsViewController") as! ContainerDetailsViewController
        controller.serialNumber = destinationSerial
        controller.detailsViewFor = "Replace"
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
  
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
 }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
       
       if destinationSerial == "" {
            Utility.showPopup(Title: App_Title, Message: "Please scan Destination Container before proceed.".localized(), InViewC: self)
            return
        }
        
        defaults.set(true, forKey: "replace_2ndStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceConfirmView") as! ReplaceConfirmViewController
        controller.sourceSerial = self.sourceSerial
        controller.destinationSerial = self.destinationSerial
        controller.containerDetailsDict = self.containerDetailsDict
        self.navigationController?.pushViewController(controller, animated: false)
        
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
            
        }else if sender.tag == 3 {
            nextButtonPressed(UIButton())
        }
        
        
    }
    
    
    //MARK: - End
    
    
    
    
}

extension ReplaceSecondViewController : ScanViewControllerDelegate{
    func didScanCodeForReceive(codeDetails: [String : Any]) {
        print(codeDetails["scannedCode"] as Any)
        self.getContainerSerial(code: codeDetails["scannedCode"] as! String)
    }
}

extension ReplaceSecondViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceive(codeDetails: [String : Any]){
        print(codeDetails["scannedCode"] as Any)
        self.getContainerSerial(code: codeDetails["scannedCode"] as! String)
    }
}


