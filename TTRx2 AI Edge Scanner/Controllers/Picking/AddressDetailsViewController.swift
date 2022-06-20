//
//  AddressDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 13/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class AddressDetailsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addCustomAddressButton: UIButton!
    @IBOutlet weak var toggleButton1: UIButton!
    @IBOutlet weak var toggleButton2: UIButton!
    @IBOutlet weak var toggle1BorderView: UIView!
    @IBOutlet weak var toggle2BorderView: UIView!
    var isSeller:Bool!
    var addressArr:Array<Any>?
    var isSelected1stView:Bool!
    
    var view1SelectedIndex = -1
    var view2SelectedIndex = -1
    
    var broughtByData:NSDictionary?
    var shipToData:NSDictionary?
    var soldByData:NSDictionary?
    var shipFromData:NSDictionary?
    
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        addCustomAddressButton.setBorder(width: 1.0, borderColor: Utility.hexStringToUIColor(hex: "719898"), cornerRadious: addCustomAddressButton.frame.size.height/2.0)
        containerView.setRoundCorner(cornerRadious: 10)
        setup_view()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    //MARK: - End
    //MARK: - Private
    func setup_view(){
        if isSelected1stView {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            
        }
        
        if isSeller{
            backButton.setTitle("Seller Address".localized(), for: .normal)
            toggleButton1.setTitle("Sold By".localized(), for: .normal)
            toggleButton2.setTitle("Ship From".localized(), for: .normal)
            
            if let dataDict = Utility.getDictFromdefaults(key: "soldBy"){
                soldByData = dataDict
            }else{
                if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                    soldByData = addData
                }
            }
            
            if let dataDict = Utility.getDictFromdefaults(key: "shipFrom"){
                shipFromData = dataDict
            }else{
                if let addData = UserInfosModel.getDefaultAddress(is_Default_Location: false){
                    shipFromData = addData
                    
                }
            }
        }else{
            backButton.setTitle("Trading Partner Address".localized(), for: .normal)
            toggleButton1.setTitle("Sold To".localized(), for: .normal)
            toggleButton2.setTitle("Ship To".localized(), for: .normal)
            
            if let dataDict = Utility.getDictFromdefaults(key: "broughtBy"){
                broughtByData = dataDict
            }else{
                if let addData = CustomerAddressesModel.getDefaultAddress(){
                    broughtByData = addData
                }
            }
            
            
            
            if let dataDict = Utility.getDictFromdefaults(key: "shipTo"){
                shipToData = dataDict
            }else{
                if let addData = CustomerAddressesModel.getDefaultAddress(){
                    shipToData = addData
                    
                }
            }
        }
    }
    
    func populateAddressView(data:NSDictionary?,label:UILabel,isSelected:Bool){
        
        var color1:UIColor!
        var color2:UIColor!
        
        if isSelected{
            color1 = UIColor.white
            color2 = Utility.hexStringToUIColor(hex: "BFF1FF")
        }else{
            color1 = Utility.hexStringToUIColor(hex: "00AFEF")
            color2 = Utility.hexStringToUIColor(hex: "072144")
        }
        
        
        let secondAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color1!,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0)!]
        
        let thirdAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color2!,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0)!]
        
        if data != nil {
            var nick_name = ""
            if let recipient_name:String = data!["recipient_name"] as? String{
                nick_name = "\(recipient_name)"
            }
            
            //            if let address_nickname:String = data!["address_nickname"] as? String{
            //                nick_name = "\(address_nickname)"
            //            }
            let nameStr = NSMutableAttributedString(string: nick_name, attributes: secondAttributes)
            
            var addressStr:String = "\n"
            
            if let line1:String = data!["line1"] as? String{
                if line1.count > 0 {
                    addressStr = addressStr + line1 + ", "
                }
            }
            
            if let line2:String = data!["line2"] as? String{
                if line2.count > 0 {
                    addressStr = addressStr + line2 + ", "
                }
            }
            
            if let line3:String = data!["line3"] as? String{
                if line3.count > 0 {
                    addressStr = addressStr + line3 + ", "
                }
            }
            
            if let city:String = data!["city"] as? String{
                
                if city.count > 0 {
                    addressStr = addressStr + city + ", "
                }
            }
            
            if let state_name:String = data!["state_name"] as? String{
                
                if state_name.count > 0 {
                    addressStr = addressStr + state_name + ", "
                }
            }
            
            if let country_name:String = data!["country_name"] as? String{
                if country_name.count > 0 {
                    addressStr = addressStr + country_name
                }
            }
            
            let addStr = NSAttributedString(string: addressStr, attributes: thirdAttributes)
            
            nameStr.append(addStr)
            label.attributedText = nameStr
            
            
        }
        
        
    }
    //MARK: - End
    //MARK: - IBAction
    @IBAction func toggleButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            toggleButton1.isUserInteractionEnabled = false
            toggleButton2.isUserInteractionEnabled = true
            toggleButton1.setTitleColor(UIColor.white, for: .normal)
            toggle1BorderView.isHidden = false
            toggleButton2.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle2BorderView.isHidden = true
        }else{
            toggleButton1.isUserInteractionEnabled = true
            toggleButton2.isUserInteractionEnabled = false
            toggleButton1.setTitleColor(Utility.hexStringToUIColor(hex: "00AFEF"), for: .normal)
            toggle1BorderView.isHidden = true
            toggleButton2.setTitleColor(UIColor.white, for: .normal)
            toggle2BorderView.isHidden = false
            
        }
        
        listTable.reloadData()
        
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        if isSeller{
            
            if !toggleButton1.isUserInteractionEnabled{
                
                if view1SelectedIndex > -1{
                    if let data =  addressArr![view1SelectedIndex] as? NSDictionary {
                        Utility.saveDictTodefaults(key: "soldBy", dataDict: data)
                    }
                }
                
            }else{
                
                if view2SelectedIndex > -1{
                    if let data =  addressArr![view2SelectedIndex] as? NSDictionary {
                        Utility.saveDictTodefaults(key: "shipFrom", dataDict: data)
                    }
                }
            }
            
        }else{
            
            if !toggleButton1.isUserInteractionEnabled{
                
                if view1SelectedIndex > -1{
                    if let data =  addressArr![view1SelectedIndex] as? NSDictionary {
                        Utility.saveDictTodefaults(key: "broughtBy", dataDict: data)
                    }
                }
                
            }else{
                
                if view2SelectedIndex > -1{
                    if let data =  addressArr![view2SelectedIndex] as? NSDictionary {
                        Utility.saveDictTodefaults(key: "shipTo", dataDict: data)
                    }
                }
                
            }
            
        }
        
        navigationController?.popViewController(animated: false)
        
    }
    
    
    @IBAction func addCustomAddressButtonPressed(_ sender: UIButton) {
        
        var addresstype = ""
        
        if isSeller{
            
            if !toggleButton1.isUserInteractionEnabled{
                addresstype = "soldBy"
            }else{
                addresstype = "shipFrom"
            }
        }else{
            
            if !toggleButton1.isUserInteractionEnabled{
                addresstype = "broughtBy"
            }else{
                addresstype = "shipTo"
            }
            
        }
        
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddCustomAddressView") as! AddCustomAddressViewController
        controller.addressType = addresstype
        self.navigationController?.pushViewController(controller, animated: false)
    }
    //MARK: - End
    //MARK: - Tableview Delegate and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return addressArr?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerAdressListCell") as! CustomerAdressListCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var addUuid:String?
        var selectedUuid:String?
        let dataDict:NSDictionary = addressArr?[indexPath.section] as! NSDictionary
        if let uuid = dataDict["uuid"] as? String {
            addUuid = uuid
        }
        if isSeller{
            if !toggleButton1.isUserInteractionEnabled{
                if let uuid = soldByData!["uuid"] as? String {
                    selectedUuid = uuid
                }
            }else{
                if let uuid = shipFromData!["uuid"] as? String {
                    selectedUuid = uuid
                }
            }
            
            
            
        }else{
            
            if !toggleButton1.isUserInteractionEnabled{
                if let uuid = broughtByData!["uuid"] as? String {
                    selectedUuid = uuid
                }
            }else{
                if let uuid = shipToData!["uuid"] as? String {
                    selectedUuid = uuid
                }
            }
            
        }
        
        if !toggleButton1.isUserInteractionEnabled{
            if view1SelectedIndex == indexPath.section || selectedUuid ?? "" == addUuid ?? "" {
                populateAddressView(data: dataDict, label: cell.customerAddressLabel, isSelected: true)
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
                cell.selectedTickButton.isSelected = true
            }else{
                populateAddressView(data: dataDict, label: cell.customerAddressLabel, isSelected: false)
                cell.selectedTickButton.isSelected = false
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")
            }
        }else{
            if view2SelectedIndex == indexPath.section || selectedUuid ?? "" == addUuid ?? "" {
                populateAddressView(data: dataDict, label: cell.customerAddressLabel, isSelected: true)
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
                cell.selectedTickButton.isSelected = true
            }else{
                populateAddressView(data: dataDict, label: cell.customerAddressLabel, isSelected: false)
                cell.selectedTickButton.isSelected = false
                cell.bgView.backgroundColor = Utility.hexStringToUIColor(hex: "E3F1F7")
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !toggleButton1.isUserInteractionEnabled{
            view1SelectedIndex = indexPath.section
        }else{
            view2SelectedIndex = indexPath.section
        }
        
        listTable.reloadData()
        
    }
    
    //MARK: - End
}

class CustomerAdressListCell: UITableViewCell
{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var customerAddressLabel: UILabel!
    @IBOutlet weak var selectedTickButton: UIButton!
    
    
    override func awakeFromNib() {
        
    }
}
