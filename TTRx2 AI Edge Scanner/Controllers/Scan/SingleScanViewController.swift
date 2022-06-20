//
//  SingleScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 03/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import ScanditBarcodeCapture

@objc protocol SingleScanViewControllerDelegate: class {
    @objc optional func didSingleScanCompleteForEndPointURL(urlString:String)
    @objc optional func didSingleScanCodeForReceive(codeDetails:[String : Any])
    @objc optional func didSingleScanCodeForReceiveSerialVerification(scannedCode:[String])
    @objc optional func didSingleScanCodeForRemoveMultiple(willBeRemovedSerials:[String])
    @objc optional func didSingleScanCodeForReturnShipmentSearch(codeDetails:[String : Any])
    @objc optional func didSingleScanCodeForScanAggreation(codeDetails: [String : Any],productName:String,productGtIn14:String,lotnumber:String,serialnumber:String,expirationdate:String)

    @objc optional func didSingleScanCodeForReturnSerialVerification(scannedCode:[String], condition : String)
    @objc optional func didSingleScanCodeForReturnSerialVerification(scannedCode:[[String:String]])
    
    @objc optional func didSingleScanCodeForInventoryCount(scannedCode:[String])
    @objc optional func didSingleScanCodeForManualInboundShipment(scannedCode:[String])
    
    @objc optional func didReceiveBarcodeSingleScan(codeDetails:[String : Any])
    
    @objc optional func didReceiveBarcodeLocationScan(codeDetails:[String : Any])
    @objc optional func didLotBasedTriggerScanDetails(arr : NSArray)
    @objc optional func didSingleScanCodeForFailedSerial(scannedCode : [String])
    @objc optional func didScanErrorMsgInTrigger_singlescan(msg:String)
    @objc optional func triggerScanFailedForSingleScan(failedArr : [[String:Any]])
    @objc optional func didScanPickingFilterOption(verifiedItem:[[String:Any]])

}

class SingleScanViewController: BaseViewController, ConfirmationViewDelegate {
    
    weak var delegate: SingleScanViewControllerDelegate?
    
    fileprivate var scannedCodes: Set<String> = []
    fileprivate var removedCodes: Set<String> = []
    fileprivate var scannedReturnCodes: Set<[String : String]> = []
    fileprivate var scannedReturnLotCodes: Set<String> = []
    
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!
    
    var isForEndPointURLScan: Bool = false
    var isForReceivingSerialVerificationScan: Bool = false
    var isFromAggregation :Bool = false
    
    var isForMultiRemove: Bool = false
    var isForInventory: Bool = false
    var isReturnShipmentSearch: Bool = false
    var isForReturnSerialVerificationScan: Bool = false
    var isForManualInbound: Bool = false
    var isFromBarCodeCpature:Bool = false
    var isFromPickingSingleItemScan:Bool = false

    var isForLocationSelection:Bool = false

    var isFromAddAggreationScan: Bool = false
    
    var isForOnlyReceive : Bool = false

    /////////////////////////////////////BOTTOM SHEET/////////////////////////////
    public var isForBottomSheetScan: Bool = false
    private var isForBottomSheetLotScan: Bool = false
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var tblProduct: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    
    //    @IBOutlet var btnCounter: [UIButton]!
    private var productCount = 0
    private var arrLotProductList : [ProductListModel]?
    
    
    @IBOutlet weak var returnConditionView: UIView!
    @IBOutlet weak var resalableButton: UIButton!
    @IBOutlet weak var quarantineButton: UIButton!
    @IBOutlet weak var destructButton: UIButton!
    var returnCondition: String = Return_Serials.Condition.Resalable.rawValue
    
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noOfScannedSerials: UILabel!
    
    @IBOutlet weak var upDownArrowButton:UIButton!
    @IBOutlet weak var itemscountStackView:UIStackView!
    @IBOutlet weak var tableviewHeightConstant:NSLayoutConstraint!
    
    @IBOutlet weak var containerButton : UIButton!
    @IBOutlet weak var productButton:UIButton!
    
    fileprivate var failedScan : Set<String> = []

    var lineItemsArr : Array<Any>?
    var isReceiveProductInshipment:Bool!
    var failedItems = Array<Dictionary<String,Any>>()
    var verifiedArr = Array<Dictionary<String,Any>>()
    
    var dpProductList : Array<Any>?
    var isproductMatchInDpItems : Bool = false
    
