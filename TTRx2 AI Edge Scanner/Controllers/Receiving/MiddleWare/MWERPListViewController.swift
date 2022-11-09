//
//  MWERPListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 15/07/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1 unused

import UIKit

class MWERPListViewController: BaseViewController {
    
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var erpListTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var erpListArray = [[String:Any]]()
    
    //MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWReceivingSelectionViewController") as! MWReceivingSelectionViewController
        controller.delegate = self
        controller.previousController = "MWERPListViewController"
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    //MARK: - End

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        nextButton.isHidden = true
        self.erpActionWebServiceCall()
    }
    //MARK: - End

    //MARK: - Webservice call
    func erpActionWebServiceCall(){
        /*
        Get Action Erps
        18a6c216-5320-4ab8-bec7-61a4eb2a9997
        https://cxi3hpbeyg.execute-api.us-east-1.amazonaws.com/prod/get-erps-in-action
        POST
        {
          "action_uuid": "18a6c216-5320-4ab8-bec7-61a4eb2a9997",
          "target_action": "185eb551-cb71-4d11-bfa3-31693d06163f",
          "sub": "e54c3361-4c43-400b-a1c1-c3f0cb28cf43"
        }
        */
        
        var requestDict = [String:Any]()
        requestDict["action_uuid"] = Utility.getActionId(type:"erpAction")
        requestDict["sub"] = defaults.object(forKey:"sub")
        requestDict["target_action"] = Utility.getActionId(type: "erpTargetAction")

        self.showSpinner(onView: self.view)
        Utility.POSTServiceCall(type: "ErpAction", serviceParam: requestDict as NSDictionary, parentViewC: self, willShowLoader: false, viewController: self,appendStr: "") { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let responseDict: NSDictionary = responseData as? NSDictionary{
                       let statusCode = responseDict["status_code"] as? Bool
                        
                        if statusCode! {
                            let erpArr = Utility.converJsonToArray(string: responseDict["data"] as! String)
                            if erpArr.count > 0 {
                                self.erpListArray = erpArr as! [[String:Any]]
                                for i in 0..<self.erpListArray.count{
                                    var erpDict = self.erpListArray[i]
                                    erpDict["po_uuid"] = ""
                                    self.erpListArray[i] = erpDict
                                }
                            }
                            self.erpListTableView.reloadData()

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
}

//MARK: - MWMultiScanViewControllerDelegate
extension MWERPListViewController : MWMultiScanViewControllerDelegate {
    
    func didScanCodeForReceiveSerialVerification(scannedCode:[String]) {
        //Add Api here
        print("didScanCodeForReceiveSerialVerification....>>",scannedCode)
    }
    func backFromMultiScan() {
    }
}
//MARK: - End

//MARK: - MWSingleScanViewControllerDelegate
extension MWERPListViewController : MWSingleScanViewControllerDelegate {
    
    func didSingleScanCodeForReceiveSerialVerification(scannedCode:[String]) {
        //Add Api here
        print("didSingleScanCodeForReceiveSerialVerification....>>",scannedCode)
    }
    func backFromSingleScan() {
    }
}
//MARK: - End

//MARK: - MWReceivingSelectionViewControllerDelegate
extension MWERPListViewController: MWReceivingSelectionViewControllerDelegate {
    func didClickOnCamera(){
        if(defaults.bool(forKey: "IsMultiScan")){
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWMultiScanViewController") as! MWMultiScanViewController
            controller.sectionName = "CreateSOByPicking" //,,,sb16-1
            controller.isForReceivingSerialVerificationScan = true
            controller.isForPickingScanOption = true
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "MWSingleScanViewController") as! MWSingleScanViewController
            controller.delegate = self
            controller.isForReceivingSerialVerificationScan = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didClickManually(){
        
    }
    func didClickCrossButton() {
        
    }
}
//MARK: - End

/*
//MARK: - MWPuchaseOrderListViewControllerDelegate
extension MWERPListViewController: MWPuchaseOrderListViewControllerDelegate {
    func didSelectMWPuchaseOrder(detailsDict:MWPuchaseOrderModel?, erpUUID:String) {
        if (detailsDict != nil) {
            if let uuid = detailsDict!.uniqueID , !uuid.isEmpty {
                if let indexNo : Int = erpListArray.firstIndex(where: {$0["erp_uuid"] as? String == erpUUID}) {
                    var erpDict = self.erpListArray[indexNo]
                    erpDict["po_uuid"] = uuid
                    self.erpListArray[indexNo] = erpDict
                }
            }
        }
        erpListTableView.reloadData()

        if !erpListArray.contains(where: {$0["po_uuid"] as? String == ""}) {
            nextButton.isHidden = false
        }else {
            nextButton.isHidden = true
        }
    }
}
//MARK: - End
*/

//MARK: - UITableViewDataSource & UITableViewDelegate
extension MWERPListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return erpListArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ERPListTableViewCell") as! ERPListTableViewCell

        let dict = erpListArray[indexPath.section]
        var erpName = ""
        if let erp_name = dict["erp_name"] as? String , !erp_name.isEmpty {
            erpName = erp_name
        }
        cell.erpNameLabel.text = erpName
        
        cell.cellContainerView.backgroundColor = UIColor.white
        cell.erpNameLabel.textColor = Utility.hexStringToUIColor(hex: "276A44")
        cell.arrowButton.isSelected = false
        
        if let po_uuid = dict["po_uuid"] as? String , !po_uuid.isEmpty {
            cell.cellContainerView.backgroundColor = Utility.hexStringToUIColor(hex: "71D29B")
            cell.erpNameLabel.textColor = UIColor.white
            cell.arrowButton.isSelected = true
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        let dict = erpListArray[indexPath.section]
        let storyboard = UIStoryboard.init(name: "MWReceiving", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MWPuchaseOrderListViewController") as! MWPuchaseOrderListViewController
        /*
        controller.delegate = self
        controller.erpDict = dict
        */
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
//MARK: - End

class ERPListTableViewCell : UITableViewCell {
    @IBOutlet weak var erpNameLabel:UILabel!
    @IBOutlet weak var arrowButton:UIButton!
    @IBOutlet weak var cellContainerView: UIView!
    
    override func awakeFromNib() {
    }
}
