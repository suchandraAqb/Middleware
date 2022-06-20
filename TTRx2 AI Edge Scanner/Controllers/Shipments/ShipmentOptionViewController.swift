//
//  ShipmentOptionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 16/07/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ShipmentOptionViewController: BaseViewController {

    
    @IBOutlet var roundedView:[UIView]!

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
    }

    
    //MARK:- IBAction
    
    @IBAction func inboundButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InboundShipmentList") as! InboundShipmentListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func outboundButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "OutboundShipmentList") as! OutboundShipmentListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func productPerspectiveButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Finder", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "PPListViewController") as! PPListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    //MARK:- End
    
    
}
