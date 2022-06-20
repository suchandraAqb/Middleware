//
//  ARSFAddAccessViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/10/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFAddAccessViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var detailsView: UIView!
    
    @IBOutlet var usersButton: UIButton!
    @IBOutlet var rolesButton: UIButton!
    @IBOutlet var usersView: UIView!
    @IBOutlet var rolesView: UIView!
    @IBOutlet var usersTable: UITableView!
    @IBOutlet var rolesTable: UITableView!
    
    var listArray=["Jonh Smith","Daniel Sample"]
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func usersButtonPressed(_ sender: UIButton) {
        if !usersButton.isSelected {
            usersButton.isSelected=true
            usersButton.backgroundColor=UIColor.systemBlue
            usersView.isHidden=false
            rolesButton.isSelected=false
            rolesButton.backgroundColor=UIColor.white
            rolesView.isHidden=true
        }
    }
    @IBAction func rolesButtonPressed(_ sender: UIButton) {
        if !rolesButton.isSelected {
            rolesButton.isSelected=true
            rolesButton.backgroundColor=UIColor.systemBlue
            rolesView.isHidden=false
            usersButton.isSelected=false
            usersButton.backgroundColor=UIColor.white
            usersView.isHidden=true
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func usersCheckUncheckButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func rolesCheckUncheckButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    //MARK:- End
    
    //MARK: - Privete Method
    func prepareView(){
        //,,,sb-lang1
        usersButton.setTitle("Users".localized(), for: UIControl.State.selected)
        rolesButton.setTitle("Roles".localized(), for: UIControl.State.selected)
        //,,,sb-lang1
        
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 10.0
        detailsView.clipsToBounds = true
        usersButton.setRoundCorner(cornerRadious: 10)
        usersButton.layer.borderWidth=2
        usersButton.layer.borderColor=UIColor.systemBlue.cgColor
        rolesButton.setRoundCorner(cornerRadious: 10)
        rolesButton.layer.borderWidth=2
        rolesButton.layer.borderColor=UIColor.systemBlue.cgColor
        usersTable.reloadData()
        rolesTable.reloadData()
        usersButtonPressed(usersButton)
        
    }
    //MARK:- End
    
    
    //MARK: - Webservice Call
    
    //MARK:- End
    
    //MARK: - Table view datasourse & delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == usersTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFAddAccessUsersListTableViewCell") as! ARSFAddAccessUsersListTableViewCell
            cell.titleLabel.text=listArray[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFAddAccessRolesListTableViewCell") as! ARSFAddAccessRolesListTableViewCell
            cell.titleLabel.text="Test Name"//listArray[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == usersTable {
            let cell = tableView.cellForRow(at: indexPath) as! ARSFAddAccessUsersListTableViewCell
            cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! ARSFAddAccessRolesListTableViewCell
            cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
        }
        
    }
    //MARK:- End
    
    
    
}


//MARK:  Table view cell class

class ARSFAddAccessUsersListTableViewCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var checkUncheckButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}

class ARSFAddAccessRolesListTableViewCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var checkUncheckButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
