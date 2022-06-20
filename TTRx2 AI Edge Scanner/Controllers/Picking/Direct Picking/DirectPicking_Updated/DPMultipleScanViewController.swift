//
//  DPMultipleScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 03/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import ScanditBarcodeCapture

@objc protocol DPMultipleScanViewControllerDelegate: class {
    @objc optional func dpMultipleScanCodeForReceiveSerialVerification(scannedCode:[String])
}

class DPMultipleScanViewController: BaseViewController, ConfirmationViewDelegate {
    
    weak var delegate: DPMultipleScanViewControllerDelegate?
    
    fileprivate var scannedCodes: Set<String> = []
    fileprivate var removedCodes: Set<String> = []
    
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var captureView: DataCaptureView!
    private var barcodeCaptureOverlay : BarcodeCaptureOverlay!
    var isForReceivingSerialVerificationScan: Bool = false

    private var barcodeTracking: BarcodeTracking!
    private var overlay: BarcodeTrackingBasicOverlay!
    private var advancedOverlay: BarcodeTrackingAdvancedOverlay!
    private var feedback: Feedback!
    private var overlaysCustomAll: [Int: UIImageView] = [:]
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var tblProduct: UITableView!
    
    @IBOutlet weak var lblHeader: UILabel!
    
    private var productCount = 0
    
    @IBOutlet weak var returnConditionView: UIView!
    @IBOutlet weak var resalableButton: UIButton!
    @IBOutlet weak var quarantineButton: UIButton!
    @IBOutlet weak var destructButton: UIButton!
    
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noOfScannedSerials: UILabel!
    
    @IBOutlet weak var upDownArrowButton:UIButton!
    @IBOutlet weak var tableviewHeightConstant:NSLayoutConstraint!
    fileprivate var failedScan : Set<String> = []
    @IBOutlet weak var itemscountStackView:UIStackView!

    var failedItems = Array<Dictionary<String,Any>>()
    var verifiedArr = Array<Dictionary<String,Any>>()
    
    var dpProductList : Array<Any>?
    var ismatchValue : Bool = false
    var localQuantitynotPicked :Int = 0
    var indexArr = NSMutableArray()
    var productName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodes = []
        sectionView.roundTopCorners(cornerRadious: 40)
        setupRecognition()
        self.tblProduct.delegate = self
        self.tblProduct.dataSource = self
        self.tblProduct.separatorStyle = .none
        itemscountStackView.isHidden = false

