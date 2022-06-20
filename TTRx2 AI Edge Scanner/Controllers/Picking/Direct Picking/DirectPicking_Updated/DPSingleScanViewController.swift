//
//  DPSingleScanViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 03/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import ScanditBarcodeCapture

@objc protocol DPSingleScanViewControllerDelegate: class {
    @objc optional func dpSingleScanCodeForReceiveSerialVerification(scannedCode:[String])
    @objc optional func triggerScanFailedForSingleScan(failedArr : [[String:Any]])
}

class DPSingleScanViewController: BaseViewController, ConfirmationViewDelegate {
    
    weak var delegate: DPSingleScanViewControllerDelegate?
    
    fileprivate var scannedCodes: Set<String> = []
    fileprivate var removedCodes: Set<String> = []
    
    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var viewFinder : LaserlineViewfinder!
    private var barcodeCaptureOverlay : BarcodeCaptureOverlay!
    var isForReceivingSerialVerificationScan: Bool = false


    /////////////////////////////////////BOTTOM SHEET/////////////////////////////
    public var isForBottomSheetScan: Bool = false
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var tblProduct: UITableView!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    
    
    private var productCount = 0
    
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
    fileprivate var failedScan : Set<String> = []

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
        //self.tblProduct.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        itemscountStackView.isHidden = false
        tableviewHeightConstant.constant = 200
        upDownArrowButton.isSelected = true
        lblHeader.text = "Items To Pick"
        doneButton.isHidden = true
        btnConfirm.isHidden = true
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
        if failedItems.count > 0 && isForBottomSheetScan {
            self.delegate?.triggerScanFailedForSingleScan!(failedArr: self.failedItems)
        }
        freeze()
    }
    
    deinit {
        //self.tblProduct.removeObserver(self, forKeyPath: "contentSize")
        if(isForReceivingSerialVerificationScan){
            barcodeCapture.isEnabled = false
        }
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
            self.delegate?.dpSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
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
            camera = Camera.default

            let barcodeCaptureSettings = BarcodeCaptureSettings()

            barcodeCaptureSettings.set(symbology: .code128, enabled: true)
            barcodeCaptureSettings.set(symbology: .dataMatrix, enabled: true)
            barcodeCaptureSettings.set(symbology: .ean13UPCA, enabled: true)
            barcodeCaptureSettings.set(symbology: .ean8, enabled: true)
            barcodeCaptureSettings.set(symbology: .interleavedTwoOfFive, enabled: true)
            barcodeCaptureSettings.set(symbology: .upce, enabled: true)
            barcodeCaptureSettings.set(symbology: .qr, enabled: true)
            barcodeCaptureSettings.locationSelection = RadiusLocationSelection(radius:.zero)
            barcodeCaptureSettings.codeDuplicateFilter = -1
            
            let symbologySettings = barcodeCaptureSettings.settings(for: .dataMatrix)
            symbologySettings.isColorInvertedEnabled = true
            // Setting the code duplicate filter to one means that the scanner won't report the same code as recognized
            // for one second once it's recognized.
            barcodeCaptureSettings.codeDuplicateFilter = 1

            // By setting the radius to zero, the barcode's frame has to contain the point of interest.
            // The point of interest is at the center of the data capture view by default, as in this case.
            barcodeCaptureSettings.locationSelection = RadiusLocationSelection(radius: .zero)

            // Create data capture context using your license key and set the camera as the frame source.
            context = DataCaptureContext.licensed
            context.setFrameSource(camera, completionHandler: nil)

            // Use the recommended camera settings for the BarcodeCapture mode.
            let recommendedCameraSettings = BarcodeCapture.recommendedCameraSettings
            camera?.apply(recommendedCameraSettings)

            // Register self as a listener to get informed whenever the status of the license changes.
            context.addListener(self)

            // Create new barcode capture mode with the settings from above.
            barcodeCapture = BarcodeCapture(context: context, settings: barcodeCaptureSettings)

            // Register self as a listener to get informed whenever a new barcode got recognized.
            barcodeCapture.addListener(self)

            // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
            // camera preview. The view must be connected to the data capture context.
            captureView = DataCaptureView(context: context, frame: sectionView.bounds)

            // Add a barcode capture overlay to the data capture view to render the tracked barcodes on top of the video
            // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
            // to the view.
            self.barcodeCaptureOverlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture, view: captureView)

            // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of
            // feedback. With 6.10 we will introduce this visual treatment as a new style for the overlay.
            let brush = Brush(fill: .clear, stroke: .white, strokeWidth: 3)
            self.barcodeCaptureOverlay.brush = brush

            // We have to add the laser line viewfinder to the overlay.
            viewFinder = LaserlineViewfinder(style: .animated)
            //self.viewFinder.enabledColor = Utility.hexStringToUIColor(hex: "00AFEF")
            viewFinder.width = FloatWithUnit(value: 0.9, unit: .fraction)
            barcodeCaptureOverlay.viewfinder = viewFinder

            // We are resizing the capture view to not to take the whole screen,
            // but just fill it's parent, both horizontally and vertically.
            sectionView.addSubview(captureView)
            captureView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([
                captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                captureView.topAnchor.constraint(equalTo: view.topAnchor),
                captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                captureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            view.sendSubviewToBack(captureView)
        
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
            itemscountStackView.isHidden = true
            tableviewHeightConstant.constant = 0
        }else{
            upDownArrowButton.isSelected = true
            itemscountStackView.isHidden = false
            tableviewHeightConstant.constant = 200
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
    }
// MARK: - End

// MARK: - BarcodeCaptureListener

extension DPSingleScanViewController: BarcodeCaptureListener {
    
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
            let details = UtilityScanning(with:code).decoded_info
                if details.count <= 0 {
                    return
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
                                                Utility.showPopup(Title: App_Title, Message: "Product not found", InViewC: self)
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
                                self.viewFinder.enabledColor = Utility.hexStringToUIColor(hex: "00AFEF")
                                let brush = Brush(fill: .clear, stroke: Utility.hexStringToUIColor(hex: "00AFEF"), strokeWidth: 3)
                                self.barcodeCaptureOverlay.brush = brush
                                
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

                                self.viewFinder.enabledColor = UIColor.white
                                let brush = Brush(fill: .clear, stroke: .white, strokeWidth: 3)
                                self.barcodeCaptureOverlay.brush = brush

                                self.ismatchValue = false
                            }
                            self.tblProduct.reloadData()
                        }
                    
                }
            }
        }
    }
    
