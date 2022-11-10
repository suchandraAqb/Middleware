/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//,,,sbm1

import ScanditBarcodeCapture
import ScanditCaptureCore
import ScanditParser

import UIKit

@objc protocol MWMultiScanViewControllerDelegate: AnyObject {
    @objc optional func didScanCodeForReceiveSerialVerification(scannedCode:[String])
    @objc optional func backFromMultiScan()
}

class MWMultiScanViewController: BaseViewController {
    weak var delegate: MWMultiScanViewControllerDelegate?
    private enum Constants {
        static let barcodeToScreenTresholdRation: CGFloat = 0.1
        static let shelfCount = 4
        static let backRoomCount = 8
    }
    var isForReceivingSerialVerificationScan: Bool = false
    
    fileprivate var scannedCodes: Set<String> = []

    fileprivate var gs1ValidScan: Set<String> = []
    fileprivate var gs1InvalidScan: Set<String> = []

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeTracking: BarcodeTracking!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeTrackingBasicOverlay!
    private var advancedOverlay: BarcodeTrackingAdvancedOverlay!
    private var feedback: Feedback!

    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noOfScannedSerials: UILabel!
    @IBOutlet weak var serialScanLabelWidthConstant:NSLayoutConstraint!
    @IBOutlet weak var containerButton : UIButton!
    @IBOutlet weak var productButton:UIButton!
    
    private var overlays: [Int: StockOverlay] = [:]

    private var overlaysCustomAll: [Int: UIImageView] = [:]
    private var overlaysCustomForLookWithFilter: [Int: CustomViewForLookWithFilter] = [:]//,,,sb11-2

    private var arrLotProductList : [ProductListModel]?
    var isTriggerEnableNotFound :Bool = false
    var failedItems = Array<Dictionary<String,Any>>()
    
    var containerProductCheckingArr = NSMutableArray()
    var isForPickingScanOption:Bool = false
    var isContainerScanEnable:Bool = false
    var sectionName:String = "" //,,,sb16-1
    private var parser: Parser!
    var barcodetype : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodes = []
        setupRecognition()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        serialScanLabelWidthConstant.constant = 129
        
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
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    private func populateItemsCount(isRemove : Bool){
        let count = "\(String(describing: self.scannedCodes.count))"
        let msg = "\(Int(count)!>1 ?"serials" : "serial") scanned".localized()
        
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

    private func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the default camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeTracking mode as default settings.
        // The preferred resolution is automatically chosen, which currently defaults to HD on all devices.
        // Setting the preferred resolution to full HD helps to get a better decode range.
        let cameraSettings = BarcodeTracking.recommendedCameraSettings
        cameraSettings.preferredResolution = .fullHD
        camera?.apply(cameraSettings, completionHandler: nil)

        // The barcode tracking process is configured through barcode tracking settings
        // and are then applied to the barcode tracking instance that manages barcode tracking.
        let settings = BarcodeTrackingSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
//        settings.set(symbology: .ean13UPCA, enabled: true)
//        settings.set(symbology: .ean8, enabled: true)
//        settings.set(symbology: .upce, enabled: true)
//        settings.set(symbology: .code39, enabled: true)
//        settings.set(symbology: .code128, enabled: true)
        
//        settings.set(symbology: .ean13UPCA, enabled: true)
//        settings.set(symbology: .ean8, enabled: true)
//        settings.set(symbology: .upce, enabled: true)
//        settings.set(symbology: .qr, enabled: true)
//        settings.set(symbology: .dataMatrix, enabled: true)
//        settings.set(symbology: .code39, enabled: true)
//        settings.set(symbology: .code128, enabled: true)
//        settings.set(symbology: .interleavedTwoOfFive, enabled: true)
//        settings.set(symbology: .gs1Databar, enabled: true)

        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true) //ITF
        settings.set(symbology: .qr, enabled: true) //QR
        settings.set(symbology: .gs1Databar, enabled: true)
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)

//        let symbologySettings = settings.settings(for: .dataMatrix)
//        symbologySettings.isColorInvertedEnabled = true
        
