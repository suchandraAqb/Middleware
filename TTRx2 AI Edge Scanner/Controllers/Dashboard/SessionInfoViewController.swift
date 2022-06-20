//
//  PickingListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SessionInfoViewController: BaseViewController {
    @IBOutlet weak var selectView:UIView!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var enviromentLabel:UILabel!
    @IBOutlet weak var versionLabel:UILabel!
    @IBOutlet weak var fullName:UILabel!
    var userDict = NSDictionary()
    
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectView.setRoundCorner(cornerRadious: 20)
        self.populateDetails()
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func crossButtonpressed(_ sender:UIButton){
        self.dismiss(animated: true)
    }
   

    func populateDetails(){
        let currentDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: currentDate)
        let daySuffixStr = "\(day)\(Utility.dateSuffix(day: day))"
        let formattedDate = currentDate.getFormattedDate(format: "MMMM, yyyy")
        dateLabel.text = "\(daySuffixStr) \(formattedDate)"
        
        var username = ""
        if let userNamestr =  defaults.object(forKey: "userName") as? String {
            username = userNamestr
        }
        self.userName.text = (username.capitalized)

        var full_name = ""
        if let full_namestr =  defaults.object(forKey: "userName") as? String {
            full_name = full_namestr
        }
        fullName.text = (full_name.capitalized)
     
        versionLabel.text = "Version 22.1"
        
        var domainName = ""
        if let domainStr =  defaults.object(forKey: "domainname") as? String {
            domainName = domainStr
        }
        enviromentLabel.text = domainName
        
//        var baseUrl = ""
//        if let restendpoint = BaseUrl{
//            let str1 = restendpoint.components(separatedBy: "api.").last
//            let str2 = str1?.components(separatedBy: ".tracktraceweb").first
//            if restendpoint == "https://api.tracktraceweb.com/2.0/" {
//                baseUrl = "Production"
//            }else{
//                baseUrl = str2!
//            }
//        }
//        enviromentLabel.text = "\(clientFriendlyName) - (\(baseUrl.capitalized))"
    }

    //MARK: - End
    
    //MARK: - Call API
    //MARK: End
}