        //self.tblProduct.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        tableviewHeightConstant.constant = 200
        upDownArrowButton.isSelected = true
        lblHeader.text = "Items To Pick"
        doneButton.isHidden = true
        self.addDetailsView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          AllProductsModel.AllProductsShared.getAllProducts { (isDone:Bool?) in
        }
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
        if (isForReceivingSerialVerificationScan){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.dpMultipleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
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
        
            // The barcode capturing process is configured through barcode capture settings
            // and are then applied to the barcode capture instance that manages barcode recognition.
            context = DataCaptureContext.licensed
            camera = Camera.default
            context.setFrameSource(camera, completionHandler: nil)
        
            let cameraSettings = BarcodeTracking.recommendedCameraSettings
            cameraSettings.preferredResolution = .fullHD
            camera?.apply(cameraSettings, completionHandler: nil)
        
            let settings = BarcodeTrackingSettings()

            settings.set(symbology: .code128, enabled: true)
            settings.set(symbology: .dataMatrix, enabled: true)
            settings.set(symbology: .ean13UPCA, enabled: true)
            settings.set(symbology: .ean8, enabled: true)
            settings.set(symbology: .interleavedTwoOfFive, enabled: true)
            settings.set(symbology: .upce, enabled: true)
            settings.set(symbology: .qr, enabled: true)
            
            let symbologySettings = settings.settings(for: .dataMatrix)
            symbologySettings.isColorInvertedEnabled = true
       
            // Create new barcode capture mode with the settings from above.
            barcodeTracking = BarcodeTracking(context: context, settings: settings)
            feedback = Feedback.default
            barcodeTracking.addListener(self)

            // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
            // camera preview. The view must be connected to the data capture context.

            captureView = DataCaptureView(context: context, frame: sectionView.bounds)
            captureView.context = context
            captureView.addControl(TorchSwitchControl())
        
            sectionView.addSubview(captureView)
            captureView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([
                captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                captureView.topAnchor.constraint(equalTo: view.topAnchor),
                captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            sectionView.sendSubviewToBack(captureView)
            DispatchQueue.main.async { [self] in
                overlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, view: captureView)
                //overlay.shouldShowScanAreaGuides = true
                overlay.delegate = self
            }
        advancedOverlay = BarcodeTrackingAdvancedOverlay(barcodeTracking: barcodeTracking, view: captureView)
        advancedOverlay.delegate = self
        /*
        
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
        settings.codeDuplicateFilter = -1
        
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
            
        overlay.shouldShowScanAreaGuides = true
        overlay.viewfinder = LaserlineViewfinder()
        captureView.addOverlay(overlay)
        
        if (isForReceivingSerialVerificationScan || isForInventory || isForReturnSerialVerificationScan || isForManualInbound || isForOnlyReceive){
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
         */
    }
    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        if upDownArrowButton.isSelected {
            upDownArrowButton.isSelected = false
            tableviewHeightConstant.constant = 0
            itemscountStackView.isHidden = true

        }else{
            upDownArrowButton.isSelected = true
            tableviewHeightConstant.constant = 200
            itemscountStackView.isHidden = false

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
    
    private func customOverlayForAll(for trackedCode: TrackedBarcode) -> UIImageView {
        let identifier = trackedCode.identifier
        var overlay: UIImageView
    
        if overlaysCustomAll.keys.contains(identifier) {
            overlay = overlaysCustomAll[identifier]!
        } else {
            overlay = UIImageView(frame: .zero)
            
            if scannedCodes.contains(trackedCode.barcode.data!){
                overlay.image = UIImage.init(named: "green_tick")
            }else{
                overlay.image = UIImage.init(named: "red_cross")
            }
        overlay.alpha = 1
        overlay.sizeToFit()
        overlaysCustomAll[identifier] = overlay
    }
        overlay.isHidden = !canShowOverlay(of: trackedCode)
        return overlay
    }
    private func canShowOverlay(of trackedCode: TrackedBarcode) -> Bool {
        //let captureViewWidth = captureView.frame.width

        // If the barcode is wider than the desired percent of the data capture view's width,
        // show it to the user.
        ////return (width / captureViewWidth) >= Constants.barcodeToScreenTresholdRation
        return true
    }
}
// MARK: - End

// MARK: - BarcodeCaptureListener

extension DPMultipleScanViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dpProductList?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DProductCell", for: indexPath) as! DProductCell
        
        cell.selectionStyle = .none
      

        if let item = self.dpProductList?[indexPath.row] as? NSDictionary{

            var dataStr = ""
            if let storageNameStr = item["storage_area_name"] as? String{
                dataStr = storageNameStr
            }
            cell.storagelable.text = dataStr

            dataStr = ""
            if let storageShelfStr = item["shelf_area_name"] as? String{
                dataStr = storageShelfStr
            }
            cell.storageShelflable.text = dataStr

             dataStr = ""
            if let productNameStr = item["product_name"] as? String{
                dataStr = productNameStr
            }
            cell.lblProductName.text = dataStr
            
            var dataInt = 0
          
            if let productCountStr = item["quantity_to_pick"] as? String{
                dataInt = Int((productCountStr as NSString).intValue)
            }
            if dataInt == 0 {
                cell.lblProductCount.isHidden = true

            }else{
                cell.lblProductName.isHidden = false
                cell.lblProductCount.text = "Qty:" + "\(dataInt)"

            }
        }
       
        if indexArr.contains(indexPath.row) {
            cell.selectedButton.isHidden = false
        }else{
            cell.selectedButton.isHidden = true
        }
        return cell
    }
  
}
extension DPMultipleScanViewController{

    @IBAction func done(_ sender: UIButton){
        
        self.removeDetailsView(completionHandler: {_ in
                self.delegate?.dpMultipleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                self.navigationController?.popViewController(animated: true)
        })
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
            })
            
        }
    }
}

// MARK: - BarcodeTrackingListener

extension DPMultipleScanViewController: BarcodeTrackingListener {

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
                self.overlaysCustomAll.removeValue(forKey: identifier.intValue)
            }
            for trackedCode in session.trackedBarcodes.values {
                self.overlaysCustomAll[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
            }
            self.populateItemsCount(isRemove: false)
        }
    }
}

// MARK: - BarcodeTrackingBasicOverlayDelegate

