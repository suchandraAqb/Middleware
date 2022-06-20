//
//  UnQuarantineGeneralViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by rupshikha anand on 02/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
//GET
//​/adjustments​/{adjustment_uuid}
//Get one Inventory Adjustment
class UnQuarantineGeneralViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate, ConfirmationViewDelegate,AddAttachmentViewDelegate  {
   
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var referenceSubView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesSubView: UIView!
    
    @IBOutlet weak var quarantineUUIDLabel: UILabel!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var quarantinePresetButton: UIButton!
    @IBOutlet weak var quarantineOtherButton: UIButton!
    @IBOutlet weak var quarantinePresetDropdownView: UIView!
    @IBOutlet weak var quarantinePresetSubDropdownView: UIView!
    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var quarantineNotesView: UIView!
    @IBOutlet weak var quarantineNotesSubView: UIView!
    @IBOutlet weak var quarantineNotesTextView: UITextView!
    @IBOutlet var mandatoryFieldLabels: [UILabel]!
    
    //MARK: Step Items
    @IBOutlet weak var step1Button: UIButton!
    @IBOutlet weak var step2Button: UIButton!
    @IBOutlet weak var step3Button: UIButton!
    @IBOutlet weak var step1BarView: UIView!
    @IBOutlet weak var step2BarView: UIView!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var attachmentListTable: UITableView!
    @IBOutlet weak var addAttachmentButtonView: UIView!
    @IBOutlet weak var addAttachmentButton: UIButton!
    @IBOutlet weak var attachmentTableHeight: NSLayoutConstraint!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var countTextFiled:UITextField!
    @IBOutlet weak var countView:UIView!
    //MARK: - End
    
