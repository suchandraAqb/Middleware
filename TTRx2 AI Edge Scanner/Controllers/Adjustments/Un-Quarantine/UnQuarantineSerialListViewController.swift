//
//  UnQuarantineSerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 07/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class UnQuarantineSerialListViewController: BaseViewController {
    @IBOutlet weak var listTable: UITableView!
    var structure: [[String: Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Action
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
//MARK: - End
}
extension UnQuarantineSerialListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UnQuarantineSerialListCell
        cell.customView.setRoundCorner(cornerRadious: 10)
        let serial = structure[indexPath.row]
        cell.serialLabel.text = (serial["serial"] as? String) ?? ""
        return cell
    }
    
    
}

//MARK: - Tableview Cell
class UnQuarantineSerialListCell: UITableViewCell {
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var serialLabel: UILabel!
    
    override func awakeFromNib() {
    }
    
}
