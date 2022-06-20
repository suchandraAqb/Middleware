//
//  PickingListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 22/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
@objc protocol participentReassignDelegate : class{
    @objc optional func didReassigned()
}
class ParticipentReassignViewController: BaseViewController {
    @IBOutlet weak var selectView:UIView!
    @IBOutlet weak var staffButton:UIButton!
    @IBOutlet weak var saveButton:UIButton!
    
    var delegate : participentReassignDelegate?
    var staffArr: NSArray?
    var pickingDict = NSDictionary()
    var selectedDict = NSDictionary()
    
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectView.setRoundCorner(cornerRadious: 20)
        staffButton.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "072144"), cornerRadious: 10)
        saveButton.setRoundCorner(cornerRadious: saveButton.frame.size.height/2)
        if let arr = Utility.getObjectFromDefauls(key: "staffMgtList"){
            self.staffArr = arr as? NSArray
        }
        if let staffname = pickingDict["participant_name"] as? String,!staffname.isEmpty{
            staffButton.setTitle(staffname, for: .normal)
        }
    }
    //MARK: - End
    
    //MARK: - Action
    
    @IBAction func crossButtonpressed(_ sender:UIButton){
        self.dismiss(animated: true)
    }
    @IBAction func dropDownButtonPressed(_ sender:UIButton){
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "DPLotBasedUpdatedView") as! DPLotBasedUpdatedViewController
        storyboard.isStaffList = true
        storyboard.delegate = self
        storyboard.staffarr = staffArr as? Array<Any>
        self.present(storyboard, animated: true, completion: nil)
    }
    @IBAction func saveButtonpressed(_ sender:UIButton){
        if let staffDetails = staffButton.titleLabel?.text,staffDetails.isEmpty{
            Utility.showPopup(Title:Warning, Message: "Please select participant for reassign.".localized(), InViewC: self)
            return
        }else if let staffDetails = staffButton.titleLabel?.text,!staffDetails.isEmpty{
            if staffDetails == pickingDict["participant_name"] as! String {
                Utility.showPopup(Title:Warning, Message: "Please choose different participant for reassign.".localized(), InViewC: self)
                return
            }
        }
        self.staffMgtParticipentReassignApiCall()
    }
    

    //MARK: - End
    
    //MARK: - Call API
    func staffMgtParticipentReassignApiCall(){

        var requestData = [String:Any]()
        requestData["participant_uuid"] = selectedDict["uuid"]
        
        let appendStr:String! = "/\(pickingDict["picking_uuid"] ?? "")/participant_reassign"
        self.showSpinner(onView: self.view)
        Utility.PUTServiceCall(type: "PickNewItem", serviceParam: requestData, parentViewC: UIViewController(), willShowLoader: false,viewController: BaseViewController(), appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    self.delegate?.didReassigned!()
                    self.dismiss(animated: true)

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
    //MARK: End
}

extension ParticipentReassignViewController:DPLotBasedUpdatedViewDelegate{
    func didSelectStaff(data:NSDictionary){
        if let staffName = data["full_name"] as? String,!staffName.isEmpty{
            selectedDict = data
            staffButton.setTitle(staffName, for: .normal)
        }
    }
}

