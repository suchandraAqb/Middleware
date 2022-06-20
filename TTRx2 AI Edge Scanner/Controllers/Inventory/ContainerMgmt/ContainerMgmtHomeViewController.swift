//
//  ContainerMgmtHomeViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 17/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ContainerMgmtHomeViewController: BaseViewController {
    
    @IBOutlet var roundedView:[UIView]!
    @IBOutlet var sectionTitleLabels:[UILabel]!
    var currentSelectedActionButton = UIButton()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
        
        for lbl in sectionTitleLabels {
            
            if lbl.tag == 1 {
                populateLabelView(str1: "Container List".localized(), str2: "Looks into containers".localized(), label: lbl)
            }else if lbl.tag == 2 {
                populateLabelView(str1: "View Container".localized(), str2: "View the content of a specific container, from it’s Unique Serial. From there, you can add and/or remove content".localized(), label: lbl)
            }else if lbl.tag == 3 {
                populateLabelView(str1: "Replace a container".localized(), str2: "Replace existing container(s)".localized(), label: lbl)
            }else if lbl.tag == 4 {
                populateLabelView(str1: "Generate and commission container".localized(), str2: "Generate Serial Numbers for new Containers".localized(), label: lbl)
            }else if lbl.tag == 5 {
                populateLabelView(str1: "Delete container".localized(), str2: "Delete an existing container, from it’s Unique Serial.".localized(), label: lbl)
            }
        }
    }
    //MARK:- End
    //MARK:- Custom Methods
    func populateLabelView(str1:String,str2:String,label:UILabel){
        
        let firstAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "072144"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 16.0)!]
        
        let firstStr = NSMutableAttributedString(string: str1, attributes: firstAttributes)
        
        let secondAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: Utility.hexStringToUIColor(hex: "719898"),
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 12.0)!]
        
        let secondStr = NSAttributedString(string: "\n\(str2)", attributes: secondAttributes)
        
        
        firstStr.append(secondStr)
        label.attributedText = firstStr
            
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
                                        self.moveToViewContainer(serial)
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
    func moveToViewContainer(_ serial:String){
        
        if currentSelectedActionButton.tag == 3{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReplaceFirstView") as! ReplaceFirstViewController
            controller.serialNumber = serial
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerDetailsViewController") as! ContainerDetailsViewController
        controller.serialNumber = serial        
        if currentSelectedActionButton.tag == 5{
            controller.detailsViewFor = "Delete"
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    //MARK:- End
    //MARK:- IBAction
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        currentSelectedActionButton =  sender
        if sender.tag == 1 {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerListView") as! ContainerListViewController
            self.navigationController?.pushViewController(controller, animated: true)
            
        }else if sender.tag == 2 ||  sender.tag == 5 ||  sender.tag == 3{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerScanView") as! ContainerScanViewController
            controller.delegate = self
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }else if sender.tag == 4 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommisionSerialsListView") as! CommisionSerialsListViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
   
    
    
    //MARK:- End
    
}

extension ContainerMgmtHomeViewController:ContainerScanViewDelegate{
    func didClickOnCamera(){
        DispatchQueue.main.async{
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
}

extension ContainerMgmtHomeViewController : ScanViewControllerDelegate{
    func didScanCodeForReceive(codeDetails: [String : Any]) {
        print(codeDetails["scannedCode"] as Any)
        self.getContainerSerial(code: codeDetails["scannedCode"] as! String)
    }
}

extension ContainerMgmtHomeViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceive(codeDetails: [String : Any]){
        print(codeDetails["scannedCode"] as Any)
        self.getContainerSerial(code: codeDetails["scannedCode"] as! String)
    }
}
