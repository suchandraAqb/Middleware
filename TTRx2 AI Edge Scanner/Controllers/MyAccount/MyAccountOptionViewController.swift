//
//  MyAccountOptionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 25/08/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MyAccountOptionViewController: BaseViewController{

    @IBOutlet var roundedView:[UIView]!
    
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK:- End
    
    //MARK: - IBAction
    
    @IBAction func userProfileButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePasswordViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK:- End
    
    
  

}
