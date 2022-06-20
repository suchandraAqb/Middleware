//
//  CustomViewForMessageAR.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 13/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class CustomViewForMessageAR: UIView {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView(message : [String:Any]) -> CustomViewForMessageAR{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomViewForMessageAR", owner: self, options: nil)?.first as! CustomViewForMessageAR
        customInfoWindow.titleLabel.text = message["title"] as? String
        customInfoWindow.messageLabel.text = message["body"] as? String
        guard let colorData = message["color"] as? Data else { return customInfoWindow }

        do {
            customInfoWindow.topView.backgroundColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData )
        } catch let error {
            print("color error \(error.localizedDescription)")
        }
        
        return customInfoWindow
    }
}
