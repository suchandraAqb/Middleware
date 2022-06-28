//
//  SettingsPageViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Dhiman on 20/06/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SettingsPageViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addCredentialButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var settingTableView: UITableView!
    var arrCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createInputAccessoryView()
        addCredentialButton.setRoundCorner(cornerRadious: addCredentialButton.frame.size.height/2)
        saveButton.setRoundCorner(cornerRadious: addCredentialButton.frame.size.height/2)
    }
    
    
    //MARK: View Life Cycle
    //MARK: End
    
    //MARK: IBAction
    @IBAction func addCredentialsButtonPressed(_ sender:UIButton){
        self.arrCount = arrCount + 1
        settingTableView.reloadData()
    }
    //MARK: End
    
    //MARK: - textField Delegate
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            let pointInTable = textField.superview!.convert(textField.frame.origin, to: settingTableView)
            var tableVContentOffset = settingTableView.contentOffset
            tableVContentOffset.y = pointInTable.y
            if let accessoryView = textField.inputAccessoryView {
                tableVContentOffset.y -= accessoryView.frame.size.height
            }
            settingTableView.setContentOffset(tableVContentOffset, animated: true)
            return true;
      }
    
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.inputAccessoryView = inputAccView
            textFieldTobeField = textField

        }
        func textFieldDidEndEditing(_ textField: UITextField) {
       
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            textField.resignFirstResponder()
            return true
        }
    
    //MARK: - UITableViewDataSource & UITableviewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCount
   }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        cell.usernameTextfield.inputAccessoryView = inputAccView
        cell.passwordTextfield.inputAccessoryView = inputAccView
        
        cell.usernameTextfield.text = ""
        cell.passwordTextfield.text = ""
        
        return cell
   
   }
}
 class SettingsTableViewCell : UITableViewCell{
    @IBOutlet weak var usernameTextfield:UITextField!
    @IBOutlet weak var passwordTextfield:UITextField!
    @IBOutlet weak var dropdownButton:UIButton!
    @IBOutlet weak var erpview:UIView!
     
     override func awakeFromNib() {
         usernameTextfield.setRoundCorner(cornerRadious: 10)
         usernameTextfield.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10)
         passwordTextfield.setRoundCorner(cornerRadious: 10)
         passwordTextfield.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10)
         erpview.setRoundCorner(cornerRadious: 10)
         erpview.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10)
     }
}
