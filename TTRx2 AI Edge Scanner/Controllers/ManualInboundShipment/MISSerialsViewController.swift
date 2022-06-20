//
//  MISSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 18/02/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISSerialsViewController:  BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
 
    @IBOutlet weak var serialListTable: UITableView!
    
    var serialList = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        serialListTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - Tableview Delegate and Datasource

    
    func numberOfSections(in tableView: UITableView) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serialList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventorySerialListTableViewCell") as! InventorySerialListTableViewCell
        let name =  serialList[indexPath.row]
        cell.serialLabel.text = name
        return cell
    }
    //MARK: - End
}