    var allLocations:NSDictionary?
    var selectedReasonUuid:String?
    var quaranTineAdjustmentList:Array<Any>?
    var itemsList = [String : Any]()
    var productArray: [[String: Any]] = []
    var structureArray: [[String: Any]] = []
    var adjustmentLineItems: [[String: Any]] = []
    var type: String?
    var attachmentList = [[String:Any]]()

    
    //MARK: View Life Cyscle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        removeQuarantineDefaults()
        createInputAccessoryView()
        setup_initialview()
        setup_data()
        getAdjustmentList(type: "UN-QUARANTINE")
        getAdjectmentDetails()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateGeneralInfo()
        setup_stepview()
    }
    //MARK: - End
    //MARK: - Private Method
    func setup_data(){
        self.quarantineUUIDLabel.text = (itemsList["uuid"] as? String) ?? ""
    }
    func setup_initialview(){
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 16.0,color:Utility.hexStringToUIColor(hex: "719898"))
        refTextField.addLeftViewPadding(padding: 15.0)
        refTextField.inputAccessoryView = inputAccView
        notesTextView.inputAccessoryView = inputAccView
        sectionView.roundTopCorners(cornerRadious: 40)
        quarantineToggleButtonPressed(quarantinePresetButton)
        //  allLocations = UserInfosModel.getLocations()
        quarantineNotesTextView.inputAccessoryView = inputAccView
        
        locationView.setRoundCorner(cornerRadious: 10)
        reasonView.setRoundCorner(cornerRadious: 10)
        referenceView.setRoundCorner(cornerRadious: 10)
        notesView.setRoundCorner(cornerRadious: 10)
        attachmentView.setRoundCorner(cornerRadious: 10)
        addAttachmentButton.setRoundCorner(cornerRadious: addAttachmentButton.frame.height / 2.0)

        quarantinePresetSubDropdownView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantineNotesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        referenceSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        notesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        countView.setRoundCorner(cornerRadious: 10)
        countTextFiled.addLeftViewPadding(padding: 15.0)
        countTextFiled.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        self.attachmentListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.attachmentListTable && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    
                    self.attachmentTableHeight.constant = newSize.height
                    self.attachmentListTable.invalidateIntrinsicContentSize()
                    self.attachmentListTable.layoutIfNeeded()
                    
                }
            }
        }
    }
    func setup_stepview(){
        let isFirstStepCompleted = defaults.bool(forKey: "un_quaran_1stStep")
        let isSecondStepCompleted = defaults.bool(forKey: "un_quaran_2ndStep")
        
        
        step1Button.isUserInteractionEnabled = false
        step2Button.isUserInteractionEnabled = false
        step3Button.isUserInteractionEnabled = false
        
        step1Button.setImage(UIImage(named: activeStepButtonImgStr), for: .normal)
        step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
        
        
        step1Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
        step2Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step3Label.textColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        step2BarView.backgroundColor = Utility.hexStringToUIColor(hex: inActiveColorStr)
        
        
        if isFirstStepCompleted && isSecondStepCompleted{
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            
            step2Label.textColor = Utility.hexStringToUIColor(hex: activeFontColorStr)
            step1BarView.backgroundColor = Utility.hexStringToUIColor(hex: activeColorStr)
            step2Button.isUserInteractionEnabled = true
            step3Button.isUserInteractionEnabled = true
            
        }else if isFirstStepCompleted {
            //step1Button.setImage(UIImage(named: completedStepButtonImgStr), for: .normal)
            step2Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            step3Button.setImage(UIImage(named: inActiveStepButtonImgStr), for: .normal)
            
            step2Button.isUserInteractionEnabled = true
        }
        
        
    }
    
    func saveData(){
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if quarantinePresetButton.isSelected{
            if let txt = presetNameLabel.accessibilityHint , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "reason_uuid")
                
                if let txt = presetNameLabel.text , !txt.isEmpty {
                    otherDetailsDict.setValue(txt, forKey: "reason_text")
                }
            }
            
            
        }else{
            if let txt = quarantineNotesTextView.text , !txt.isEmpty {
                otherDetailsDict.setValue(txt, forKey: "reason_text")
            }
        }
        
        if let txt = refTextField.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "reference_num")
        }
        
        if let txt = notesTextView.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "notes")
        }
        
        
        Utility.saveDictTodefaults(key: "unquaratine_general_info", dataDict: otherDetailsDict)
    }
    
    
    func formValidation()->Bool{
        var isValidated = true
        if let dataDict = Utility.getDictFromdefaults(key: "unquaratine_general_info") {
            
            let quarantine = dataDict["reason_text"] as? String ?? ""
            if quarantine.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select/type Un-Quarantine reason.".localized(), InViewC: self)
                isValidated = false
            }
        }
        
        
        return isValidated
        
    }
    func populateGeneralInfo(){
        
        if let dataDict = Utility.getDictFromdefaults(key: "unquaratine_general_info") {
            

            if let txt =  dataDict["reason_uuid"] as? String, !txt.isEmpty{
                presetNameLabel.accessibilityHint = txt
                
                if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                    presetNameLabel.text = txt
                }
                
                quarantineToggleButtonPressed(quarantinePresetButton)
                
                
                
            }else if let txt =  dataDict["reason_text"] as? String, !txt.isEmpty{
                quarantineNotesTextView.text = txt
                quarantineToggleButtonPressed(quarantineOtherButton)
            }
         
             
             
             if let txt =  dataDict["unquaratine_reference_num"] as? String, !txt.isEmpty{
                 refTextField.text = txt
             }
         
         
             if let txt =  dataDict["unquaratine_notes"] as? String, !txt.isEmpty{
                 notesTextView.text = txt
             }
            
        }
        
        if !itemsList.isEmpty {
            let itemCount = itemsList["items_count"] as! Int
            let productCount = itemsList["products_count"] as! Int
            
            var productStr = ""
            if productCount>1 {
                productStr = "Items"
            }else{
                productStr = "Item"
            }
            var itemstr = ""
            if itemCount>1 {
                itemstr = "Products"
            }else{
                itemstr = "Product"
            }
            
            countTextFiled.text = "\(itemCount)" + " \(productStr) , " + "\(productCount)" + " \(itemstr)."
        }
    }

    func removeQuarantineDefaults(){
        defaults.removeObject(forKey: "un_quaran_1stStep")
        defaults.removeObject(forKey: "un_quaran_2ndStep")
        defaults.removeObject(forKey: "unquaratine_general_info")
        defaults.removeObject(forKey: "adjustment_uuid")
        defaults.removeObject(forKey: "adjustmentLineItems")
        defaults.removeObject(forKey: "selectedItems")
        defaults.removeObject(forKey: "unquarantineLocation")
        
    }
    
    func populateattachment(){
        attachmentListTable.reloadSections([0], with: .fade)
        addAttachmentButtonView.isHidden = true
        if attachmentList.count < 5 {
            addAttachmentButtonView.isHidden = false
        }
    }
    //MARK: - End
    
    //MARK: - Search View Delegate
    func attachmentAdd(attachmentDict:[String:Any]?) {
        self.attachmentList.append(attachmentDict!)
        populateattachment()
    }
    //MARK: End
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Un-Quarantine".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        saveData()
        if !formValidation(){
            return
        }
        defaults.set((itemsList["uuid"] as? String) ?? "", forKey: "adjustment_uuid")
        defaults.set(true, forKey: "un_quaran_1stStep")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineItemView") as! UnQuarantineItemViewController
        controller.attachmentList = attachmentList
       self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func editIconPressed(_ sender: UIButton) {
          
          let btn = UIButton()
          btn.tag = 1
          stepButtonsPressed(btn)
          
      }
    @IBAction func stepButtonsPressed(_ sender: UIButton) {
        if sender.tag == 2 {
            nextButtonPressed(UIButton())
            
        }else if sender.tag == 3 {
            saveData()
            if !formValidation(){
                return
            }
            
           let controller = self.storyboard?.instantiateViewController(withIdentifier: "UnQuarantineConfirmView") as! UnQuarantineConfirmViewController
           self.navigationController?.pushViewController(controller, animated: false)
            
        }
    }
    @IBAction func quarantineToggleButtonPressed(_ sender: UIButton) {
        doneTyping()
        if sender.isSelected{
            return
        }
        
        if sender == quarantinePresetButton {
            quarantinePresetButton.isSelected = true
            quarantineOtherButton.isSelected = false
            quarantinePresetDropdownView.isHidden = false
            quarantineNotesView.isHidden = true
        }else{
            quarantinePresetButton.isSelected = false
            quarantineOtherButton.isSelected = true
            quarantinePresetDropdownView.isHidden = true
            quarantineNotesView.isHidden = false
        }
        
    }
    @IBAction func quarantineReasonButtonPressed(_ sender: UIButton) {
        if quaranTineAdjustmentList == nil {
            return
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = quaranTineAdjustmentList as! [[String : Any]]
        controller.delegate = self
        controller.type = ""
        controller.sender = sender
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addAttachmentButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddAttachmentView") as! AddAttachmentViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func attachmentDeleteButtonPressed(_ sender: UIButton) {
        
        let msg = "You are about to delete the resource.".localized() + "\n" + "This operation can’t be undone.".localized() + "\n\n" + "Proceed to the deletion?".localized()
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            
            let obj = self.attachmentList[sender.tag]
            
            if (self.attachmentList as NSArray).contains(obj) {
                let index = (self.attachmentList as NSArray).index(of: obj)
                self.attachmentList.remove(at: index)
                
                self.populateattachment()
            }
            
            
        })
        
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    //MARK: - End
    
    //MARK: - textField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputAccView
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    //MARK: - End
    
    //MARK: - textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.inputAccessoryView = inputAccView
    }
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            
            if let name = data["name"] as? String{
                presetNameLabel.text = name
                presetNameLabel.accessibilityHint = itemStr
                selectedReasonUuid = itemStr
            }
            
        }
        
    }
    
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 4 {
            
            if let name = data["name"] as? String{
                presetNameLabel.text = name
                
                if let uuid = data["uuid"] as? String {
                    presetNameLabel.accessibilityHint = uuid
                }
                
            }
        }
    }
    //MARK: - End
    
    // MARK: - Webservice Call
    func getAdjustmentList(type:String){
        let appendStr = "inventory_adjustments_reasons?Type=\(type)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "Company_Mgmt", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    if let response = responseData as? NSDictionary{
                        
                        if let dataArr = response["data"] as? Array<Any>{
                            self.quaranTineAdjustmentList = dataArr
                            
                        }
                    }
                    
                    
                }else{
                    
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
        
    }
    
    
   
    func getAdjectmentDetails() {
        let appendStr = (itemsList["uuid"] as? String) ?? ""
        ///adjustments/{adjustment_uuid}/
        
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetQuarantineList", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        print("Adjustmentitems: \(responseDict)")
                        
                        if let location = responseDict["location"] as? [String: Any] {
                            defaults.set(location["uuid"] ?? "" , forKey: "unquarantineLocation")
                        }
                        
                        if let adjustmentLineItems = responseDict["adjustmentLineItem"] as? [[String:Any]] {
                            Utility.saveObjectTodefaults(key: "adjustmentLineItems", dataObject: adjustmentLineItems)
                            
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
    
   //MARK: - ConfirmationViewDelegate
   func doneButtonPressed() {
       
   }
   func cancelConfirmation() {
       self.navigationController?.popToRootViewController(animated: true)
   }
   //MARK: - End
  
    
}

//MARK: - Tableview Delegate and Datasource
extension UnQuarantineGeneralViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    private func configureCell(at indexPath: IndexPath) ->UITableViewCell {
        let cell = attachmentListTable.dequeueReusableCell(withIdentifier: "AttachmentCell") as! AttachmentCell
        
        let dict = self.attachmentList[indexPath.row]
        
        var dataStr = ""
        if let txt = dict["fileName"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.attachmentNameLabel.text = dataStr
        
        cell.typeButton.isUserInteractionEnabled = false//,,,sb10
        cell.typeButton.isHighlighted = false
        
        if let txt = dict["fileType"] as? String,!txt.isEmpty{
            if txt == "Picture" {
                cell.typeButton.isHighlighted = true
            }else if txt == "Video" {
                cell.typeButton.isSelected = false
            }else if txt == "Document" {
                cell.typeButton.isSelected = true
            }
        }
        
        
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
}

//MARK: - End

