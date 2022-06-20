//
//  ContainerScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 26/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol ContainerScanViewDelegate: class {
    @objc optional func didClickOnCamera()
}

class ContainerScanViewController: BaseViewController {
    weak var delegate: ContainerScanViewDelegate?
    @IBOutlet weak var singleMultiScanButton: UIButton!
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
        singleMultiScanButton.isSelected = defaults.bool(forKey: "IsMultiScan")
        multiButton.isSelected = singleMultiScanButton.isSelected
        multiLabel.textColor = Utility.color(from: multiButton.isSelected)
        singleButton.isSelected = !multiButton.isSelected
        singleLabel.textColor = Utility.color(from: singleButton.isSelected)
        
    }
    
    
    
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
        self.dismiss(animated: true) {
            self.delegate?.didClickOnCamera?()
        }
    }
    
    
    @IBAction func closeReceivingSelectionView(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
        }
    }
    // MARK: - END
}
