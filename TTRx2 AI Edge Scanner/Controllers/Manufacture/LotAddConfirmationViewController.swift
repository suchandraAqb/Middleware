//
//  LotAddConfirmationViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 29/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol LotAddConfirmationViewDelegete: class {
    @objc optional func didClickOnAddLotbasedButton(_ isLotOpen:Bool)
}

class LotAddConfirmationViewController: BaseViewController {
    weak var delegate: LotAddConfirmationViewDelegete?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var lotOpenConfirmationView: UIView!
    @IBOutlet weak var lotOpenButton: UIButton!
    @IBOutlet weak var lotClosedButton: UIButton!
    var isLotOpen = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    //MARK: - End
    //MARK: - Private Methods
    func setUI() {
        sectionView.roundTopCorners(cornerRadious: 40)
        cancelButton.setRoundCorner(cornerRadious: cancelButton.frame.size.height/2.0)
        yesButton.setRoundCorner(cornerRadious: yesButton.frame.size.height/2.0)
        
        if isLotOpen{
            lotOpenLosedButtonPressed(lotOpenButton)
        }else{
            lotOpenLosedButtonPressed(lotClosedButton)
        }
       
    }
    
    //MARK: - End
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
        }
    }
    @IBAction func AddLotbasedButtonPressed(_ sender: UIButton) {

        
        if lotOpenConfirmationView.isHidden{
            lotOpenConfirmationView.isHidden = false
            headerLabel.text = "Close Lot Based Lot?".localized()
        }else{
            self.dismiss(animated: true) {
                self.delegate?.didClickOnAddLotbasedButton?(self.isLotOpen)
            }
        }
        
    }
    
    
    @IBAction func lotOpenLosedButtonPressed(_ sender: UIButton) {
        if sender.isSelected{
            return
        }
        
        if sender == lotOpenButton{
            isLotOpen = true
            lotOpenButton.isSelected = true
            lotClosedButton.isSelected = false
        }else{
            isLotOpen = false
            lotOpenButton.isSelected = false
            lotClosedButton.isSelected = true
        }
        
        
    }
    
    //MARK: - End
    

   

}
