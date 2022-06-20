//
//  CommissionSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 15/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class CommissionSerialsViewController: BaseViewController , ConfirmationViewDelegate{
    
    @IBOutlet weak var mainScrollView: UIView!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    
    
    var isEdit = false
    var commissionDetailsDict = [String:Any]()
    var allScannedSerials = [String]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.isHidden = true
        if isEdit {
            titleView.isHidden = false
            populateDetails()
        }
        
        sectionView.roundTopCorners(cornerRadious: 40)
        mainScrollView.setRoundCorner(cornerRadious: 15.0)
        titleView.setRoundCorner(cornerRadious: 10.0)
        cameraView.setRoundCorner(cornerRadious: 10.0)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        
        
    }
    //MARK: - End
    
    
    //MARK: - Private Method
    func populateDetails() {
        if !commissionDetailsDict.isEmpty {
            var dataStr = ""
            if let txt = commissionDetailsDict["product_name"] as? String,!txt.isEmpty{
                dataStr = txt
            }
            titleLabel.text = dataStr
            
            dataStr = ""
            if let txt = commissionDetailsDict["lot_number"] as? String,!txt.isEmpty{
                if commissionDetailsDict["type"]as? String == "SERIALIZED"{
                    dataStr = "SB: \(txt)"
                }else{
                    dataStr = "LB: \(txt)"
                }
            }
            lotLabel.text = dataStr
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
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
        if(defaults.bool(forKey: "IsMultiScan")){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
            controller.isForReceivingSerialVerificationScan = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
            controller.isForReceivingSerialVerificationScan = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
      }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if !allScannedSerials.isEmpty {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionSerialsConfirmView") as! CommissionSerialsConfirmViewController
            controller.scannedSerials = allScannedSerials
            controller.isEdit = isEdit
            controller.commissionDetailsDict = commissionDetailsDict
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please scan serial before proceed.".localized(), InViewC: self)
        }
        
    }
    
    @IBAction func viewScannedSerialsButtonPressed(_ sender: UIButton) {
        if !allScannedSerials.isEmpty {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "CommissionScannedSerialsView") as! CommissionScannedSerialsViewController
            controller.allScannedSerials = allScannedSerials
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: false)
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please scan serial before proceed.".localized(), InViewC: self)
        }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want to cancel".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
       
    
    //MARK: - End
    
    //MARK: - ConfirmationViewDelegate
       func doneButtonPressed() {
           
           
       }
       func cancelConfirmation() {
           self.navigationController?.popViewController(animated: true)
       }
       //MARK: - End

}

extension CommissionSerialsViewController : ScanViewControllerDelegate{
    func didScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
           Utility.showPopup(Title: Success_Title, Message: "Serial(s) Scanned Successfully.".localized() , InViewC: self)
        }
        self.allScannedSerials.append(contentsOf: scannedCode)
         
    }
}

extension CommissionSerialsViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForReceiveSerialVerification(scannedCode: [String]) {
        DispatchQueue.main.async{
           Utility.showPopup(Title: Success_Title, Message: "Serial(s) Scanned Successfully.".localized() , InViewC: self)
        }
        self.allScannedSerials.append(contentsOf: scannedCode)
        
         
    }
}

extension CommissionSerialsViewController : CommissionScannedSerialsViewDelegate{
    func didReceiveUpdatedSerials(serials: [String]) {
        self.allScannedSerials = serials
    }
}
