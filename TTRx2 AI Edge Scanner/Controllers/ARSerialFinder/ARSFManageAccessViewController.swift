//
//  ARSFManageAccessViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/10/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFManageAccessViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var ListTable: UITableView!
    
    @IBOutlet var addButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    var listArray=["Staff who have it’s birthday in February","Jane Doe"]
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        addButton.setRoundCorner(cornerRadious: 10)
        deleteButton.setRoundCorner(cornerRadious: 10)
        ListTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFAddAccessView") as! ARSFAddAccessViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkUncheckButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    //MARK:- End
    
    //MARK: - Privete Method
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageAccessListTableViewCell") as! ManageAccessListTableViewCell
        
        cell.nameLabel.text=listArray[indexPath.row]
        
        if indexPath.row == 0 {
            cell.userButton.setImage(UIImage(named: "staff.png"), for: .normal)
        }else{
            cell.userButton.setImage(UIImage(named: "user.png"), for: .normal)
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as! ManageAccessListTableViewCell
        cell.checkUncheckButton.isSelected = !cell.checkUncheckButton.isSelected
    }
    //MARK:- End

}

class ManageAccessListTableViewCell:UITableViewCell{
    @IBOutlet var multiLingualViews: [UIView]!
    @IBOutlet var checkUncheckButton: UIButton!
    @IBOutlet var userButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
}