extension DPSingleScanViewController: UITableViewDelegate, UITableViewDataSource{
    
    
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
                
//                if indexArr.contains(indexPath.row) {
//                    cell.selectedButton.isHidden = false
//                }else{
//                    cell.selectedButton.isHidden = true
//
//                }
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
extension DPSingleScanViewController{

    @IBAction func done(_ sender: UIButton){
        
        self.removeDetailsView(completionHandler: {_ in
                self.addTriggerScanitemsinDatabase()
                self.delegate?.dpSingleScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                self.navigationController?.popViewController(animated: true)
        })
    }
   
    private func setupAfterAddScreen(){
        
        if lblHeader.text == "Add items to your list"{
            self.btnConfirm.isHidden = true
            self.btnClear.isHidden = true
        }else{
            self.btnConfirm.isHidden = false
            self.btnClear.isHidden = false
        }
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
               // self.setupAfterAddScreen()
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
    
    
    func addTriggerScanitemsinDatabase(){
        //self.delegate?.didLotBasedTriggerScanDetails!(arr: (arrLotProductList! as NSArray))
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


class DProductCell: UITableViewCell {
    
    @IBOutlet weak var lblProductCount: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var storagelable:UILabel!
    @IBOutlet weak var storageShelflable:UILabel!
    @IBOutlet weak var selectedButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
       // self.btnCount.layer.cornerRadius = self.btnCount.frame.height/2
       // self.btnCount.layer.borderWidth = 0.5
       // self.btnCount.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension DPSingleScanViewController: DataCaptureContextListener {
    func context(_ context: DataCaptureContext, didChange contextStatus: ContextStatus) {
        // This function is executed from a background queue, so we need to switch to the main queue
        // before doing any work with our timer.
        
    }

    func context(_ context: DataCaptureContext, didAdd mode: DataCaptureMode) {}

    func context(_ context: DataCaptureContext, didRemove mode: DataCaptureMode) {}

    func context(_ context: DataCaptureContext, didChange frameSource: FrameSource?) {}
}

