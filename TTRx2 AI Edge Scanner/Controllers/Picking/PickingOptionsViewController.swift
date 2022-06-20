//
//  PickingOptionsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 21/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol PickingOptionsViewDelegete: class {
    @objc optional func didClickOnSOByPickingButton()
    @objc optional func didClickOnPickingBySOButton()
}

class PickingOptionsViewController: BaseViewController {
    weak var delegate: PickingOptionsViewDelegete?
    //@IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var SOByPickingButton: UIButton!
    @IBOutlet weak var PickingBySOButton: UIButton!
    
    //MARK: - View Life Cycle
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    //MARK: - End
    //MARK: - Private Methods
    private func setUI() {
        sectionView.roundTopCorners(cornerRadious: 40)
        SOByPickingButton.setRoundCorner(cornerRadious: SOByPickingButton.frame.size.height / 2.0)
        PickingBySOButton.setRoundCorner(cornerRadious: PickingBySOButton.frame.size.height / 2.0)
    }
    
    //MARK: - End
    //MARK: - IBAction
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func SOByPickingButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnSOByPickingButton?()
        }
    }
    @IBAction func PickingBySOButtonPressed(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true) {
            self.delegate?.didClickOnPickingBySOButton?()
        }
    }
    //MARK: - End
}