    var containerProductCheckingArr = NSMutableArray()
    var isForPickingScanOption:Bool = false
    var isContainerScanEnable:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodes = []
        scannedReturnCodes = []
        scannedReturnLotCodes = []
        sectionView.roundTopCorners(cornerRadious: 40)
        setupRecognition()
        self.tblProduct.delegate = self
        self.tblProduct.dataSource = self
        self.tblProduct.separatorStyle = .none
        //self.tblProduct.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        if isForBottomSheetScan {
            itemscountStackView.isHidden = true
            tableviewHeightConstant.constant = 0
            upDownArrowButton.isSelected = false
            lblHeader.text = "Add items to your list"
            self.addDetailsView()
        }
        if isForPickingScanOption{
            containerButton.isHidden = false
            productButton.isHidden = false
            isContainerScanEnable = false
            containerButton.alpha = 0.5
            productButton.alpha = 1
            containerButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
            containerButton.setTitleColor(UIColor.white, for: .normal)
            productButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
            productButton.setTitleColor(UIColor.white, for: .normal)
            
        }else{
            
            containerButton.isHidden = true
            productButton.isHidden = true
            
          
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          AllProductsModel.AllProductsShared.getAllProducts { (isDone:Bool?) in
        }
        unfreeze()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if failedItems.count > 0 && isForBottomSheetScan {
            self.delegate?.triggerScanFailedForSingleScan!(failedArr: self.failedItems)
        }
        freeze()
    }
    
    deinit {
        //self.tblProduct.removeObserver(self, forKeyPath: "contentSize")
        if(isForInventory || isForReceivingSerialVerificationScan || isForReturnSerialVerificationScan) || isForBottomSheetScan || isForOnlyReceive || isproductMatchInDpItems{
            barcodeCapture.isEnabled = false
        }
    }
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func returnConditionButtonPressed(_ sender: UIButton) {
        if(!sender.isSelected){
            if(sender == resalableButton){
                resalableButton.isSelected = true
                quarantineButton.isSelected = false
                destructButton.isSelected = false
                returnCondition = Return_Serials.Condition.Resalable.rawValue
            }else if(sender == quarantineButton){
                resalableButton.isSelected = false
                quarantineButton.isSelected = true
                destructButton.isSelected = false
                returnCondition = Return_Serials.Condition.Quarantine.rawValue
            }else if(sender == destructButton){
                resalableButton.isSelected = false
                quarantineButton.isSelected = false
                destructButton.isSelected = true
                returnCondition = Return_Serials.Condition.Destruct.rawValue
            }
            for item in scannedReturnCodes {
                var itemDict = item
                itemDict["condition"] = returnCondition
                itemDict["code"] = itemDict["code"]!
                scannedReturnCodes.remove(item)
                scannedReturnCodes.insert(itemDict)
            }
        }
    }
    @IBAction func toggleFreezing(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            freeze()
        } else {
            unfreeze()
        }
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if (isForReceivingSerialVerificationScan || isForOnlyReceive || isproductMatchInDpItems){
            if isForPickingScanOption {
                
                if isContainerScanEnable{
                    let predicate = NSPredicate(format: "type == 'PRODUCT'")
                    let filterArr = containerProductCheckingArr.filtered(using: predicate)
                    if filterArr.count > 0 {
                        Utility.showPopup(Title: App_Title, Message: "Please Scan Container Only.", InViewC: self)
                        containerProductCheckingArr.removeAllObjects()
                        scannedCodes.removeAll()
                        self.populateItemsCount(isRemove: false)
                        return
                    }else{
                        self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                        self.navigationController?.popViewController(animated: true)

                    }
                }else{
                    let predicate = NSPredicate(format: "type == 'CONTAINER'")
                    let filterArr = containerProductCheckingArr.filtered(using: predicate)
                    if filterArr.count > 0 {
                        Utility.showPopup(Title: App_Title, Message: "Please Scan Product Only.", InViewC: self)
                        containerProductCheckingArr.removeAllObjects()
                        scannedCodes.removeAll()
                        self.populateItemsCount(isRemove: false)

                        return
                    }else{
                        self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                        self.navigationController?.popViewController(animated: true)

                    }
                }
            }else{
                self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                self.navigationController?.popViewController(animated: true)
            }
            if isForOnlyReceive {
                self.delegate?.didSingleScanCodeForFailedSerial?(scannedCode: Array(self.failedScan))
            }
        }else if(isFromAggregation){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
        }else if (isForReturnSerialVerificationScan){
            self.navigationController?.popViewController(animated: true)
            // self.delegate?.didSingleScanCodeForReturnSerialVerification?(scannedCode: Array(self.scannedCodes), condition: returnCondition)
            self.delegate?.didSingleScanCodeForReturnSerialVerification?(scannedCode: Array(self.scannedReturnCodes))
        }else if(isForMultiRemove){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didSingleScanCodeForRemoveMultiple?(willBeRemovedSerials: Array(self.removedCodes))
        }else if(isForInventory){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didSingleScanCodeForInventoryCount?(scannedCode: Array(self.scannedCodes))
            
        }else if isForManualInbound{
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didSingleScanCodeForManualInboundShipment?(scannedCode: Array(self.scannedCodes))
        }
    }
    
    @IBAction func backAction(_ sender: UIButton){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmationView") as! ConfirmationViewController
        controller.confirmationMsg = "Are you sure want to cancel scanning?".localized()
        controller.delegate = self
        controller.isCancelConfirmation = false
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    func doneButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupRecognition() {
        DispatchQueue.main.async { [self] in
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed
        
        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)
        
        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommenededCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommenededCameraSettings)
        
        // The barcode capturing process is configured through barcode capture settings
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeCaptureSettings()
        
        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.locationSelection = RadiusLocationSelection(radius:.zero)
            if isForPickingScanOption{
                settings.codeDuplicateFilter = 1
            }else{
                settings.codeDuplicateFilter = -1

            }
        let symbologySettings = settings.settings(for: .dataMatrix)
        symbologySettings.isColorInvertedEnabled = true
        
        // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
        // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
        // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
        // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        //        let symbologySettings = settings.settings(for: .code39)
        //        symbologySettings.activeSymbolCounts = Set(7...20) as Set<NSNumber>
        
        
        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)
        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)
        
        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        captureView = DataCaptureView(context: context, frame: sectionView.bounds)
        captureView.addControl(TorchSwitchControl())
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sectionView.addSubview(captureView)
        
        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        
        overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture)
        if !isForOnlyReceive {
            overlay.brush = .highlighted
        }else{
           // overlay.brush = .clear
        }
        overlay.shouldShowScanAreaGuides = false
        overlay.viewfinder = LaserlineViewfinder()
        captureView.addOverlay(overlay)
        
        if (isForReceivingSerialVerificationScan || isForInventory || isForReturnSerialVerificationScan || isForManualInbound || isForOnlyReceive || isproductMatchInDpItems){
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: false)
        }else if(isForMultiRemove) {
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: true)
        }else{
            self.doneButton.isHidden = true
            self.noOfScannedSerials.isHidden = true
        }
        returnConditionView.isHidden = !isForReturnSerialVerificationScan
        }
    }
    @IBAction func arrowButtonPressed(_ sender: UIButton) {
//        upDownArrowButton.isSelected = !upDownArrowButton.isSelected
        if upDownArrowButton.isSelected {
            upDownArrowButton.isSelected = false
            itemscountStackView.isHidden = true
            tableviewHeightConstant.constant = 0
        }else{
            upDownArrowButton.isSelected = true
            itemscountStackView.isHidden = false
            tableviewHeightConstant.constant = 200
        }
            
    }
    @IBAction func containerOrProductScan(_ sender:UIButton){
        if sender.tag == 1 {
            isContainerScanEnable = false
            containerButton.alpha = 0.5
            productButton.alpha = 1
            
            containerButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
            containerButton.setTitleColor(UIColor.white, for: .normal)
            productButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
            productButton.setTitleColor(UIColor.white, for: .normal)
        }else{
            isContainerScanEnable = true
            containerButton.alpha = 1
            productButton.alpha = 0.5
            containerButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
            containerButton.setTitleColor(UIColor.white, for: .normal)
            productButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
            productButton.setTitleColor(UIColor.white, for: .normal)
            
        }
    }
    // MARK: - Private Function
    private func populateItemsCount(isRemove : Bool){
        var count = ""
        var msg = ""
        if(isRemove){
            count = "\(String(describing: self.removedCodes.count))"
            msg = "\(Int(count)!>1 ?"serials" : "serial") will be removed".localized()
        }else{
            count = "\(String(describing: self.scannedCodes.count))"
            msg = "\(Int(count)!>1 ?"serials" : "serial") scanned".localized()
        }
        
        let noCountAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!]
        let noCountString = NSMutableAttributedString(string: count , attributes: noCountAttributes)
        
        let msgAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0)!]
        
        let msgStr = NSAttributedString(string: "\n\(msg)", attributes: msgAttributes)
        noCountString.append(msgStr)
        
        noOfScannedSerials.attributedText = noCountString
        
    }
    private func showResult(_ result: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func freeze() {
        // First, disable barcode tracking to stop processing frames.
        if(!isForInventory && !isForReceivingSerialVerificationScan && !isForReturnSerialVerificationScan && !isForOnlyReceive || isproductMatchInDpItems){
            barcodeCapture.isEnabled = false
        }
        // Switch the camera off to stop streaming frames. The camera is stopped asynchronously.
        camera?.switch(toDesiredState: .off)
    }
    
    private func unfreeze() {
        DispatchQueue.main.async { [self] in
        // First, enable barcode tracking to resume processing frames.
        barcodeCapture.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        camera?.switch(toDesiredState: .on)
        }
    }
    // MARK: - End
    private func checkitems(productindentifier:String,gtin14:String,lotNumber:String,Productname:String,expirationDate:NSString,code:NSString){
        let lineitem = lineItemsArr! as NSArray
        let predicate : NSPredicate
        if gtin14 == "" {
             predicate = NSPredicate(format: "ndc = '\(productindentifier)'")
            
        }else{
             predicate = NSPredicate(format: "gtin14 = '\(gtin14)'")

        }
        let arr = lineitem.filtered(using: predicate)

            if arr.count>0 {
                let dict = arr.first as! NSDictionary
                if dict["name"] as! String == Productname {
                    if (dict["lots"] as? NSArray != nil){
                    let lotsArray = dict["lots"] as! NSArray
                    let predicate = NSPredicate(format: "lot_number = '\(lotNumber)'")
                    let filterArr = lotsArray.filtered(using: predicate)
                if filterArr.count>0 {
                    if !self.scannedCodes.contains(code as String) {
                        self.scannedCodes.insert(code as String)
                        isReceiveProductInshipment = true
                        var data = [String:String]()
                        data["code"] = code as String
                        data["condition"] = self.returnCondition
                        self.scannedReturnLotCodes.insert(code as String)
                        self.scannedReturnCodes.insert(data)

                        }
                }else{
                     if !failedScan.contains(code as String){
                         failedScan.insert(code as String)
                     }
             }

                }else{
                    if !self.scannedCodes.contains(code as String) {
                        self.scannedCodes.insert(code as String)
                        isReceiveProductInshipment = true
                        var data = [String:String]()
                        data["code"] = code as String
                        data["condition"] = self.returnCondition
                        self.scannedReturnLotCodes.insert(code as String)
                        self.scannedReturnCodes.insert(data)

                        }
                    }
                }else{
                   if !failedScan.contains(code as String){
                        failedScan.insert(code as String)
                    }
                }
                self.populateItemsCount(isRemove: false)

            }else{
                if !failedScan.contains(code as String){
                    failedScan.insert(code as String)
                }
            }
       }
    }

