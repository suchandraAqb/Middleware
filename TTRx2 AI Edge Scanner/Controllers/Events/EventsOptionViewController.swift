//
//  EventsOptionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by AQB Solutions Private Limited on 14/12/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class EventsOptionViewController: BaseViewController {

    @IBOutlet var roundedView:[UIView]!

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
    }

    
 //MARK: - IBAction
    
    @IBAction func inboundButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InboundFailedSerialsListView") as! InboundFailedSerialsListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func outboundButtonPressed(_ sender: UIButton) {
        
    }
    
    
    
    
    //MARK: - End
    

   

}
