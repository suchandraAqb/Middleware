//
//  ReturnProductTypeSelectionVC.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 01/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

typealias productType = (_ isLotBased: Bool) -> Void

class ReturnProductTypeSelectionVC: BaseViewController {
    
    public var selectedProduct : productType?
    
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
}
extension ReturnProductTypeSelectionVC{
    
    @IBAction func closeView(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func SerialBasedButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            guard let returnValue = self.selectedProduct else {return}
            returnValue(false)
        }
    }
    @IBAction func LotBasedButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            guard let returnValue = self.selectedProduct else {return}
            returnValue(true)
        }
    }
}