// MARK: - BarcodeCaptureListener

extension SingleScanViewController: BarcodeCaptureListener {
    
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let code = barcode.data, !code.isEmpty else {
                return
            }
//            let details = UtilityScanning(with:code).decoded_info
//            if details.count <= 0 {
//                return 
//            }
            if(self.isForMultiRemove){
                if !self.removedCodes.contains(code) {
                    self.removedCodes.insert(code)
                }
                self.populateItemsCount(isRemove: true)
            }else if(self.isFromBarCodeCpature){
                print(code)
                if !self.scannedCodes.contains(code) {
                    self.scannedCodes.insert(code)
                }
                self.navigationController?.popViewController(animated: true)
                self.delegate?.didReceiveBarcodeSingleScan?(codeDetails: ["scannedCodes":code])
                
            }else if(self.isFromPickingSingleItemScan){
                self.getGS1BarcodeLookupDetails(serials: code, productName: "", uuid: "", productGtin14: "", lotNumber: "")

            }else if self.isForBottomSheetScan{
                let details = UtilityScanning(with:code).decoded_info
                if details.count > 0 {
                    var containerSerialNumber = ""
                    var productName = ""
                    var gtin14 = ""
                    var serialNumber = ""
                    var lotNumber = ""
                    var uuid = ""
                    var expirationDate = ""
                    var productIdentifier = ""

                    if(details.keys.contains("00")){
                        if let cSerial = details["00"]?["value"] as? String{
                            containerSerialNumber = cSerial
                        }else if let cSerial = details["00"]?["value"] as? NSNumber{
                            containerSerialNumber = "\(cSerial)"
                        }
                    }else{

                        if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                            if !allproducts.isEmpty  {
                                if(details.keys.contains("01")){
                                    
                                    if let gtin14Value = details["01"]?["value"] as? String{
                                        let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14Value }
                                        print(filteredArray as Any)
                                        if filteredArray.count > 0 {
                                            gtin14 = gtin14Value
                                            productName = (filteredArray.first?["name"] as? String)!
                                            uuid = (filteredArray.first?["uuid"] as? String)!
                                        }else{
                                            let productDict = Utility.gtin14ToNdc(gtin14str: gtin14Value)
                                            
                                                if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                    productName = product_name
                                                }
                                                if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                    productIdentifier = product_identifier
                                                }
                                                if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
                                                    uuid = product_uuid
                                                }
                                            if productIdentifier.isEmpty{
                                                Utility.showPopup(Title: App_Title, Message: "Product not found", InViewC: self)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(details.keys.contains("10")){
                            if let lot = details["10"]?["value"] as? String{
                                lotNumber = lot
                            }
                        }
                        if(details.keys.contains("21")){
                            if let serial = details["21"]?["value"] as? String{
                                serialNumber = serial
                            }
                        }
                        if (details.keys.contains("17")) {
                            if let expiration = details["17"]?["value"] as? String{
                                let splitarr = expiration.split(separator: "T")
                                if splitarr.count>0{
                                    expirationDate = String(splitarr[0])
                                }
                            }
                        }
                        if (self.lineItemsArr != nil) && !self.lineItemsArr!.isEmpty{
                            let lineitem = self.lineItemsArr! as NSArray
                            let predicate : NSPredicate
                            if gtin14 == "" {
                                 predicate = NSPredicate(format: "ndc = '\(productIdentifier)'")
                                
                            }else{
                                 predicate = NSPredicate(format: "gtin14 = '\(gtin14)'")

                            }
                            let arr = lineitem.filtered(using: predicate)

                                if arr.count>0 {
                                    let dict = arr.first as! NSDictionary
                                    if dict["name"] as! String == productName {
                                        if (dict["lots"] as? NSArray != nil){
                                        let lotsArray = dict["lots"] as! NSArray
                                        let predicate = NSPredicate(format: "lot_number = '\(lotNumber)'")
                                        let filterArr = lotsArray.filtered(using: predicate)
                                    if filterArr.count>0 {
                                        if !self.scannedCodes.contains(code as String) {
                                            self.scannedCodes.insert(code as String)
                                            self.isReceiveProductInshipment = true
                                            var data = [String:String]()
                                            data["code"] = code as String
                                            data["condition"] = self.returnCondition
                                            self.scannedReturnLotCodes.insert(code as String)
                                            self.scannedReturnCodes.insert(data)

                                            }
                                    }else{
                                        if !self.failedScan.contains(code as String){
                                            self.failedScan.insert(code as String)
                                         }
                                        self.isReceiveProductInshipment = false

                                 }

                                    }else{
                                        if !self.scannedCodes.contains(code as String) {
                                            self.scannedCodes.insert(code as String)
                                            self.isReceiveProductInshipment = true
                                            var data = [String:String]()
                                            data["code"] = code as String
                                            data["condition"] = self.returnCondition
                                            self.scannedReturnLotCodes.insert(code as String)
                                            self.scannedReturnCodes.insert(data)

                                            }
                                        }
                                    }else{
                                        if !self.failedScan.contains(code as String){
                                            self.failedScan.insert(code as String)
                                        }
                                        self.isReceiveProductInshipment = false

                                    }
                                    self.populateItemsCount(isRemove: false)

                                }else{
                                    if !self.failedScan.contains(code as String){
                                        self.failedScan.insert(code as String)
                                    }
                                    self.isReceiveProductInshipment = false

                                }
                            self.delegate?.didSingleScanCodeForFailedSerial?(scannedCode: Array(self.failedScan))

                            if self.isReceiveProductInshipment != nil && self.isReceiveProductInshipment {
                                self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotNumber)

                            }
                        } else{
                                 if !self.scannedCodes.contains(code) {
                                       self.scannedCodes.insert(code)
                                       var data = [String:String]()
                                       data["code"] = code
                                       data["condition"] = self.returnCondition
                                       self.scannedReturnLotCodes.insert(code)
                    
                                     self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotNumber)
                                 }
                         }
                 }
           }
        }else if(self.isForLocationSelection){
                print(code)
                if !self.scannedCodes.contains(code) {
                    self.scannedCodes.insert(code)
                }
                self.navigationController?.popViewController(animated: true)
                self.delegate?.didReceiveBarcodeLocationScan?(codeDetails: ["scannedCodes":code])
            }else if(self.isForOnlyReceive){
                let details = UtilityScanning(with:code).decoded_info
                if details.count > 0 {
                    var containerSerialNumber = ""
                    var productName = ""
                    var gtin14 = ""
                    var productIdentifier = ""
                    var serialNumber = ""
                    var lotNumber = ""
                    var expirationDate = ""
                    if(details.keys.contains("00")){
                        if let cSerial = details["00"]?["value"] as? String{
                            containerSerialNumber = cSerial
                        }else if let cSerial = details["00"]?["value"] as? NSNumber{
                            containerSerialNumber = "\(cSerial)"
                        }
                    }else{

                        if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                            if !allproducts.isEmpty  {
                                if(details.keys.contains("01")){
                                    
                                    if let gtin14Value = details["01"]?["value"] as? String{
                                        let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14Value }
                                        print(filteredArray as Any)
                                        if filteredArray.count > 0 {
                                            gtin14 = gtin14Value
                                            productName = (filteredArray.first?["name"] as? String)!
                                        }else{
                                            let productDict = Utility.gtin14ToNdc(gtin14str: gtin14Value)
                                            
                                                if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                    productName = product_name
                                                }
                                                if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                    productIdentifier = product_identifier
                                                }
                                            if productIdentifier.isEmpty{
                                                Utility.showPopup(Title: App_Title, Message: "Product not found", InViewC: self)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(details.keys.contains("10")){
                            if let lot = details["10"]?["value"] as? String{
                                lotNumber = lot
                            }
                        }
                        if(details.keys.contains("21")){
                            if let serial = details["21"]?["value"] as? String{
                                serialNumber = serial
                            }
                        }
                        if (details.keys.contains("17")) {
                            if let expiration = details["17"]?["value"] as? String{
                                let splitarr = expiration.split(separator: "T")
                                if splitarr.count>0{
                                    expirationDate = String(splitarr[0])
                                }
                            }
                        }
                        self.checkitems(productindentifier:productIdentifier,gtin14: gtin14, lotNumber: lotNumber,Productname: productName,expirationDate: expirationDate as NSString,code: code as NSString)
                    }
                }
            
        
            }else if(self.isForInventory || self.isForReturnSerialVerificationScan || self.isForReceivingSerialVerificationScan){
                
                if !self.scannedCodes.contains(code) {
                    self.scannedCodes.insert(code)
                    
                    var data = [String:String]()
                    data["code"] = code
                    data["condition"] = self.returnCondition
                    self.scannedReturnLotCodes.insert(code)
                    self.scannedReturnCodes.insert(data)
                }
                self.populateItemsCount(isRemove: false)
                let details = UtilityScanning(with:code).decoded_info
                if details.count > 0 {
                  if(details.keys.contains("00")){
                    if self.isForPickingScanOption {
                        let dict = NSMutableDictionary()
                        dict.setValue("CONTAINER", forKey: "type")
                        dict.setValue(code, forKey: "Value")
                        if !self.containerProductCheckingArr.contains(dict){
                            self.containerProductCheckingArr.add(dict)
                            }
                        }
                    }else{
                        if self.isForPickingScanOption {
                            let dict = NSMutableDictionary()
                            dict.setValue("PRODUCT", forKey: "type")
                            dict.setValue(code, forKey: "Value")
                            if !self.containerProductCheckingArr.contains(dict){
                                self.containerProductCheckingArr.add(dict)
                            }
                        }
                    }
                }
            }else if(self.isForEndPointURLScan){
                barcodeCapture.isEnabled = false
                guard let scannedUrl = URL(string:code) else {
                    Utility.showPopup(Title: "Error!", Message: "Not a valid url. Please try again.".localized(), InViewC: self)
                    self.barcodeCapture.isEnabled = true
                    return
                }
                let msg = "Do you want to proceed with this url?".localized() + "\n\n\(scannedUrl.absoluteString)"
                
                let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (UIAlertAction) in
                    self.barcodeCapture.isEnabled = true
                })
                let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didSingleScanCompleteForEndPointURL!(urlString: scannedUrl.absoluteString)
                })
                confirmAlert.addAction(cancelAction)
                confirmAlert.addAction(okAction)
                self.navigationController?.present(confirmAlert, animated: true, completion: nil)
                
            }else if self.isForManualInbound{
                print(code)
                if !self.scannedCodes.contains(code) {
                    self.scannedCodes.insert(code)
                    
                    var data = [String:String]()
                    data["code"] = code
                    data["condition"] = self.returnCondition
                    
                }
                self.populateItemsCount(isRemove: false)
                
            }else if self.isproductMatchInDpItems {
                var containerSerialNumber = ""
                var productName = ""
                var gtin14 = ""
                var uuid = ""
                var expirationDate = ""
                var productIdentifier = ""
                let details = UtilityScanning(with:code).decoded_info

                if(details.keys.contains("00")){
                    if let cSerial = details["00"]?["value"] as? String{
                        containerSerialNumber = cSerial
                    }else if let cSerial = details["00"]?["value"] as? NSNumber{
                        containerSerialNumber = "\(cSerial)"
                    }
                }else{

                    if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                        if !allproducts.isEmpty  {
                            if(details.keys.contains("01")){
                                
                                if let gtin14Value = details["01"]?["value"] as? String{
                                    let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14Value }
                                    print(filteredArray as Any)
                                    if filteredArray.count > 0 {
                                        gtin14 = gtin14Value
                                        productName = (filteredArray.first?["name"] as? String)!
                                        uuid = (filteredArray.first?["uuid"] as? String)!
                                    }else{
                                        let productDict = Utility.gtin14ToNdc(gtin14str: gtin14Value)
                                        
                                            if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                productName = product_name
                                            }
                                            if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                productIdentifier = product_identifier
                                            }
                                            if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
                                                uuid = product_uuid
                                            }
                                        if productIdentifier.isEmpty{
    //                                        Utility.showPopup(Title: App_Title, Message: "Product not found", InViewC: self)
                                        }
                                    }
                                }
                            }
                        }
                    }
                   
                    if (details.keys.contains("17")) {
                        if let expiration = details["17"]?["value"] as? String{
                            let splitarr = expiration.split(separator: "T")
                            if splitarr.count>0{
                                expirationDate = String(splitarr[0])
                                    }
                                }
                            }
                    
                    let arr = NSMutableArray()
                    arr.addObjects(from: self.dpProductList!)
                    let predicate = NSPredicate(format: "product_name = '\(productName)'")
                    let filterArr = arr.filtered(using: predicate)
                    
                    if filterArr.count > 0{
                        if let dict = filterArr.first as? NSDictionary{
                            let quantity = dict["quantity_to_pick"] as? NSString

                            if !self.scannedCodes.contains(code as String){
                                self.scannedCodes.insert(code as String)
                            }
                            if self.scannedCodes.count > 0 {
                                self.doneButton.isHidden = false
                                self.noOfScannedSerials.isHidden = false
                                self.populateItemsCount(isRemove: false)
                            }
                            if quantity?.intValue == 1{
                                self.dpProductList?.removeFirst()
                            }else{
                                let value:Int = Int(quantity!.intValue) - 1
                                if value > 0 {
                                    var tempdict = NSMutableDictionary()
                                    if let dict = self.dpProductList?.first as? NSDictionary{
                                        tempdict = dict.mutableCopy() as! NSMutableDictionary
                                    }
                                    tempdict.setValue("\(value)", forKey: "quantity_to_pick")
                                    
                                    let tempdproductList = NSMutableArray()
                                    tempdproductList.addObjects(from: self.dpProductList!)
                                    tempdproductList.replaceObject(at: 0, with: tempdict)
                                    
                                    self.dpProductList = tempdproductList.mutableCopy() as? Array<Any>
                                }
                            }
                        }
                    }
                }
            }else{
                barcodeCapture.isEnabled = false
                let details = UtilityScanning(with:code).decoded_info
                print(details as NSDictionary)
                if details.count > 0 {
                    var containerSerialNumber = ""
                    var productName = ""
                    var productGtin14 = ""
                    var serialNumber = ""
                    var lotNumber = ""
                    var expirationDate = ""
                    if(details.keys.contains("00")){
                        if let cSerial = details["00"]?["value"] as? String{
                            containerSerialNumber = cSerial
                        }else if let cSerial = details["00"]?["value"] as? NSNumber{
                            containerSerialNumber = "\(cSerial)"
                        }
                    }else{
                        if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                            if !allproducts.isEmpty  {
                                if(details.keys.contains("01")){
                                    if let gtin14 = details["01"]?["value"] as? String{
                                        productGtin14 = gtin14
                                        let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
                                        print(filteredArray as Any)
                                        if filteredArray.count > 0 {
                                            productName = (filteredArray.first?["name"] as? String)!
                                        }
                                    }
                                }
                            }
                        }
                        if(details.keys.contains("10")){
                            if let lot = details["10"]?["value"] as? String{
                                lotNumber = lot
                            }
                        }
                        
                        if (details.keys.contains("17")){
                            if let expirationdate = details["17"]?["value"] as? String{
                                expirationDate = expirationdate
                            }
                        }
                        if(details.keys.contains("21")){
                            if let serial = details["21"]?["value"] as? String{
                                serialNumber = serial
                            }
                        }
                    }
                    
                    print(containerSerialNumber,"\n",productName,"\n",productGtin14,"\n",lotNumber,"\n",serialNumber)
                    
                    var msg = ""
                    if containerSerialNumber.isEmpty{
                        if(!productName.isEmpty){
                            msg = "\(productName)\n"
                        }
                        if(!productGtin14.isEmpty){
                            msg = "\(msg)GTIN : \(productGtin14)\n"
                        }
                        if(!serialNumber.isEmpty){
                            msg = "\(msg)SLNo : \(serialNumber)\n"
                        }
                        if(!lotNumber.isEmpty){
                            msg = "\(msg)LotNo : \(lotNumber)\n"
                        }
                        
                    }else{
                        msg = "Container Serial Number : \(containerSerialNumber)\n"
                    }
                    if msg.isEmpty{
                        let confirmAlert = UIAlertController(title: "Error".localized(), message: "Product is not valid", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler: { (UIAlertAction) in
                            self.barcodeCapture.isEnabled = true
                        })
                        confirmAlert.addAction(okAction)
                        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
                    }else{
                            if self.isReturnShipmentSearch{
                                msg = "\(msg) \n" + "Do you want to proceed with this Return?".localized()
                            }else{
                                msg = "\(msg) \n" + "Do you want to proceed with this code?".localized()
                            }
                            
                            let confirmAlert = UIAlertController(title: "Confirm".localized(), message: msg, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (UIAlertAction) in
                                self.barcodeCapture.isEnabled = true
                            })
                            let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
                                self.barcodeCapture.isEnabled = false
                                self.camera?.switch(toDesiredState: .off)
                                self.navigationController?.popViewController(animated: true)
                                if(self.isReturnShipmentSearch){
                                    self.delegate?.didSingleScanCodeForReturnShipmentSearch?(codeDetails: ["scannedCode" : code])
                                }else if(self.isFromAddAggreationScan){
                                }else if(self.isFromAggregation){
                                    self.delegate?.didSingleScanCodeForScanAggreation?(codeDetails: ["scannedCode" : code], productName: productName, productGtIn14: productGtin14, lotnumber: lotNumber, serialnumber: serialNumber, expirationdate: expirationDate)
                                }else{
                                    self.delegate?.didSingleScanCodeForReceive?(codeDetails: ["scannedCode" : code])
                                }
                                
                            })
                            confirmAlert.addAction(cancelAction)
                            confirmAlert.addAction(okAction)
                            self.navigationController?.present(confirmAlert, animated: true, completion: nil)
                        
                    }
                }else{
                    let confirmAlert = UIAlertController(title: App_Title, message: "Product is not valid".localized(), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok".localized(), style: .cancel, handler: { (UIAlertAction) in
                        self.barcodeCapture.isEnabled = true
                    })
                    confirmAlert.addAction(okAction)
                    self.navigationController?.present(confirmAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
extension SingleScanViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrLotProductList?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.selectionStyle = .none
        (cell.btnPlus.tag, cell.btnMinus.tag, cell.btnDelete.tag, cell.btnCount.tag,cell.bigPlusButton.tag) = (indexPath.row, indexPath.row, indexPath.row, indexPath.row,indexPath.row)
        if arrLotProductList!.count > 0 {
            btnClear.isHidden = false
            self.btnConfirm.isHidden = false
        }else{
            btnClear.isHidden = true
            self.btnConfirm.isHidden = true

        }
        if isForBottomSheetLotScan {
            cell.btnPlus.isHidden = false
            cell.btnMinus.isHidden = false
            cell.bigPlusWeightconstant.constant = 60
            cell.minusButtonConst.constant = 25
        }else{
            cell.btnPlus.isHidden = true
            cell.btnMinus.isHidden = true
            cell.bigPlusWeightconstant.constant = 0
            cell.minusButtonConst.constant = 0


        }
        cell.bigPlusButton.showsTouchWhenHighlighted = true

        let item = self.arrLotProductList?[indexPath.row]
        
        cell.lblProductName.text = item?.productName
        //cell.lblProductCount.text = "\(item?.productCount ?? 0)"
        cell.btnCount.setTitle("\(item?.productCount ?? 0)", for: .normal)
        //cell.lblGTIN.text = item?.productGtin14
        //cell.lblLot.text = item?.lotNumber
        
        //        cell.quantityLabel.text = "\(item?.productCount ?? 0)"
        return cell
    }
    
    //    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //        if let obj = object as? UITableView {
    //            if obj == self.tblProduct && keyPath == "contentSize" {
    //                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
    //                    if self.productCount == 1{
    //                        self.heightTableView.constant = newSize.height
    //                        self.tblProduct.invalidateIntrinsicContentSize()
    //                        UIView.animate(withDuration: 0.3, animations: {
    //                            self.tblProduct.layoutIfNeeded()
    //                        })
    //                    }
    //                }
    //            }
    //        }
    //    }
}
extension SingleScanViewController{
    
