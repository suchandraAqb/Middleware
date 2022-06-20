
import UIKit

class FailedSerialSendQuarantineViewController: BaseViewController,UITextViewDelegate,SingleSelectDropdownDelegate,ConfirmationViewDelegate,AddAttachmentViewDelegate {
    
    var adjustmentType = ""
    @IBOutlet weak var adjustmentTypeButton: UIButton!
    
    @IBOutlet weak var selectSourceLocationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var referenceSubView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesSubView: UIView!
    
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
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
    
        
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var addAttachmentButtonView: UIView!
    @IBOutlet weak var addAttachmentButton: UIButton!
    @IBOutlet weak var attachmentListTable: UITableView!
    @IBOutlet weak var attachmentTableHeight: NSLayoutConstraint!
    @IBOutlet weak var countTextFiled:UITextField!
    @IBOutlet weak var countView:UIView!
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productUuidLabel: UILabel!
    @IBOutlet weak var productSerialLabel: UILabel!
    @IBOutlet weak var productLotLabel: UILabel!
    @IBOutlet weak var productGtinLabel: UILabel!
    @IBOutlet weak var productExpirationLabel: UILabel!
    
    
    @IBOutlet weak var confirmButton: UIButton!
    
    
    
    
    
    var allLocations:NSDictionary?
    var selectedLocationUuid:String?
    var selectedDesLocationUuid:String?
    var quaranTineAdjustmentList:Array<Any>?
    var storageAreas:Array<Any>?
    var shelfs:Array<Any>?
    var selectedStorageArea:NSDictionary?
    var selectedShelf:NSDictionary?
    var isStorageSelected = false
    var isShelfSelected = false
    var productCount = 0
    var serialCount = 0
    var itemsList:Array<Any>?
    
    var attachmentList = [[String:Any]]()
    var productDetailsDict = [String:Any]()
    
