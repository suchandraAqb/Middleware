//
//  SerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 27/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class SerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate  {

    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var serialsButton: UIButton!
    var serialsList:Array<Any>?
    var shipmentId:String?
    var itemUuid:String?
    var isOutbound = false

   //MARK: - View Life Cycle
   override func viewDidLoad() {
       super.viewDidLoad()
       sectionView.roundTopCorners(cornerRadious: 40)
       let headerNib = UINib.init(nibName: "SectionHeaderView", bundle: Bundle.main)
       listTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
       getSerialsList()
        
   }
   //MARK: - End
    
    //MARK: - Private Method
    func getSerialsList(){
        
        let appendStr:String! = (shipmentId ?? "") as String + "/products/" + (itemUuid ?? "") as String + "/serials"
        
        var type = "GetInboundSerials"
        if isOutbound {
            type = "GetOutboundSerials"
        }
        
        self.showSpinner(onView: self.view)
          Utility.GETServiceCall(type: type, serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
              DispatchQueue.main.async{
                  self.removeSpinner()
                  if isDone! {
                    
                    self.serialsList = responseData as? Array<Any>
                    
                    if self.serialsList != nil {
                        self.listTable.reloadData()
                    }
                }else{
                   if responseData != nil{
                      let responseDict: NSDictionary = responseData as! NSDictionary
                      let errorMsg = responseDict["message"] as! String
                       Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                       
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as! SectionHeaderView
        
        let dataDict:NSDictionary = serialsList?[section] as! NSDictionary
        
        if let name = dataDict["lot_no"]  as? String{
            headerView.lotNoLabel.text = name
        }
        
        
        let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
        
        if let exDate = dataDict["expiration_date"] as? String{
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-mm-dd", outputFormat: outputDateFormat, dateStr: exDate){
                headerView.expirationDateLabel.text = "Expiration Date".localized() + ": \(formattedDate)"
               
            }
        }
        
        
        
        if let serials:Array<Any> = dataDict["serial_no"] as? Array<Any> {
            headerView.quantityLabel.text = "\(serials.count)"
        }
        
        headerView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return serialsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let dataDict:NSDictionary = serialsList?[section] as! NSDictionary
        
        if let serials:Array<Any> = dataDict["serial_no"] as? Array<Any> {
            return serials.count
        }
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsTableViewCell") as! ItemsTableViewCell
        
        let sectionDict:NSDictionary = serialsList?[indexPath.section] as! NSDictionary
        if let serials:Array<Any> = sectionDict["serial_no"] as? Array<Any> {
            print(serials)
            if let serial_no = serials[indexPath.row] as? String{
                cell.productNameLabel.text = serial_no
            }else{
                cell.productNameLabel.text = String(describing: serials[indexPath.row])
            }
            
            
            if indexPath.row + 1 == serials.count {
                cell.layer.cornerRadius = 10
                cell.clipsToBounds = true
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }else{
                cell.layer.cornerRadius = 0
                cell.clipsToBounds = false
            }
             
        }
        
        
        return cell
        
    }
    //MARK: - End
    

    

}
