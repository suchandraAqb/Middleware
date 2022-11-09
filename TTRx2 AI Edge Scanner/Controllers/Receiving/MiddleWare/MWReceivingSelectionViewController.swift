//
//  MWReceivingSelectionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 20/07/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit

@objc protocol MWReceivingSelectionViewControllerDelegate: AnyObject {
    @objc optional func didClickOnCamera()
    @objc optional func didClickManually()
    @objc optional func didClickCrossButton()
}

class MWReceivingSelectionViewController: BaseViewController {
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var manuallyButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet var multiLingualView: [UIView]!
    
    weak var delegate: MWReceivingSelectionViewControllerDelegate?
    
    var previousController = ""
    
    // MARK: - IBAction
    @IBAction func toggleSingleMultiScan(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.isSelected.toggle()
            defaults.set(sender.isSelected, forKey: "IsMultiScan")
            self.multiButton.isSelected = sender.isSelected
            self.multiLabel.textColor = Utility.color(from: self.multiButton.isSelected)
            self.singleButton.isSelected = !self.multiButton.isSelected
            self.singleLabel.textColor = Utility.color(from: self.singleButton.isSelected)
        }
    }
    
    @IBAction func startReceivingScanButtonPressed(_ sender: Any){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnCamera?()
        }
    }
    
    @IBAction func closeReceivingSelectionView(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            if self.previousController == "MWReceivingManuallyViewController" || self.previousController == "MWReceivingSerialListViewController" {
                self.delegate?.didClickCrossButton?()
            }
        }
    }
    
    @IBAction func manuallyButtonPressed(_ sender: Any){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.didClickManually?()
        }
    }
    // MARK: - END
    
    // MARK: - ViewLifeCycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        orLabel.isHidden = false
        manuallyButton.isHidden = false
        if previousController == "MWReceivingManuallyViewController" || self.previousController == "MWReceivingSerialListViewController"{
            orLabel.isHidden = true
            manuallyButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Utility.UpdateUILanguage(multiLingualView)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    // MARK: - END
}
