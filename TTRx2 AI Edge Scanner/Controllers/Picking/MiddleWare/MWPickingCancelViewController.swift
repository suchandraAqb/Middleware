//
//  MWPickingCancelViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 08/11/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm4

import UIKit

class MWPickingCancelViewController: BaseViewController {
    
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var voidView: UIView!
    @IBOutlet weak var voidButtonView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelButtonView: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        continueView.setRoundCorner(cornerRadious: 20)
        continueButtonView.setRoundCorner(cornerRadious: continueButtonView.frame.size.height/2.0)
        voidView.setRoundCorner(cornerRadious: 20)
        voidButtonView.setRoundCorner(cornerRadious: voidButtonView.frame.size.height/2.0)
        cancelView.setRoundCorner(cornerRadious: 20)
        cancelButtonView.setRoundCorner(cornerRadious: cancelButtonView.frame.size.height/2.0)
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        backActionPopToRoot(sender: UIButton())
    }
    
    @IBAction func voidButtonPressed(_ sender: UIButton) {
        MWPicking.removeAllMW_PickingEntityDataFromDB()//,,,sbm2
        backActionPopToRoot(sender: UIButton())
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    //MARK: - End
}