    //MARK: View Life Cyscle
    override func viewDidLoad() {
        super.viewDidLoad()
        getAdjustmentList()
        createInputAccessoryView()
        countTextFiled.text = "1"
//        createInputAccessoryViewAddedScan()
        setup_initialview()
        populateGeneralInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    //MARK: - End
    //MARK: - Private Method
    func setup_initialview(){
        Utility.populateMandatoryFieldsMark(mandatoryFieldLabels,fontFamily: "Poppins-Medium",size: 17.0,color:Utility.hexStringToUIColor(hex: "719898"))
        refTextField.addLeftViewPadding(padding: 15.0)
        refTextField.inputAccessoryView = inputAccView
        notesTextView.inputAccessoryView = inputAccView
        sectionView.roundTopCorners(cornerRadious: 40)
        quarantineToggleButtonPressed(quarantinePresetButton)
        allLocations = UserInfosModel.getLocations()
        quarantineNotesTextView.inputAccessoryView = inputAccView
        
        productView.setRoundCorner(cornerRadious: 10)
        locationView.setRoundCorner(cornerRadious: 10)
        reasonView.setRoundCorner(cornerRadious: 10)
        referenceView.setRoundCorner(cornerRadious: 10)
        notesView.setRoundCorner(cornerRadious: 10)
        attachmentView.setRoundCorner(cornerRadious: 10)
        addAttachmentButton.setRoundCorner(cornerRadious: addAttachmentButton.frame.height / 2.0)
        
        confirmButton.setRoundCorner(cornerRadious: confirmButton.frame.height / 2.0)
        
        locationSelectionView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantinePresetSubDropdownView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        quarantineNotesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        referenceSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        notesSubView.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        
        countTextFiled.setBorder(width: 1, borderColor: Utility.hexStringToUIColor(hex: "E3EAF3"), cornerRadious: 10.0)
        countView.setRoundCorner(cornerRadious: 10)
        countTextFiled.addLeftViewPadding(padding: 15.0)
        populateattachment()
        
        self.attachmentListTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    
    func populateattachment(){
        attachmentListTable.reloadSections([0], with: .fade)
        addAttachmentButtonView.isHidden = true
        if attachmentList.count < 5 {
            addAttachmentButtonView.isHidden = false
        }
    }
    
    deinit {
        self.attachmentListTable.removeObserver(self, forKeyPath: "contentSize")
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
    
    
    func getAdjustmentList(){
        let appendStr = "inventory_adjustments_reasons?Type=\(adjustmentType)"
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
    
    func saveData(){
        doneTyping()
        let otherDetailsDict = NSMutableDictionary()
        
        if let txt = locationNameLabel.accessibilityHint , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid")
        }
        
        if let txt = locationNameLabel.text , !txt.isEmpty {
            otherDetailsDict.setValue(txt, forKey: "location_uuid_name")
        }
        
        
        
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
        
        
        Utility.saveDictTodefaults(key: "adjustment_general_info", dataDict: otherDetailsDict)
    }
    func formValidation()->Bool{
        var isValidated = true
        if let dataDict = Utility.getDictFromdefaults(key: "adjustment_general_info") {
            let location = dataDict["location_uuid"] as? String ?? ""
            let quarantine = dataDict["reason_text"] as? String ?? ""
            
            if location.isEmpty {
                Utility.showPopup(Title: App_Title, Message: "Please select source Location.".localized(), InViewC: self)
                isValidated = false
            }else if quarantine.isEmpty && adjustmentType != Adjustments_Types.Dispense.rawValue{
                if adjustmentType == "MISC_ADJUSTMENT" {
                    Utility.showPopup(Title: App_Title, Message: "Please select/type".localized() + " " + "Missing / Stolen".localized() + " " +  "reason.".localized(), InViewC: self)
                }else{
                    Utility.showPopup(Title: App_Title, Message: "Please select/type".localized() + " \(adjustmentType) " + "reason.".localized(), InViewC: self)
                }
                isValidated = false
            }
        }else{
            isValidated = false
        }
        return isValidated
    }
    func populateGeneralInfo(){
        adjustmentTypeButton.setTitle("Quarantine".localized(), for: .normal)
        
        if let txt = productDetailsDict["product_name"] as? String {
            productNameLabel.text = txt
        }
        if let txt = productDetailsDict["product_uuid"] as? String {
            productUuidLabel.text = txt
        }
        if let txt = productDetailsDict["serial_number"] as? String {
            productSerialLabel.text = txt
        }
        if let txt = productDetailsDict["lot_number"] as? String {
            productLotLabel.text = txt
        }
        if let txt = productDetailsDict["gtin14"] as? String {
            productGtinLabel.text = txt
        }
        if let txt = productDetailsDict["expiration_date"] as? String {
            if let formattedDate = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy", dateStr: txt){
                productExpirationLabel.text = formattedDate
            }
        }
        
        
        if allLocations != nil {
            let allkeys = allLocations?.allKeys
            let firstStorage = allLocations![allkeys?.first as? String ?? ""]
            let button = UIButton()
            button.tag = 1
            selectedItem(itemStr: allkeys?.first as? String ?? "", data: firstStorage as! NSDictionary, sender: button)
        }
        quarantineToggleButtonPressed(quarantinePresetButton)
    }
    
    
    
    func checkIfProductAvailable() -> Bool{
        var product = 0
        var serial = 0
        var isProductAvailable = false
        
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = true")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                let uniqueArr = (arr as NSArray).value(forKeyPath: "@distinctUnionOfObjects.product_uuid")
                product = (uniqueArr as? Array<Any>)?.count ?? 0
            }
        }catch let error{
            print(error.localizedDescription)
        }
        do{
            let predicate = NSPredicate(format:"is_valid=true and is_lot_based = false")
            let serial_obj = try PersistenceService.context.fetch(Adjustments.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                let arr = Utility.convertCoreDataRequestsToJSONArray(moArray: serial_obj)
                serial = arr.count
            }
        }catch let error{
            print(error.localizedDescription)
        }
        if product > 0 || serial > 0 {
            isProductAvailable = true
        }
        return isProductAvailable
    }
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if !formValidation(){
            return
        }
        let msg = "You are about to send this product to Quarantine?".localized()
        let confirmAlert = UIAlertController(title: "Quarantine?".localized(), message: msg, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
       
        }
        confirmAlert.addAction(noAction)
        confirmAlert.addAction(yesAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
        
        
        
        
        saveData()
        
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
    
    @IBAction func locationSelectionButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        if allLocations == nil {
            return
        }
        
//        if sender.tag == 1 {
//            if checkIfProductAvailable(){
//                Utility.showPopup(Title: App_Title, Message: "There are item(s) attached to this location. Please remove those item(s) first from Items section to change location.".localized(), InViewC: self)
//                return
//            }
//        }
        
        let storyboard = UIStoryboard.init(name:"Main",bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = true
        controller.nameKeyName = "name"
        controller.listItemsDict = allLocations
        controller.delegate = self
        controller.type = "Locations".localized()
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    @IBAction func dropDownButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func quarantineReasonButtonPressed(_ sender: UIButton) {
        if quaranTineAdjustmentList == nil {
            return
        }
        
        let storyboard = UIStoryboard.init(name:"Main",bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
        controller.isDataWithDict = false
        controller.nameKeyName = "name"
        controller.listItems = quaranTineAdjustmentList as! [[String : Any]]
        controller.delegate = self
        controller.type = ""
        controller.sender = sender
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func quarantineBackButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name:"Main",bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure you want cancel Quarantine".localized()
        controller.delegate = self
        controller.isCancelConfirmation = true
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addAttachmentButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name:"Adjustments",bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddAttachmentView") as! AddAttachmentViewController
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
        textFieldTobeField = textField
        textViewTobeField = nil
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
        textViewTobeField = textView
        textFieldTobeField = nil
    }
    
    //MARK: - End
    
    //MARK: - SingleSelectDropdownDelegate
    func selectedItem(itemStr: String, data: NSDictionary,sender:UIButton?) {
        if sender != nil && sender!.tag == 1 {
            
            if let name = data["name"] as? String{
                locationNameLabel.text = name
                locationNameLabel.accessibilityHint = itemStr
                selectedLocationUuid = itemStr
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
    
    //MARK: - ConfirmationViewDelegate
    func doneButtonPressed() {
        
        
    }
    func cancelConfirmation() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - End
    
    
    //MARK: - Search View Delegate
    func attachmentAdd(attachmentDict:[String:Any]?) {
        self.attachmentList.append(attachmentDict!)
        populateattachment()
    }
    //MARK: End
    
    
}


//MARK: - Tableview Delegate and Datasource
extension FailedSerialSendQuarantineViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = attachmentListTable.dequeueReusableCell(withIdentifier: "FailedSerialsAttachmentCell") as! FailedSerialsAttachmentCell
        
        let dict = self.attachmentList[indexPath.row]
        
        var dataStr = ""
        if let txt = dict["fileName"] as? String,!txt.isEmpty{
            dataStr = txt
        }
        cell.attachmentNameLabel.text = dataStr
        
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



//MARK: - Tableview Cell
class FailedSerialsAttachmentCell: UITableViewCell {
    
    @IBOutlet weak var attachmentNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
}
extension FailedSerialSendQuarantineViewController:SingleScanViewControllerDelegate{
    internal func didReceiveBarcodeSingleScan(codeDetails:[String:Any]){
        if (textFieldTobeField != nil) {
            textFieldTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textFieldTobeField = nil

        }else{
            textViewTobeField?.text = (codeDetails["scannedCodes"] as! String)
            textViewTobeField = nil

        }
        
    }
}
//MARK: - End

