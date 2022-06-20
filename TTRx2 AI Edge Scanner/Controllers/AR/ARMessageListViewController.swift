//
//  ARMessageListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 12/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARMessageListViewController: BaseViewController,AddARMessageViewControllerDelegate {
    
    //MARK: - Update Status Bar Style
    var messageList = Array<Dictionary<String,Any>>()
    var selectedMessageIndex = -1
    @IBOutlet weak var messageListTable: UITableView!
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    /////////////////////////////////////////////////////
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let temp = defaults.object(forKey: "ARMessageList") as? Array<Dictionary<String,Any>>{
            messageList = temp
        }else{
            messageList = Array<Dictionary<String,Any>>()
        }
        if let tempSelectedIndex = defaults.value(forKey: "ARMessageSelectedIndex") as? Int{
            selectedMessageIndex = tempSelectedIndex
        }else{
            selectedMessageIndex = -1
        }
        self.messageListTable .reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        defaults.set(messageList, forKey: "ARMessageList")
        defaults.set(selectedMessageIndex, forKey: "ARMessageSelectedIndex")
    }
    //MARK: - End
    ///////////////////////////////////////////////////////
    //MARK: - AddARMessageViewControllerDelegate
    func didSaveNewMessage(messageDict: [String : Any]) {
        self.messageList.append(messageDict)
        //self.messageListTable.reloadData()
        defaults.set(self.messageList, forKey: "ARMessageList")
        self.viewWillAppear(true)
    }
}
///////////////////////////////////////////////////////
//MARK: - IBAction -
extension ARMessageListViewController{
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        if(selectedMessageIndex == -1){
            Utility.showPopup(Title: "Warning!".localized(), Message: "Please select your default message before scan.".localized(), InViewC: self)
            return;
        }
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        controller.isForMessageAr = true
        controller.messageDict = messageList[selectedMessageIndex]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddARMessageViewController") as! AddARMessageViewController
        controller.delegate = self
        self.showPopover(ofViewController: controller, originView: self.view, presentationStyle: .custom, transitionStyle: .crossDissolve)
        /*
         let ac = UIAlertController(title: "Add New Message", message: nil, preferredStyle: .alert)
         ac.addTextField { (textField) in
         textField.placeholder = "Title..."
         }
         ac.addTextField { (textField) in
         textField.placeholder = "Message..."
         }
         
         
         
         let okAction = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
         guard let title = ac.textFields![0].text,!title.isEmpty else{
         Utility.showPopup(Title:"Warning!", Message: "Title can't be blank.", InViewC: self)
         return
         }
         guard let message = ac.textFields![1].text,!message.isEmpty else{
         Utility.showPopup(Title:"Warning!", Message: "Message can't be blank.", InViewC: self)
         return
         }
         var dict = [String: Any]()
         dict["title"] = title
         dict["body"] = message
         self.messageList.append(dict)
         //self.messageListTable.reloadData()
         defaults.set(self.messageList, forKey: "ARMessageList")
         self.viewWillAppear(true)
         }
         ac.addAction(okAction)
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         ac.addAction(cancelAction)
         
         self.present(ac, animated: true, completion: nil)
         let rect = CGRect(x: ac.textFields![1].frame.origin.x, y: ac.textFields![1].frame.origin.y+ac.textFields![1].frame.size.height+5, width: ac.textFields![1].frame.size.width, height: 60)
         let customView = HSBColorPicker(frame: rect)
         customView.delegate = self
         customView.backgroundColor = .green
         ac.view.addSubview(customView)
         
         */
    }
}
//MARK: - End -
//////////////////////////////////////////////////////
//MARK: - Tableview Delegate and Datasource -
extension ARMessageListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARMessageListTableViewCell") as! ARMessageListTableViewCell
        let messageDict =  messageList[indexPath.row] as Dictionary
        cell.messageTitlelLabel.text = messageDict["title"] as? String
        cell.messageBodylLabel.text = messageDict["body"] as? String
        
        if indexPath.row == selectedMessageIndex {
            cell.checkButton.isSelected = true
        }else{
            cell.checkButton.isSelected = false
        }
        //cell.deleteButton.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let ac = UIAlertController(title: "Confirm".localized(), message: "Are you sure you want to delete this message? ".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler:  { (UIAlertAction) in
                if(indexPath.row == self.messageList.count-1){
                    self.selectedMessageIndex = -1
                }
                self.messageList.remove(at: indexPath.row)
                defaults.set(self.messageList, forKey: "ARMessageList")
                defaults.set(self.selectedMessageIndex, forKey: "ARMessageSelectedIndex")
                self.viewWillAppear(true)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
                //self.messageListTable.reloadData()
            })
            ac.addAction(okAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("-----------------------------")
        /*
         if(indexPath.row == selectedMessageIndex){
         selectedMessageIndex = -1
         }else{
         selectedMessageIndex = indexPath.row
         }
         defaults.set(self.selectedMessageIndex, forKey: "ARMessageSelectedIndex")
         self.messageListTable.reloadData()
         */
        DispatchQueue.main.async{
            if(indexPath.row == self.selectedMessageIndex){
                let ac = UIAlertController(title: "Confirm".localized(), message: "Do you want to remove this message from default?".localized(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:  { (UIAlertAction) in
                    self.selectedMessageIndex = -1
                    defaults.set(self.selectedMessageIndex, forKey: "ARMessageSelectedIndex")
                    self.messageListTable.reloadData()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
                    //self.messageListTable.reloadData()
                })
                ac.addAction(okAction)
                ac.addAction(cancelAction)
                self.present(ac, animated: true, completion: nil)
            }else{
                let ac = UIAlertController(title: "Confirm".localized(), message: "Do you want to make this your default scan message?".localized(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:  { (UIAlertAction) in
                    self.selectedMessageIndex = indexPath.row
                    defaults.set(self.selectedMessageIndex, forKey: "ARMessageSelectedIndex")
                    self.messageListTable.reloadData()
                })
                ac.addAction(okAction)
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:  { (UIAlertAction) in
                    //self.messageListTable.reloadData()
                })
                ac.addAction(cancelAction)
                self.present(ac, animated: true, completion: nil)
            }
        }
        
    }
}
//MARK: - End -
////////////////////////////////////////////////
class ARMessageListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTitlelLabel: UILabel!
    @IBOutlet weak var messageBodylLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
