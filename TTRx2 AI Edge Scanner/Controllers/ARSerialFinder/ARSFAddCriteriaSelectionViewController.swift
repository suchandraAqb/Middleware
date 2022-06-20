//
//  ARSFAddCriteriaSelectionViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 07/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARSFAddCriteriaSelectionViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var detailsView: UIView!
    
    //,,,sb2
    @IBOutlet weak var productListTable: UITableView!
    @IBOutlet weak var productListTableHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var lotListTable: UITableView!
    @IBOutlet weak var lotListTableHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var inventoryListTable: UITableView!
    @IBOutlet weak var inventoryListTableHeightConstant: NSLayoutConstraint!

    var productListArray:Array<Any>?
    var lotListArray:Array<Any>?
    var inventoryListArray:Array<Any>?
    //,,,sb2
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        
        //,,,sb2
        productListTable.reloadData()
        lotListTable.reloadData()
        inventoryListTable.reloadData()
        //,,,sb2
        
        self.get_filter_options_WebserviceCall("Product")
        self.get_filter_options_WebserviceCall("Lot")
        self.get_filter_options_WebserviceCall("Inventory")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //,,,sb2
        self.productListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.lotListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.inventoryListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //,,,sb2
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //,,,sb2
        self.productListTable.removeObserver(self, forKeyPath: "contentSize")
        self.lotListTable.removeObserver(self, forKeyPath: "contentSize")
        self.inventoryListTable.removeObserver(self, forKeyPath: "contentSize")
        //,,,sb2
    }
    //MARK:- End
    
    //MARK: - IBAction
    
    //MARK:- End
    
    
    //MARK: - Privete Method
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.productListTable && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    self.productListTableHeightConstant.constant = newSize.height
                    self.updateViewConstraints()
                }
            }
            else if obj == self.lotListTable && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    self.lotListTableHeightConstant.constant = newSize.height
                    self.updateViewConstraints()
                }
            }
            else if obj == self.inventoryListTable && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    self.inventoryListTableHeightConstant.constant = newSize.height
                    self.updateViewConstraints()
                }
            }
        }
    }//,,,sb2
    //MARK:- End
    
    
    //MARK: - Webservice Call
    func get_filter_options_WebserviceCall(_ filter_sub_module:String) {
        let str = "SERIAL FINDER".addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let appendStr = "?filter_module=\(str ?? "")&filter_sub_module=\(filter_sub_module)"
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "get_filter_options", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let response = responseData as? Array<Any> {
                        if filter_sub_module == "Product" {
                            self.productListArray = response
                            self.productListTable.reloadData()
                        }
                        else if filter_sub_module == "Lot" {
                            self.lotListArray = response
                            self.lotListTable.reloadData()
                        }
                        else {
                            self.inventoryListArray = response
                            self.inventoryListTable.reloadData()
                        }
                    }
                }else {
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        
                        Utility.showAlertWithPopAction(Title: App_Title, Message: errorMsg, InViewC: self, isPop: true, isPopToRoot: false)
                        
                    }else{
                        Utility.showAlertWithPopAction(Title: App_Title, Message: message ?? "", InViewC: self, isPop: true, isPopToRoot: false)
                    }
                }
            }
        }
    }//,,,sb2
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = UIColor.clear
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width, height: 20))
        headerLabel.font = UIFont(name: "Poppins-SemiBold", size: 15.0)
        headerLabel.textColor = UIColor.black
        headerLabel.backgroundColor=UIColor.clear
        headerLabel.alpha = 1
        view.addSubview(headerLabel)
        
        //,,,sb2
        if (tableView == productListTable) {
            headerLabel.text = "Product".localized()//,,,sb-lang1
        }
        else if (tableView == lotListTable) {
            headerLabel.text = "Lot".localized()//,,,sb-lang1
        }
        else {
            headerLabel.text = "Inventory".localized()//,,,sb-lang1
        }
        //,,,sb2
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == productListTable) {
            return productListArray?.count ?? 0
        }
        else if (tableView == lotListTable) {
            return lotListArray?.count ?? 0
        }
        else {
            return inventoryListArray?.count ?? 0
        }
    }//,,,sb2
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == productListTable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFAddCriteriaSelectionTableViewCell") as! ARSFAddCriteriaSelectionTableViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.clipsToBounds = true
            
            let dict = self.productListArray![indexPath.row] as? NSDictionary
            var dataStr = ""
            if let txt = dict!["user_abbr"] as? String,!txt.isEmpty {
                dataStr = txt
            }
            cell.titleLabel.text = dataStr
            
            return cell
        }
        else if (tableView == lotListTable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFAddCriteriaSelectionTableViewCell") as! ARSFAddCriteriaSelectionTableViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.clipsToBounds = true
            
            let dict = self.lotListArray![indexPath.row] as? NSDictionary
            var dataStr = ""
            if let txt = dict!["user_abbr"] as? String,!txt.isEmpty {
                dataStr = txt
            }
            cell.titleLabel.text = dataStr
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARSFAddCriteriaSelectionTableViewCell") as! ARSFAddCriteriaSelectionTableViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.clipsToBounds = true
            
            let dict = self.inventoryListArray![indexPath.row] as? NSDictionary
            var dataStr = ""
            if let txt = dict!["user_abbr"] as? String,!txt.isEmpty {
                dataStr = txt
            }
            cell.titleLabel.text = dataStr
            
            return cell
        }
    }//,,,sb2
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            
            if (tableView == self.productListTable) {
                let dict = self.productListArray![indexPath.row] as? NSDictionary
//                print ("productList dict...",dict as Any) //,,,sb11-12
                
                var key = ""
                if let txt = dict!["key"] as? String,!txt.isEmpty {
                    key = txt
                }
                
                if (key == "PRODUCT_CATEGORY") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFCategoryCriteriaView") as! ARSFCategoryCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if (key == "PRODUCT_STATUS") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFStatusCriteriaView") as! ARSFStatusCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    var value_type = ""
                    if let txt = dict!["value_type"] as? String,!txt.isEmpty {
                        value_type = txt
                    }
                    
                    if (value_type == "date") {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFDateBoundaryCriteriaView") as! ARSFDateBoundaryCriteriaViewController
                        controller.isAdd = true //,,,sb11-1
                        controller.typeDict = dict //,,,sb11-1
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    else if (value_type == "boolean" || value_type == "int") {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFBooleanBasedCriteriaView") as! ARSFBooleanBasedCriteriaViewController
                        controller.isAdd = true //,,,sb11-1
                        controller.typeDict = dict //,,,sb11-1
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    else {
                        //text
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFTextBasedCriteriaView") as! ARSFTextBasedCriteriaViewController
                        controller.isAdd = true //,,,sb11-1
                        controller.typeDict = dict //,,,sb11-1
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
            else if (tableView == self.lotListTable) {
                let dict = self.lotListArray![indexPath.row] as? NSDictionary
//                print ("lotList dict...",dict as Any) //,,,sb11-12
                
                var value_type = ""
                if let txt = dict!["value_type"] as? String,!txt.isEmpty {
                    value_type = txt
                }
                
                if (value_type == "date") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFDateBoundaryCriteriaView") as! ARSFDateBoundaryCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if (value_type == "boolean" || value_type == "int") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFBooleanBasedCriteriaView") as! ARSFBooleanBasedCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    //text
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFTextBasedCriteriaView") as! ARSFTextBasedCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            else {
                let dict = self.inventoryListArray![indexPath.row] as? NSDictionary
//                print ("inventoryList dict...",dict as Any) //,,,sb11-12
                
                var value_type = ""
                if let txt = dict!["value_type"] as? String,!txt.isEmpty {
                    value_type = txt
                }
                
                if (value_type == "date") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFDateBoundaryCriteriaView") as! ARSFDateBoundaryCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if (value_type == "boolean" || value_type == "int") {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFBooleanBasedCriteriaView") as! ARSFBooleanBasedCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    //text
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARSFTextBasedCriteriaView") as! ARSFTextBasedCriteriaViewController
                    controller.isAdd = true //,,,sb11-1
                    controller.typeDict = dict //,,,sb11-1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }//,,,sb2
    //MARK:- End
}

class ARSFAddCriteriaSelectionTableViewCell:UITableViewCell{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var multiLingualViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if multiLingualViews != nil {
            Utility.UpdateUILanguage(multiLingualViews)
        }
    }
    
}
