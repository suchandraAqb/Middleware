//
//  SerialRequestSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SerialRequestSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate  {

    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var serialsButton: UIButton!
    var serialsList = [Any]()
    var product_uuid = ""
    var lot_uuid = ""
    var request_uuid = ""
    var format = ""
       

   

   //MARK: - View Life Cycle
   override func viewDidLoad() {
       super.viewDidLoad()
       sectionView.roundTopCorners(cornerRadious: 40)
       getSerialRequestSerials()
        
   }
   //MARK: - End
    
    //MARK: - Private Method
    
    func getSerialRequestSerials(){
            
            let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials/\(request_uuid)/serials?serials_format=\(format)"
            self.showSpinner(onView: self.view)
            Utility.GETServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        
                            if let responseArr = responseData as? Array<Any> {
                                self.serialsList = responseArr
                                self.listTable.reloadData()
                            }
                        
                    }else{
                        
                        if responseData != nil{
                            let responseDict: NSDictionary = responseData as! NSDictionary
                            if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                                Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                            }else  if let errorMsg = responseDict["message"] as? String {
                                Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                            }else{
                                Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                            }
                            
                            
                        }else{
                            Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                        }
                        
                        
                    }
                    
                }
            }
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 5))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
                  
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return serialsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        var dataStr = ""
        
        if let txt = serialsList[indexPath.section] as? String {
            dataStr = txt
        }
        
        cell.productNameLabel.text = dataStr
        
        
        return cell
        
    }
    //MARK: - End
    

    

}
