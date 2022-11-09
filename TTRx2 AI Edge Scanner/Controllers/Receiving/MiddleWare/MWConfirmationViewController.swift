//
//  MWConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 06/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

@objc protocol  MWConfirmationViewDelegate: AnyObject {
    func doneButtonPressed(alertStatus:String)
    func cancelButtonPressed(alertStatus:String)
}

class MWConfirmationViewController: UIViewController {
    @IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var confirmationMsgLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var confirmationMsg : String!
    var alertStatus = ""
    var isCancelButtonShow = false

    weak var delegate: MWConfirmationViewDelegate?
    
    //MARK: View Life Cycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmationMsgLabel.text = confirmationMsg.firstUppercased
        
        doneButton.setRoundCorner(cornerRadious: doneButton.frame.height/2)
        
        if isCancelButtonShow {
            cancelButton.isHidden = false
            cancelButton.backgroundColor = UIColor.white
            cancelButton.setTitleColor( Utility.hexStringToUIColor(hex: "276A44"), for: UIControl.State.normal)
            cancelButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "276A44"), cornerRadious: doneButton.frame.height/2)
        }else {
            cancelButton.isHidden = true
        }
        
        if alertStatus == "Alert1" ||
           alertStatus == "Alert3" ||
           alertStatus == "Alert4" ||
           alertStatus == "Alert5" ||
           alertStatus == "Alert6" {
            
            doneButton.setTitle("Yes".localized(), for: UIControl.State.normal)
            cancelButton.setTitle("No".localized(), for: UIControl.State.normal)
        }
        else if alertStatus == "Alert2" {
            doneButton.setTitle("Ok".localized(), for: UIControl.State.normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    //MARK: End
    
    //MARK: IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.cancelButtonPressed(alertStatus: self.alertStatus)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.doneButtonPressed(alertStatus: self.alertStatus)
        }
    }
    //MARK: End
}