//        let symbologySettings = settings.settings(for: .qr)
//        symbologySettings!.activeSymbolCounts = Set(6...8) as Set<NSNumber>
//        symbologySettings!.isColorInvertedEnabled = true
        
       // Code 128, DataMatrix, EAN13, EAN8, Interleaved 2 of 5, QR, UPCA, UPCE


        // Create new barcode tracking mode with the settings from above.
        barcodeTracking = BarcodeTracking(context: context, settings: settings)
        feedback = Feedback.default
        // Register self as a listener to get informed of tracked barcodes.
        barcodeTracking.addListener(self)
        

        // To visualize the on-going barcode tracking process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: sectionView.bounds)
        captureView.context = context
        captureView.addControl(TorchSwitchControl())
        
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sectionView.addSubview(captureView)
        sectionView.sendSubviewToBack(captureView)
        captureView.logoOffset = PointWithUnit(x: FloatWithUnit(value: captureView.frame.size.width - 10, unit: .pixel),
        y: FloatWithUnit(value: captureView.frame.size.height - 10, unit: .pixel))
        
        if barcodetype == "HIBC"{
            parser = try! Parser(context: context, format: .hibc)
        }else{
            parser = try! Parser(context: context, format: .gs1AI)

        }

        // Add a barcode tracking overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
        // to the view.
        DispatchQueue.main.async { [self] in
            overlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, view: captureView)
            //overlay.shouldShowScanAreaGuides = true
            overlay.delegate = self
        }
        if (isForReceivingSerialVerificationScan){
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: false)
        }else{
            self.doneButton.isHidden = true
            self.noOfScannedSerials.isHidden = true
            // Add another barcode tracking overlay to the data capture view to render other views. The overlay is
            // automatically added to the view.
        }
        advancedOverlay = BarcodeTrackingAdvancedOverlay(barcodeTracking: barcodeTracking, view: captureView)
        advancedOverlay.delegate = self
    }
   
    private func populatelotProductDetails(code : String,productName: String,uuid : String,productGtin14 : String,lotNumber:String){
        if self.arrLotProductList?.count ?? 0 == 0{
            self.arrLotProductList = [ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber, code : code)]
        }else{
            if let index = self.arrLotProductList?.firstIndex(where: {$0.productName == productName}){
                self.arrLotProductList?[index].productCount! += 1
            }else{
                self.arrLotProductList?.append(ProductListModel(productName: productName, productCount: 1, uuid: uuid, productGtin14: productGtin14, lotNumber: lotNumber,code : code))
            }
        }
    }
    
    private func getGS1BarcodeLookupDetails(serials : String,productName: String , uuid: String , lotnumber:String , gtin14:String){
        /*
        //self.showSpinner(onView: self.captureView)
        if !serials.isEmpty{
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "?gs1_barcode=\(str ?? "")"
            
            Utility.GETServiceCall(type: "GS1BarcodeLookup", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr, isOpt: true) { (responseData:Any?, isDone:Bool?, message:String?) in
                 DispatchQueue.main.async{
               // self.removeSpinner()
                if isDone! {
                    let responseArray: NSArray = responseData as? NSArray ?? NSArray()
                    print(responseArray as NSArray)
                    if responseArray.count > 0{
                        if let serialDetailsArray = responseArray as? [[String : Any]]{
                            
                            let verifiedItem = serialDetailsArray.first
                            
                            if verifiedItem?["type"] as? String == "CONTAINER"{
                                if self.sectionName == "CreateSOByPicking" {
                                    if verifiedItem?["status"] as? String == "FOUND" {
                                        self.isTriggerEnableNotFound = false

                                        if !self.gs1ValidScan.contains(serials){
                                            self.gs1ValidScan.insert(serials)
                                            
                                            if !self.scannedCodes.contains(serials){
                                                self.scannedCodes.insert(serials)
                                            }
                                                
                                            self.populatelotProductDetails(code: serials, productName: "CONTAINER", uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                        }
                                    }
                                    else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                        if !self.gs1InvalidScan.contains(serials){
                                            self.gs1InvalidScan.insert(serials)
                                        }
                                        
                                        self.isTriggerEnableNotFound = true
                                        
                                        if !(self.failedItems as NSArray).contains(verifiedItem!){
                                            self.failedItems.append(verifiedItem!)
                                        }
                                    }
                                    else{
                                        self.isTriggerEnableNotFound = false

                                    }
                                }//,,,sb16-1
                                
                                return
                            }
                            
                            if verifiedItem?["status"] as? String == "LOT_FOUND" {
                                self.isTriggerEnableNotFound = false
                                if !self.gs1ValidScan.contains(serials){
                                    self.gs1ValidScan.insert(serials)
                                    
                                    if !self.scannedCodes.contains(serials){
                                        self.scannedCodes.insert(serials)
                                    }
                                        
                                    self.populatelotProductDetails(code: serials, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                }
                                
                            }else if verifiedItem?["status"] as? String == "FOUND" {
                                self.isTriggerEnableNotFound = false

                                if !self.gs1ValidScan.contains(serials){
                                    self.gs1ValidScan.insert(serials)
                                    
                                    if !self.scannedCodes.contains(serials){
                                        self.scannedCodes.insert(serials)
                                    }
                                        
                                    self.populatelotProductDetails(code: serials, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                }
                            }else if verifiedItem?["status"] as? String == "FOUND"{
                                print("ERROR ::: ALREADY LOT PRODUCT ADDED TO SESSION")
                            }else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                if !self.gs1InvalidScan.contains(serials){
                                    self.gs1InvalidScan.insert(serials)
                                }
                                self.isTriggerEnableNotFound = true
                                
                                if !(self.failedItems as NSArray).contains(verifiedItem!){
                                    self.failedItems.append(verifiedItem!)
                                }
                            }else{
                                self.isTriggerEnableNotFound = false

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
                        //Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
                 
//                    self.allScannedSerials = Array(self.allScannedSerials.suffix(from: serials.components(separatedBy: "\\n").count))
//
//                    let first = self.allScannedSerials.prefix(MaxNumberOfSerialsForVerification)
//
//                    if first.count > 0 {
//                        self.getGS1BarcodeLookupDetails(serials: first.joined(separator: "\\n"), scannedcode: scannedcode)
//                    }else{
//                        self.removeSpinner()
                    }
                 
            }
        }else{
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }*/
    }
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
                    self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                }
            }else {
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
                    self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.showConfirmationViewController(confirmationMsg: "Are you sure want to cancel scanning?".localized(), alertStatus: "Alert5")
    }
    
    private func freeze() {
        // First, disable barcode tracking to stop processing frames.
        barcodeTracking.isEnabled = false
        // Switch the camera off to stop streaming frames. The camera is stopped asynchronously.
        camera?.switch(toDesiredState: .off)
    }

    private func unfreeze() {
        // First, enable barcode tracking to resume processing frames.
        DispatchQueue.main.async { [self] in
            barcodeTracking.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
            camera?.switch(toDesiredState: .on)
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
    
    //MARK: - Private function
    private func stockOverlay(for trackedCode: TrackedBarcode) -> StockOverlay {
        let identifier = trackedCode.identifier
        var overlay: StockOverlay
        if overlays.keys.contains(identifier) {
            overlay = overlays[identifier]!
        } else {
            // Get the information you want to show from your back end system/database.
            overlay = StockOverlay(with: StockModel(shelfCount: Constants.shelfCount,
                                                    backroomCount: Constants.backRoomCount,
                                                    barcodeData: trackedCode.barcode.data)
            )
            overlay.abcd()
            overlays[identifier] = overlay
        }
        overlay.isHidden = !canShowOverlay(of: trackedCode)
        return overlay
    }
        
    @objc func handleTap(_ sender: MyTapGesture) {
        sender.cV.superview?.bringSubviewToFront(sender.cV)
    }
    
    private func customOverlayForAll(for trackedCode: TrackedBarcode) -> UIImageView {
        let identifier = trackedCode.identifier
        var overlay: UIImageView
        
        if overlaysCustomAll.keys.contains(identifier) {
            overlay = overlaysCustomAll[identifier]!
        } else {
            overlay = UIImageView(frame: .zero)
            
            //,,,sb11-2
            if(scannedCodes.contains(trackedCode.barcode.data!)) && !isTriggerEnableNotFound{
                overlay.image = UIImage.init(named: "green_tick")
            }else if (isTriggerEnableNotFound){
                overlay.image = UIImage.init(named: "red_cross")
            }
            //,,,sb11-2
            overlay.alpha = 1
            overlay.sizeToFit()
            // Get the information you want to show from your back end system/database.
            overlaysCustomAll[identifier] = overlay
        }
        overlay.isHidden = !canShowOverlay(of: trackedCode)
        return overlay
    }
    private func customOverlayForLookWithFilter(for trackedCode: TrackedBarcode) -> CustomViewForLookWithFilter {
        let identifier = trackedCode.identifier
        var overlayTemp: CustomViewForLookWithFilter
        if overlaysCustomForLookWithFilter.keys.contains(identifier) {
            overlayTemp = overlaysCustomForLookWithFilter[identifier]!
        } else {
            // Get the information you want to show from your back end system/database.
            //overlayTemp = CustomViewForLookWithFilter().loadView(barCode: trackedCode)
            //overlayTemp = CustomViewForLookWithFilter(frame: CGRect(x: 0, y: 0, width: 260, height: 56))
            overlayTemp = CustomViewForLookWithFilter().prepareView(barCode: trackedCode)
           // overlayTemp.delegate = self
            overlaysCustomForLookWithFilter[identifier] = overlayTemp
            
            //,,,sb11-2
            
            
            overlayTemp.mainContainerView.backgroundColor = Utility.hexStringToUIColor(hex: "D6D6D6")
            overlayTemp.triangleImageView.image = UIImage.init(named: "grey_triangle")

//            if(scannedCodesLookWithFilterAR_after.contains(trackedCode.barcode.data!)){
//                if self.isMatchOnlyAR {
//                    overlayTemp.mainContainerView.backgroundColor = UIColor.white
//                    overlayTemp.triangleImageView.image = UIImage.init(named: "triangle")
//
//                }else {
//                    overlayTemp.mainContainerView.backgroundColor = Utility.hexStringToUIColor(hex: "FEF851")
//                    overlayTemp.triangleImageView.image = UIImage.init(named: "yelow_triangle")
//                }
//            }
            //,,,sb11-2
            
            overlayTemp.sizeToFit()
        }
        overlayTemp.isHidden = !canShowOverlay(of: trackedCode)
        return overlayTemp
    }
   
    private func canShowOverlay(of trackedCode: TrackedBarcode) -> Bool {
        
        return true
    }
    
    
}

// MARK: - MWConfirmationView
extension MWMultiScanViewController: MWConfirmationViewDelegate {
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
        self.delegate?.backFromMultiScan?()
    }
    func cancelButtonPressed(alertStatus:String) {
        
    }
    //MARK: - End
}
// MARK: - End