extension DPMultipleScanViewController: BarcodeTrackingBasicOverlayDelegate {
    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay,
                                     brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        guard let code = trackedBarcode.barcode.data, !code.isEmpty else {
            return overlay.brush
        }
        return .newlyAdded

//        if !self.scannedCodes.contains(code) {
//            if(!self.isForMultiRemove) {
//                self.feedback?.emit()
//            }
//            self.scannedCodes.insert(code)
//            return .newlyAdded
//        }else{
//            if(removedCodes.contains(trackedBarcode.barcode.data!)){
//                return .removed
//            }else{
//                return .highlighted
//            }
//        }
 
    }

    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay, didTap trackedBarcode: TrackedBarcode) {
        print(self.scannedCodes)
    }
}

// MARK: - BarcodeTrackingAdvancedOverlayDelegate
extension DPMultipleScanViewController: BarcodeTrackingAdvancedOverlayDelegate {
    
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        viewFor trackedBarcode: TrackedBarcode) -> UIView? {
        guard let code = trackedBarcode.barcode.data, !code.isEmpty else {
            return nil
        }
        var overlayTemp : UIView
        overlayTemp = customOverlayForAll(for: trackedBarcode)
  
        let details = UtilityScanning(with:code).decoded_info
        if details.count <= 0 {
            return nil
        }
        if !self.scannedCodes.contains(code){
                self.overlay.setBrush(.newlyAdded, for: trackedBarcode)
        }else{
                self.overlay.setBrush(.highlighted, for: trackedBarcode)
        }
        if details.count > 0 && !self.scannedCodes.contains(code){
                var containerSerialNumber = ""
                var gtin14 = ""
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
                                        self.productName = (filteredArray.first?["name"] as? String)!
                                        uuid = (filteredArray.first?["uuid"] as? String)!
                                    }else{
                                        let productDict = Utility.gtin14ToNdc(gtin14str: gtin14Value)
                                        
                                            if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                self.productName = product_name
                                            }
                                            if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                productIdentifier = product_identifier
                                            }
                                            if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
                                                uuid = product_uuid
                                            }
                                        if productIdentifier.isEmpty{
                                            //Utility.showPopup(Title: App_Title, Message: "Product not found", InViewC: self)
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
                        let predicate = NSPredicate(format: "product_name = '\(self.productName)'")
                        let filterArr = arr.filtered(using: predicate)
                    
                        if filterArr.count > 0 {
                            let dict = filterArr.first as? NSDictionary
                            let quantity = dict?["quantity_to_pick"] as? NSString
                        
                            let index = (self.dpProductList! as NSArray).index(of: dict!)
                            
                            self.ismatchValue = true
                            
                            if quantity!.intValue > 0 {
                                let value:Int = Int(quantity!.intValue) - 1
                                if value == 0 {
                                    if !self.indexArr.contains(index){
                                      self.indexArr.add(index)
                                  }
                                }
                                  let indexPath = NSIndexPath(row: index, section: 0)
                                  self.tblProduct.scrollToRow(at: indexPath as IndexPath, at: .none, animated: true)
                                
                                    var tempdict = NSMutableDictionary()
                                    if let dict = self.dpProductList?[index] as? NSDictionary{
                                        tempdict = dict.mutableCopy() as! NSMutableDictionary
                                    }
                                    tempdict.setValue("\(value)", forKey: "quantity_to_pick")
                                    
                                    let tempdproductList = NSMutableArray()
                                    tempdproductList.addObjects(from: self.dpProductList!)
                                    tempdproductList.replaceObject(at: index, with: tempdict)
                                    
                                    self.dpProductList = tempdproductList.mutableCopy() as? Array<Any>
                                    
                                    if !self.scannedCodes.contains(code as String) {
                                        self.scannedCodes.insert(code as String)
                                    }
                            }
                           
                            if self.scannedCodes.count > 0 {
                                self.doneButton.isHidden = false
                                self.noOfScannedSerials.isHidden = false
                                self.populateItemsCount(isRemove: false)
                            }
                            self.tblProduct.reloadData()
                        }else{
                            
                            self.ismatchValue = false
                        }
                        self.tblProduct.reloadData()
                    }
                }
         return overlayTemp
}
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        anchorFor trackedBarcode: TrackedBarcode) -> Anchor {
            return .center
    }

    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        offsetFor trackedBarcode: TrackedBarcode) -> PointWithUnit {
            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                 y: FloatWithUnit(value: 0, unit: .fraction))
    }
}
