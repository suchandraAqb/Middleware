//
//  LotDetailsView.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/09/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class LotDetailsView: UIView {
    @IBOutlet weak var lotNoLabel: UILabel!
    @IBOutlet weak var lotQuantity: UILabel!
    @IBOutlet weak var lotNoHeaderLabel: UILabel!
    @IBOutlet weak var lotQuantityHeaderLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
       return UINib(nibName: "LotDetailsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    

}