// MARK: - BarcodeTrackingListener

extension MWMultiScanViewController: BarcodeTrackingListener {

    // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                         didUpdate session: BarcodeTrackingSession,
                         frameData: FrameData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.barcodeTracking.isEnabled {
                return
            }
            
            for identifier in session.removedTrackedBarcodes {
                if (self.isForReceivingSerialVerificationScan){
                    
                    self.overlaysCustomForLookWithFilter.removeValue(forKey: identifier.intValue)
                }
            }
            for trackedCode in session.trackedBarcodes.values {
                if (self.isForReceivingSerialVerificationScan){
                                    
                    self.overlaysCustomForLookWithFilter[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                }
            }
            if (self.isForReceivingSerialVerificationScan){
                self.populateItemsCount(isRemove: false)
            }
        }
    }
}

// MARK: - BarcodeTrackingBasicOverlayDelegate
extension MWMultiScanViewController: BarcodeTrackingBasicOverlayDelegate {
    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                     brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        guard let code = trackedBarcode.barcode.data, !code.isEmpty else {
            return overlay.brush
        }
        return .newlyAdded
    }

    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay, didTap trackedBarcode: TrackedBarcode) {
        print(self.scannedCodes)
    }
}

// MARK: - BarcodeTrackingAdvancedOverlayDelegate
extension MWMultiScanViewController: BarcodeTrackingAdvancedOverlayDelegate {
    
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        viewFor trackedBarcode: TrackedBarcode) -> UIView? {
        //return stockOverlay(for: trackedBarcode)
        guard let code = trackedBarcode.barcode.data, !code.isEmpty else {
            return nil
        }
        let overlayTemp = customOverlayForLookWithFilter(for: trackedBarcode)
        if barcodetype == "HIBC"{
            do {
               let parsedData = try parser.parseString(code)
               /*
                * Extract the fields relevant to your use case. Below, for example, we extract a label,
                * which has the type String, and an expiry date, which is represented as a map with keys
                * "year", "month", "day".
               */
//               guard let serialNumber = parsedData.fieldsByName["lic"]?.parsed as? String,
//                     let pcnNumber = parsedData.fieldsByName["pcn"]?.parsed as? String,
//                     let uomNumber = parsedData.fieldsByName["uom"]?.parsed as? String,
//                     let expiryDate = parsedData.fieldsByName["expiryDate"]?.parsed as? [String: AnyObject],
//                     let year = expiryDate["year"] as? String,
//                     let month = expiryDate["month"] as? String,
//                     let day = expiryDate["day"] as? String else { return overlayTemp }

               // Do something with the extracted fields.

           } catch {
               // Handle the parser error
               print(error)
           }
        }else{
        let details = UtilityScanning(with:code).decoded_info
        if details.count <= 0 {
            return nil
        }
        if !self.scannedCodes.contains(code){
            self.feedback?.emit()
            self.scannedCodes.insert(code)

            self.overlay.setBrush(.newlyAdded, for: trackedBarcode)
        }else{
            self.overlay.setBrush(.highlighted, for: trackedBarcode)
        }
        
//        if self.isForReceivingSerialVerificationScan {
//
//         let details = UtilityScanning(with:code).decoded_info
//            if details.count > 0 {
//                var containerSerialNumber = ""
//                var productName = ""
//                var productGtin14 = ""
//                var serialNumber = ""
//                var lotNumber = ""
//                var expirationDate = ""
//                var uuid = ""
//                var productIdentifier = ""
//
//                if(details.keys.contains("00")){
//                    if let cSerial = details["00"]?["value"] as? String{
//                        containerSerialNumber = cSerial
//                    }else if let cSerial = details["00"]?["value"] as? NSNumber{
//                        containerSerialNumber = "\(cSerial)"
//                    }
//                    if isForPickingScanOption {
//                        let dict = NSMutableDictionary()
//                        dict.setValue("CONTAINER", forKey: "type")
//                        dict.setValue(code, forKey: "Value")
//                        if !containerProductCheckingArr.contains(dict){
//                            containerProductCheckingArr.add(dict)
//                        }
//                    }
//                }else{
//                    if let  allproducts = AllProductsModel.getAllProducts() as? [[String: Any]]{
//                        if !allproducts.isEmpty  {
//                            if(details.keys.contains("01")){
//                                if let gtin14 = details["01"]?["value"] as? String{
//                                    productGtin14 = gtin14
//                                    let filteredArray = allproducts.filter { $0["gtin14"] as? String == gtin14 }
//                                    print(filteredArray as Any)
//                                    if filteredArray.count > 0 {
//                                        productName = (filteredArray.first?["name"] as? String)!
//                                        uuid = (filteredArray.first?["uuid"] as? String)!
//                                    }else{
//                                        let productDict = Utility.gtin14ToNdc(gtin14str: productGtin14)
//                                        if let product_name = productDict["name"] as? String,!product_name.isEmpty{
//                                            productName = product_name
//                                        }
//                                        if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
//                                            productIdentifier = product_identifier
//                                        }
//                                        if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
//                                            uuid = product_uuid
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    if(details.keys.contains("10")){
//                        if let lot = details["10"]?["value"] as? String{
//                            lotNumber = lot
//                        }
//                    }
//
//                    if (details.keys.contains("17")){
//                        if let expiration = details["17"]?["value"] as? String{
//                            let splitarr = expiration.split(separator: "T")
//                            if splitarr.count>0{
//                                expirationDate = String(splitarr[0])
//                            }
//                        }
//                    }
//                    if(details.keys.contains("21")){
//                        if let serial = details["21"]?["value"] as? String{
//                            serialNumber = serial
//                        }
//                    }
//                if isForPickingScanOption {
//                    let dict = NSMutableDictionary()
//                    dict.setValue("PRODUCT", forKey: "type")
//                    dict.setValue(code, forKey: "Value")
//                    if !containerProductCheckingArr.contains(dict){
//                        containerProductCheckingArr.add(dict)
//                    }
//                }
//            }
//            DispatchQueue.main.async {
//                if self.gs1ValidScan.contains(code){
//                   self.isTriggerEnableNotFound = false
//                }else if (self.gs1InvalidScan.contains(code)){
//                   self.isTriggerEnableNotFound = true
//               }else{
//                   self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, lotnumber: lotNumber, gtin14: productGtin14)
//                   }
//               }
//            }
//        }
        }
        if self.isForReceivingSerialVerificationScan {
            self.populateItemsCount(isRemove: false)
        }
        return overlayTemp

    }
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        anchorFor trackedBarcode: TrackedBarcode) -> Anchor {
        // The offset of our overlay will be calculated from the top center anchoring point.
        if (isForReceivingSerialVerificationScan){
            return .center
        }else{
            return .bottomCenter
        }
    }

    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        offsetFor trackedBarcode: TrackedBarcode) -> PointWithUnit {
        // We set the offset's height to be equal of the 100 percent of our overlay.
        // The minus sign means that the overlay will be above the barcode.
        /*
        if (isForReceivingSerialVerificationScan){
            
            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                 y: FloatWithUnit(value: 0, unit: .fraction))
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if let overlayTemp = self.overlaysCustom[trackedBarcode.identifier]{
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                }
            }
            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                 y: FloatWithUnit(value: 0.5, unit: .fraction))
        }*/
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let overlayTemp = self.overlaysCustomForLookWithFilter[trackedBarcode.identifier]{
                overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
            }
        }
        return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                             y: FloatWithUnit(value: 0.5, unit: .fraction))
    }
}
