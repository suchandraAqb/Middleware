//
//  MWSingleScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 03/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//,,,sbm1

import UIKit
import ScanditBarcodeCapture
import ScanditCaptureCore
import ScanditParser


@objc protocol MWSingleScanViewControllerDelegate: AnyObject {
    @objc optional func didSingleScanCodeForReceiveSerialVerification(scannedCode:[String])
    @objc optional func backFromSingleScan()
}

class MWSingleScanViewController: BaseViewController {
    
    weak var delegate: MWSingleScanViewControllerDelegate?
    
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noOfScannedSerials: UILabel!
    @IBOutlet weak var containerButton : UIButton!
    @IBOutlet weak var productButton:UIButton!
    
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!
    
    fileprivate var scannedCodes: Set<String> = []
    var failedItems = Array<Dictionary<String,Any>>()
    private var arrLotProductList : [MWProductListModel]?

    var isForReceivingSerialVerificationScan: Bool = false
    var containerProductCheckingArr = NSMutableArray()
    var isContainerScanEnable:Bool = false
    private var parser: Parser!
    var barcodetype : String = ""
        
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodes = []
        sectionView.roundTopCorners(cornerRadious: 40)
        setupRecognition()
    
        isContainerScanEnable = false
        
        containerButton.isHidden = false
        containerButton.alpha = 0.5
        containerButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        containerButton.setTitleColor(UIColor.white, for: .normal)
        
        productButton.isHidden = false
        productButton.alpha = 1
        productButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
        productButton.setTitleColor(UIColor.white, for: .normal)
        
        containerButton.isHidden = true
        productButton.isHidden = true
        