    @IBAction func updateProductCount(_ sender: UIButton){
        
        let popUpAlert = UIAlertController(title: "Update quantity", message: "", preferredStyle: .alert)
        var addedTextField = UITextField()
        popUpAlert.addTextField { (textField : UITextField!) -> Void in
            addedTextField = textField
            textField.text = self.arrLotProductList?[sender.tag].productCount?.description
            textField.keyboardType = .numberPad
        }
        
        let okAction = UIAlertAction(title: "Update".localized(), style: .cancel, handler: {_ in
            self.arrLotProductList?[sender.tag].productCount = Int(addedTextField.text!)
            self.tblProduct.reloadSections([0], with: .automatic)
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
        
        popUpAlert.addAction(okAction)
        popUpAlert.addAction(cancelAction)
        
        self.present(popUpAlert, animated: true, completion: nil)
    }
    
    @IBAction func increaseProduct(_ sender: UIButton){
        print("Plus")
        self.arrLotProductList?[sender.tag].productCount! += 1
        self.tblProduct.reloadSections([0], with: .automatic)
    }
    
    @IBAction func done(_ sender: UIButton){
        
        self.removeDetailsView(completionHandler: {_ in
                self.addTriggerScanitemsinDatabase()
                self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func removeAll(_ sender: UIButton){
        Utility.showAlertDefaultWithPopAction(Title: "Alert".localized(), Message: "Are you sure you want to delete all items?", InViewC: self) {
            self.arrLotProductList?.removeAll()
            self.scannedCodes.removeAll()
            self.tblProduct.reloadSections([0], with: .automatic)
            self.lblHeader.text = "Add items to your list"
            self.setupAfterAddScreen()       //  self.removeDetailsView()
        }
    }
    
    @IBAction func deleteProduct(_ sender: UIButton){
        
        Utility.showAlertDefaultWithPopAction(Title: "Alert".localized(), Message: "Are you sure you want to delete this item?", InViewC: self) {
            let dict = self.arrLotProductList![sender.tag]
           
            for code in self.scannedCodes {
                let details = UtilityScanning(with:code).decoded_info
                if details.count > 0 {
                    var productGtin14 = ""
                if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
                    if !allproducts.isEmpty  {
                        if(details.keys.contains("01")){
                            if let gtin14 = details["01"]?["value"] as? String{
                            productGtin14 = gtin14
                            let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
                            print(filteredArray as Any)
                                if filteredArray.count > 0 {
                                    _ = (filteredArray.first?["name"] as? String)!
                            }
                        }
                    }
                }
            }
            if(details.keys.contains("10")){
                if let lot = details["10"]?["value"] as? String{
                    _ = lot
                 }
            }
                    if productGtin14 == dict.productGtin14 {
                        if self.scannedCodes.contains(code){
                            self.scannedCodes.remove(code)
                        }
                    }
                }
            }
            self.arrLotProductList?.remove(at: sender.tag)
            self.tblProduct.reloadSections([0], with: .automatic)
            if self.arrLotProductList?.count ?? 0 == 0{
                self.lblHeader.text = "Add items to your list"
                self.setupAfterAddScreen()
               // self.removeDetailsView()
            }
        }
    }
    
    @IBAction func decreaseProduct(_ sender: UIButton){
        print("Minus")
        self.arrLotProductList?[sender.tag].productCount ?? 0 > 1 ? (self.arrLotProductList?[sender.tag].productCount! -= 1) : ()
        self.tblProduct.reloadSections([0], with: .automatic)
    }
    
    
    private func setupAfterAddScreen(){
        
        if lblHeader.text == "Add items to your list"{
            self.btnConfirm.isHidden = true
            self.btnClear.isHidden = true
        }else{
            self.btnConfirm.isHidden = false
            self.btnClear.isHidden = false

        }
        //self.tblProduct.reloadSections([0], with: .automatic)
        //        self.lblHeader.text = productCount > 1 ? "\(productCount) items" : "\(productCount) item"
    }
    
    private func addDetailsView(){
        
        DispatchQueue.global(qos: .userInteractive).sync {
            let height = UIScreen.main.bounds.height*0.52
            let frame = CGRect(x: 0, y: UIScreen.main.bounds.height+height, width: UIScreen.main.bounds.width, height: height)
            self.detailsView.frame = frame
            self.detailsContainerView.roundTopCorners(cornerRadious: 20)
            self.view.addSubview(self.detailsView)
            
            UIView.animate(withDuration: 0.3, animations: {
                let frame = CGRect(x: 0, y: UIScreen.main.bounds.height-height, width: UIScreen.main.bounds.width, height: height)
                self.detailsView.frame = frame
            },
            completion: {(value: Bool) in
                self.setupAfterAddScreen()
            })
        }
    }
    
    private func removeDetailsView(completionHandler: ((_ isComplete:Bool?) -> Void)? = nil){
        
        DispatchQueue.global(qos: .userInteractive).sync {
            let height = UIScreen.main.bounds.height*0.52
            let frame = CGRect(x: 0, y: UIScreen.main.bounds.height+height, width: UIScreen.main.bounds.width, height: height)
            self.detailsView.frame = frame
            
            UIView.animate(withDuration: 0.3, animations: {
                self.detailsView.frame = frame
            },
            completion: {(value: Bool) in
                
                self.detailsView.removeFromSuperview()
                if let handler = completionHandler{
                    handler(true)
                }
                //self.barcodeCapture.isEnabled = true
                //self.navigationController?.popViewController(animated: true)
            })
            
        }
    }
    
    private func getGS1BarcodeLookupDetails(serials : String, productName: String, uuid: String, productGtin14: String, lotNumber: String){
        //self.showSpinner(onView: self.captureView)
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?gs1_barcode=\(str ?? "")"
            
            Utility.GETServiceCall(type: "GS1BarcodeLookup", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { [self] (responseData:Any?, isDone:Bool?, message:String?) in
                // DispatchQueue.main.async{
              //  self.removeSpinner()
                if isDone! {
                    let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                    print(responseArray as NSArray)
                    if responseArray.count > 0{
                        if let serialDetailsArray = responseArray as? [[String : Any]]{
                            
                            let verifiedItem = serialDetailsArray.first
                            
                            if self.isFromPickingSingleItemScan {
                                if !(self.verifiedArr as NSArray).contains(verifiedItem!){
                                    self.verifiedArr.append(verifiedItem!)
                                    self.navigationController?.popViewController(animated: true)
                                    self.delegate?.didScanPickingFilterOption!(verifiedItem: self.verifiedArr)
                                    return
                                }
                            }
                            
                            if verifiedItem?["status"] as? String == "LOT_FOUND"{
                               
                                self.isForBottomSheetLotScan = true
                                
                                if self.arrLotProductList?.count ?? 0 == 0{
                                    
                                    self.addDetailsView()
                                    self.arrLotProductList = [ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber , code : serials)]
                                    
                                }else{
                                    
                                    if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                                        self.arrLotProductList?[index].productCount! += 1
                                        
                                    }else{
                                        self.arrLotProductList?.append(ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code: serials))
                                    }
                                }
                                
                                self.tblProduct.reloadSections([0], with: .automatic)
                                self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
                                
                                
                            }else if verifiedItem?["status"] as? String == "FOUND"{
                            
                                self.isForBottomSheetLotScan = false
                                
                                if self.arrLotProductList?.count ?? 0 == 0{
                                    
                                    self.addDetailsView()
                                    self.arrLotProductList = [ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber , code : serials)]
                                    
                                }else{
                                    
                                    if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                                        self.arrLotProductList?[index].productCount! += 1
                                        
                                    }else{
                                        self.arrLotProductList?.append(ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code: serials))
                                    }
                                }
                                
                                self.tblProduct.reloadSections([0], with: .automatic)
                                self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
                                
                                
                            
//                                self.doneButton.isHidden = false
//                                self.noOfScannedSerials.isHidden = false
//                                self.isForReceivingSerialVerificationScan = true
//                               // self.isForOnlyReceive = true
//                                if !self.scannedCodes.contains(serials) {
//                                    self.scannedCodes.insert(serials)
//
//                                    var data = [String:String]()
//                                    data["code"] = serials
//                                    data["condition"] = self.returnCondition
//                                    self.scannedReturnLotCodes.insert(serials)
//
//                                }
//                                self.populateItemsCount(isRemove: false)
                            }else if verifiedItem?["status"] as? String == "FOUND"{
                                
                                print("ERROR ::: ALREADY LOT PRODUCT ADDED TO SESSION")
                            }else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                if !(self.failedItems as NSArray).contains(verifiedItem!){
                                    self.failedItems.append(verifiedItem!)
                                }
                            }
                            self.barcodeCapture.isEnabled = true
                            //self.verifiedSerials.append(contentsOf: serialDetailsArray)
                            
                            //                            //Lot Based
                            //                            let lotBased = serialDetailsArray.filter({$0["status"] as? String == "LOT_FOUND"})
                            //
                            //                            self.verifiedLotSerials.append(contentsOf: lotBased)
                            
                            //print("",self.verifiedSerials)
                            //self.refreshProductView()
                        }
                    }else{
                        Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                    }
                }else{
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        let errorMsg = responseDict["message"] as? String ?? ""
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        
                    }else{
                       // Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
                
                //                self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
                //
                //                let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
                //
                //                if first.count > 0 {
                //                    self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedCode: scannedCode)
                //                }else{
                //                    self.removeSpinner()
                //                    self.updateLotBasedSerialsToDB(scannedCode: scannedCode)
                //                }
                // }
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
    
    func addTriggerScanitemsinDatabase(){
        self.delegate?.didLotBasedTriggerScanDetails!(arr: (arrLotProductList! as NSArray))
//        if (arrLotProductList != nil) && arrLotProductList!.count>0{
//            for item in arrLotProductList!{
//
//                let obj = LotbasedTriggerscan(context: PersistenceService.context)
//                obj.product_name = item.productName
//                obj.product_quantity = Int16(item.productCount!)
//                obj.lot_number = item.lotNumber
//                obj.gtin = item.productGtin14
//                obj.uuid = item.uuid
//            }
//        }
       
    }
}
class ProductListModel{
    var productName: String?
    var productCount: Int?
    var uuid: String?
    var productGtin14: String?
    var lotNumber: String?
    var code: String?
    init(productName: String?, productCount: Int?, uuid: String?, productGtin14: String?, lotNumber: String?,code:String) {
        self.productName = productName
        self.productCount = productCount
        self.uuid = uuid
        self.productGtin14 = productGtin14
        self.lotNumber = lotNumber
        self.code = code
    }
}
class ProductCell: UITableViewCell {
    
    @IBOutlet weak var lblProductCount: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductSerialNo: UILabel!
    @IBOutlet weak var lblLot: UILabel!
    @IBOutlet weak var lblGTIN: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCount: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var bigPlusButton:UIButton!
    @IBOutlet weak var bigPlusWeightconstant:NSLayoutConstraint!
    @IBOutlet weak var minusButtonConst:NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnCount.layer.cornerRadius = self.btnCount.frame.height/2
        self.btnCount.layer.borderWidth = 0.5
        self.btnCount.layer.borderColor = UIColor.lightGray.cgColor
    }
}
