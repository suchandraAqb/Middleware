//
//  ARSFCardViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 06/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol  ARSFCardViewControllerDelegate: AnyObject {
    @objc optional func didSelectButton(buttonName:String,detailsDict:[String:Any]?)
}//,,,sb11-3

class ARSFCardViewController: BaseViewController {
    var filterType = ""//,,,sb11-3
    var itemDetailsDict = [String : Any]()//,,,sb11-3
    weak var delegate: ARSFCardViewControllerDelegate?//,,,sb11-3

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
//        print("filterType....",filterType)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func crossButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //,,,sb11-3
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectButton!(buttonName: "start",detailsDict: self.itemDetailsDict)
    }
    @IBAction func editFilterButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectButton!(buttonName: "edit",detailsDict: self.itemDetailsDict)
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectButton!(buttonName: "delete",detailsDict: self.itemDetailsDict)
    }
    @IBAction func duplicateButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectButton!(buttonName: "duplicate",detailsDict: self.itemDetailsDict)
    }
    //,,,sb11-3
    
    //MARK:- End
}