        barcodetype = defaults.object(forKey: "barcode_format") as? String ?? ""

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unfreeze()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        freeze()
    }
    
    deinit {
        if (isForReceivingSerialVerificationScan) {
            barcodeCapture.isEnabled = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func toggleFreezing(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            freeze()
        } else {
            unfreeze()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if (isForReceivingSerialVerificationScan) {
            if isContainerScanEnable {
                let predicate = NSPredicate(format: "type == 'PRODUCT'")
                let filterArr = containerProductCheckingArr.filtered(using: predicate)
                if filterArr.count > 0 {
                    Utility.showPopup(Title: App_Title, Message: "Please Scan Container Only.", InViewC: self)
                    containerProductCheckingArr.removeAllObjects()
                    scannedCodes.removeAll()
                    self.populateItemsCount(isRemove: false)
                    return
                }else {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
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
                }else {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.showConfirmationViewController(confirmationMsg: "Are you sure want to cancel scanning?".localized(), alertStatus: "Alert5")
    }
    
    @IBAction func containerOrProductScan(_ sender:UIButton) {
        if sender.tag == 1 {
            isContainerScanEnable = false
            
            containerButton.alpha = 0.5
            containerButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
            containerButton.setTitleColor(UIColor.white, for: .normal)
            
            productButton.alpha = 1
            productButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
            productButton.setTitleColor(UIColor.white, for: .normal)
        }else {
            isContainerScanEnable = true
            
            containerButton.alpha = 1
            containerButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 15)
            containerButton.setTitleColor(UIColor.white, for: .normal)
            
            productButton.alpha = 0.5
            productButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
            productButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    // MARK: - End
    
    // MARK: - Private Function
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

//            settings.set(symbology: .code128, enabled: true)
//            settings.set(symbology: .dataMatrix, enabled: true)
//            settings.set(symbology: .ean13UPCA, enabled: true)
//            settings.set(symbology: .ean8, enabled: true)
//            settings.set(symbology: .interleavedTwoOfFive, enabled: true)
//            settings.set(symbology: .upce, enabled: true)
//            settings.set(symbology: .qr, enabled: true)
//            settings.locationSelection = RadiusLocationSelection(radius:.zero)
//            settings.codeDuplicateFilter = 1
////            settings.codeDuplicateFilter = -1
//
//            let symbologySettings = settings.settings(for: .dataMatrix)
//            symbologySettings.isColorInvertedEnabled = true

            
            settings.set(symbology: .code128, enabled: true)
            settings.set(symbology: .dataMatrix, enabled: true)
            settings.set(symbology: .code39, enabled: true)
            settings.set(symbology: .interleavedTwoOfFive, enabled: true) //ITF
            settings.set(symbology: .qr, enabled: true) //QR
            settings.set(symbology: .gs1Databar, enabled: true)
            settings.set(symbology: .ean13UPCA, enabled: true)
            settings.set(symbology: .ean8, enabled: true)
            settings.set(symbology: .upce, enabled: true)
            settings.locationSelection = RadiusLocationSelection(radius:.zero)
            settings.codeDuplicateFilter = -1

            
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
            overlay.brush = .highlighted
                
            overlay.shouldShowScanAreaGuides = false
            overlay.viewfinder = LaserlineViewfinder()
            captureView.addOverlay(overlay)
            
            if barcodetype == "HIBC"{
                parser = try! Parser(context: context, format: .hibc)
            }else{
                parser = try! Parser(context: context, format: .gs1AI)
            }

            if (isForReceivingSerialVerificationScan) {
                self.doneButton.isHidden = false
                self.noOfScannedSerials.isHidden = false
                self.populateItemsCount(isRemove: false)
            }else {
                self.doneButton.isHidden = true
                self.noOfScannedSerials.isHidden = true
            }
        }
    }
    
    private func populateItemsCount(isRemove : Bool){
        var count = ""
        var msg = ""
        
        count = "\(String(describing: self.scannedCodes.count))"
        msg = "\(Int(count)!>1 ?"serials" : "serial") scanned".localized()
        
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
        if(!isForReceivingSerialVerificationScan){
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
}

// MARK: - MWConfirmationView
extension MWSingleScanViewController: MWConfirmationViewDelegate {
    func showConfirmationViewController(confirmationMsg:String, alertStatus:String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MWConfirmationViewController") as! MWConfirmationViewController
        controller.confirmationMsg = confirmationMsg
        controller.alertStatus = alertStatus
        controller.isCancelButtonShow = true

        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - MWConfirmationViewDelegate
    func doneButtonPressed(alertStatus:String) {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.backFromSingleScan?()
    }
    func cancelButtonPressed(alertStatus:String) {
        
    }
    //MARK: - End
}
// MARK: - End

// MARK: - BarcodeCaptureListener
extension MWSingleScanViewController: BarcodeCaptureListener {
    
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

            if (self.isForReceivingSerialVerificationScan) {
                
                if !self.scannedCodes.contains(code) {
                    self.scannedCodes.insert(code)
                }
                self.populateItemsCount(isRemove: false)

                /*
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
                    
                    if (details.keys.contains("00")) {
                        //CONTAINER
                        if let cSerial = details["00"]?["value"] as? String{
                            containerSerialNumber = cSerial
                        }else if let cSerial = details["00"]?["value"] as? NSNumber{
                            containerSerialNumber = "\(cSerial)"
                        }
                        
                        let dict = NSMutableDictionary()
                        dict.setValue("CONTAINER", forKey: "type")
                        dict.setValue(code, forKey: "Value")
                        if !self.containerProductCheckingArr.contains(dict){
                            self.containerProductCheckingArr.add(dict)
                        }
                        
                        if !self.scannedCodes.contains(code) {
                            self.scannedCodes.insert(code)
//                            self.getGS1BarcodeLookupDetails_WebserviceCall(serials: code, productName: "", uuid: "", productGtin14: "", lotNumber: "")
                        }
                        self.populateItemsCount(isRemove: false)
                    }
                    else {
                        //PRODUCT
                        let dict = NSMutableDictionary()
                        dict.setValue("PRODUCT", forKey: "type")
                        dict.setValue(code, forKey: "Value")
                        if !self.containerProductCheckingArr.contains(dict){
                            self.containerProductCheckingArr.add(dict)
                        }
                        
                        /*
                        if let allproducts = AllProductsModel.getAllProducts() as? [[String: Any]] {
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
                        */
                        
                        if !self.scannedCodes.contains(code) {
                            self.scannedCodes.insert(code)
//                            self.getGS1BarcodeLookupDetails_WebserviceCall(serials: code, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotNumber)
                        }
                        self.populateItemsCount(isRemove: false)
                    }
                }
                */
            }
        }
    }
}
// MARK: - End

// MARK: - WebserviceCall
extension MWSingleScanViewController {
    private func getGS1BarcodeLookupDetails_WebserviceCall(serials : String, productName: String, uuid: String, productGtin14: String, lotNumber: String){
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
                            
                            if verifiedItem?["type"] as? String == "CONTAINER" {
                                
                                if verifiedItem?["status"] as? String == "FOUND"{
                               /*
                                   if self.arrLotProductList?.count ?? 0 == 0{
                                       
                                       self.addDetailsView()
                                       self.arrLotProductList = [MWProductListModel(productName: "CONTAINER", productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber , code : serials)]
                                       
                                   }else{
                                       if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                                           self.arrLotProductList?[index].productCount! += 1
                                           
                                       }else{
                                           self.arrLotProductList?.append(MWProductListModel(productName: "CONTAINER", productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code: serials))
                                       }
                                   }
                                   
                                   self.tblProduct.reloadSections([0], with: .automatic)
                                   self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
                                    */
                               }else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                   /*if !(self.failedItems as NSArray).contains(verifiedItem!){
                                       self.failedItems.append(verifiedItem!)
                                   }*/
                               }
                               self.barcodeCapture.isEnabled = true
                                
                            }//,,,sb16-1
                            else{
                                if verifiedItem?["status"] as? String == "LOT_FOUND"{
                                   /*
                                    if self.arrLotProductList?.count ?? 0 == 0{
                                        
                                        self.addDetailsView()
                                        self.arrLotProductList = [MWProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber , code : serials)]
                                        
                                    }else{
                                        
                                        if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                                            self.arrLotProductList?[index].productCount! += 1
                                            
                                        }else{
                                            self.arrLotProductList?.append(MWProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code: serials))
                                        }
                                    }
                                    
                                    self.tblProduct.reloadSections([0], with: .automatic)
                                    self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
                                    */
                                    
                                }else if verifiedItem?["status"] as? String == "FOUND"{
                                   /*
                                    if self.arrLotProductList?.count ?? 0 == 0{
                                        
                                        self.addDetailsView()
                                        self.arrLotProductList = [MWProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber , code : serials)]
                                        
                                    }else{
                                        
                                        if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                                            self.arrLotProductList?[index].productCount! += 1
                                            
                                        }else{
                                            self.arrLotProductList?.append(MWProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code: serials))
                                        }
                                    }
                                    
                                    self.tblProduct.reloadSections([0], with: .automatic)
                                    self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
                                    
                                    */
                                
                                }
                                else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                    /*if !(self.failedItems as NSArray).contains(verifiedItem!){
                                        self.failedItems.append(verifiedItem!)
                                    }*/
                                }
                                self.barcodeCapture.isEnabled = true
                            }
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
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }
}
// MARK: - End

class MWProductListModel {
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
