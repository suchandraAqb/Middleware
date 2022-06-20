//
//  SingleSelectDropdownViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 04/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

@objc protocol SingleSelectDropdownDelegate: class {
    @objc optional func selecteditem(data:NSDictionary,sender:UIButton?)
    @objc optional func selectedItem(itemStr:String,data:NSDictionary,sender:UIButton?)
    @objc optional func cancelButtonPressed()
    
}

class SingleSelectDropdownViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sectionView:UIView!
    @IBOutlet weak var table:UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    var listItems = Array<[String : Any]>()
    var nameKeyName : String!
    var subKeyName : String?
    var type : String!
    var isDataWithDict:Bool!
    var listItemsDict:NSDictionary!
    var sender:UIButton?
    @IBOutlet var multiLingualViews: [UIView]!
    var isfromManualShipment : Bool!
    var subKeyNameArray:Array<Any>?
    var subkeyNameAddStr = ""
    
    weak var delegate: SingleSelectDropdownDelegate?
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
        sectionView.roundTopCorners(cornerRadious: 40)
        titleLabel.text = type.capitalized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        BaseViewController.transparentBlackEffect(On: self.view)
    }
    
    // MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDataWithDict{
            return listItemsDict.allKeys.count
        }else{
            return listItems.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        
        if isDataWithDict{
            let allKeys:Array = listItemsDict.allKeys
            let uuid:String = allKeys[indexPath.row] as! String
            
            let dict = listItemsDict[uuid] as! Dictionary<String,Any>
            
            if !dict.isEmpty {
                if !(subKeyName ?? "").isEmpty {
                    print("\(dict[nameKeyName] ?? "")".capitalized + " - " + "\(dict[subKeyName!] ?? "")".capitalized)
                    cell.listNameLabel.text = "\(dict[nameKeyName] ?? "")".capitalized + " - " + "\(dict[subKeyName!] ?? "")".capitalized
                }else{
                    cell.listNameLabel.text = "\(dict[nameKeyName] ?? "")".capitalized
                }
            }
            
        }else{
            let dict = listItems[indexPath.row]
            if !dict.isEmpty {
                if subKeyNameArray != nil {
                    var tempStr = ""
                    var i = 1
                    for subkey in subKeyNameArray!{
                        if let tempSubKey = subkey as? NSDictionary {
                            if let name = tempSubKey["name"] as? String, let key = tempSubKey["key"] as? String {
                                tempStr = tempStr + name + " : " + Utility.stringConversion(data: dict[key])
                            }
                            if i < subKeyNameArray?.count ?? 0 {
                                tempStr = tempStr  + subkeyNameAddStr + " "
                            }
                        }                                                                                                                                                                   
                        i = i+1
                    }
                    cell.listNameLabel.text = "\(tempStr)"
                }else if !(subKeyName ?? "").isEmpty {
                    print("\(dict[nameKeyName] ?? "")".capitalized + " - " + "\(dict[subKeyName!] ?? "")".capitalized)
                    cell.listNameLabel.text = "\(dict[nameKeyName] ?? "")".capitalized + " - " + "\(dict[subKeyName!] ?? "")".capitalized
                }else{
                    cell.listNameLabel.text = "\(dict[nameKeyName] ?? "")".capitalized
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDataWithDict{
            let allKeys:Array = listItemsDict.allKeys
            let uuid:String = allKeys[indexPath.row] as! String
            let dict = listItemsDict[uuid] as! Dictionary<String,Any>
            if !dict.isEmpty {
                self.view.backgroundColor = .clear
                self.dismiss(animated: true) {
                    self.delegate?.selectedItem?(itemStr: uuid, data: dict as NSDictionary,sender: self.sender)
                }
            }
        }else{
            let dict = listItems[indexPath.row]
            if !dict.isEmpty {
                self.view.backgroundColor = .clear
                self.dismiss(animated: true) {
                    self.delegate?.selecteditem?(data: dict as NSDictionary,sender: self.sender)
                }
            }
        }
    }
    
    
    //MARK:IBAction
    
    @IBAction func cancelButtonPressed(_ sender: UIButton){
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) {
        }
    }
    
    
    
    
}
class ListCell: UITableViewCell
{
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var checkUncheck: UIButton!
    
    override func awakeFromNib() {
        
    }
}
