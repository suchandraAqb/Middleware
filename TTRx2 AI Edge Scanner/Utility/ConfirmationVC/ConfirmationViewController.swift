//
//  ConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 06/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol  ConfirmationViewDelegate: class {
    func doneButtonPressed()
    @objc optional func cancelButtonPressed()
    @objc optional func cancelConfirmation()
    @objc optional func doneButtonPressedWithIndex(index : Int)

}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var confirmationMsgLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!//,,,sb11-1
    @IBOutlet weak var cancelButton: UIButton!//,,,sb11-1
    
    var confirmationMsg : String!
    var isCancelConfirmation = false
    var isIndexRequired = false
    var indexNumber = -1
    var controllerName = "" //,,,sb11-1

    weak var delegate: ConfirmationViewDelegate?
    
    //MARK: View Life Cycle
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        if !confirmationMsg.hasSuffix("?"){
            confirmationMsg = confirmationMsg + "?"
        }
        confirmationMsgLabel.text = confirmationMsg.firstUppercased
        
        if controllerName == "ARSFCreateNewFilterViewController" {
            doneButton.setRoundCorner(cornerRadious: 8)
            cancelButton.setRoundCorner(cornerRadious: 8)
        }//,,,sb11-1
        
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
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            if self.isIndexRequired{
                self.delegate?.doneButtonPressedWithIndex?(index: self.indexNumber)
            }else if self.isCancelConfirmation{
                self.delegate?.cancelConfirmation?()
            }else{
                self.delegate?.doneButtonPressed()
            }
            
        }
    }
    //MARK: End
}


