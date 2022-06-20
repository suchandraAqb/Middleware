//
//  QuarantineOptionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 30/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit



@objc protocol QuarantineOptionViewControllerDelegete: class {
    @objc optional func didClickOnitemInQuarantineButton()
    @objc optional func didClickOnQuarantineButton()
}

class QuarantineOptionViewController: UIViewController {
    weak var delegate: QuarantineOptionViewControllerDelegete?
    @IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var newQuarantineButton: UIButton!
    @IBOutlet weak var itemInQuarantineButton: UIButton!
    @IBOutlet var multiLingualViews: [UIView]!
    
    //MARK: - View Life Cycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if multiLingualViews != nil {
           Utility.UpdateUILanguage(multiLingualViews)
        }
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    //MARK: - End
    
    //MARK: - Private Methods
    func setUI() {
        sectionView.roundTopCorners(cornerRadious: 40)
        newQuarantineButton.setRoundCorner(cornerRadious: newQuarantineButton.frame.size.height / 2.0)
        itemInQuarantineButton.setRoundCorner(cornerRadious: itemInQuarantineButton.frame.size.height / 2.0)
    }
    
    //MARK: - End
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
        }
    }
    @IBAction func newQuarantineButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnQuarantineButton?()
        }
        
    }
    @IBAction func itemInQuarantineButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnitemInQuarantineButton?()
        }
    }
    //MARK: - End
}

