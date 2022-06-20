//
//  MISAddAggregationScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 06/05/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol MISAddAggregationScanViewControllerDelegate: class {
    @objc optional func clickOnCamera()
    @objc optional func clickOnCameraInviewAggregation(parentId:Int)
    @objc optional func didClickOnSearchByManually(parentId:Int)
}

class MISAddAggregationScanViewController: BaseViewController {
    weak var delegate: MISAddAggregationScanViewControllerDelegate?
    var isFromViewAggregation:Bool = false
    var parentId :Int = 0
    
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet weak var manualButton:UIButton!
    @IBOutlet weak var orlabel : UILabel!
    
    var lineItemArr:Array<Any>?
        
 // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        manualButton.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
        BaseViewController.transparentBlackEffect(On: self.view)
        self.multiButton.isHidden = false
        self.multiLabel.isHidden = false
        self.singleButton.isHidden = false
        self.singleLabel.isHidden = false
        singleMultiScanButton.isHidden = false
        if (defaults.object(forKey: "lineItemCheck") != nil){
            if ((defaults.object(forKey: "lineItemCheck")) as! Int == 1) {
                if ((lineItemArr?.isEmpty) == nil) {
                    manualButton.isHidden = true
                    orlabel.isHidden = true
                }else{
                    manualButton.isHidden = false
                    orlabel.isHidden = false
                }

        }else{
            manualButton.isHidden = false
            orlabel.isHidden = false

        }
      }
    }
    //MARK: - End
    
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
        
        self.view.backgroundColor = .clear
        self.dismiss(animated: true, completion: {
            if self.isFromViewAggregation{
                self.delegate?.clickOnCameraInviewAggregation?(parentId: self.parentId)
            }else{
                self.delegate?.clickOnCamera?()
            }
        })

    }
    @IBAction func searchManuallyButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true, completion: {
            self.delegate?.didClickOnSearchByManually?(parentId: self.parentId)
        })
    }
    @IBAction func closeReceivingSelectionView(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true, completion:nil)
    }
    
}
