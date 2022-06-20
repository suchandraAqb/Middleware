//
//  AddLotOptionsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 25/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol AddLotOptionsViewDelegete: class {
    @objc optional func didClickOnAddLotbasedButton()
    @objc optional func didClickOnAddSerialbasedButton()
}

class AddLotOptionsViewController: BaseViewController {
    weak var delegate: AddLotOptionsViewDelegete?
    //@IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var AddLotbasedButton: UIButton!
    @IBOutlet weak var AddSerialbasedButton: UIButton!
    
    //MARK: - View Life Cycle
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        AddLotbasedButton.setRoundCorner(cornerRadious: AddLotbasedButton.frame.size.height / 2.0)
        AddSerialbasedButton.setRoundCorner(cornerRadious: AddSerialbasedButton.frame.size.height / 2.0)
    }
    
    //MARK: - End
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
        }
    }
    @IBAction func AddLotbasedButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnAddLotbasedButton?()
        }
        
    }
    @IBAction func AddSerialbasedButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnAddSerialbasedButton?()
        }
    }
    //MARK: - End
}

