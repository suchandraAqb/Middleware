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

import ScanditBarcodeCapture
import UIKit

@objc protocol ScanViewControllerDelegate: class {
    @objc optional func didScanCompleteForEndPointURL(urlString:String)
    @objc optional func didScanCodeForReceive(codeDetails:[String : Any])
    @objc optional func didScanCodeForReceiveSerialVerification(scannedCode:[String])
    @objc optional func didScanCodeForReceiveSerialVerificationAndCodeDetails(scannedCode:[String], codeDetailsArray:[[String : Any]])//,,,sb11-2
    @objc optional func backToScanViewController()//,,,sb11-3
    @objc optional func didScanCodeForRemoveMultiple(willBeRemovedSerials:[String])
    @objc optional func didScanCodeForReturnShipmentSearch(codeDetails:[String : Any])
    @objc optional func didScanCodeForReturnSerialVerification(scannedCode:[String], condition : String)
    @objc optional func didScanCodeForReturnSerialVerification(scannedCode:[[String:String]])
    
    @objc optional func didScanCodeForInventoryCount(scannedCode:[String])
    
    @objc optional func didScanCodeForManualInboundShipment(scannedCode:[String])
    @objc optional func didLotBasedTriggerScanDetailsForLotBased(arr : NSArray)
    @objc optional func didScanCodeForFailedSerial(scannedCode : [String])
    @objc optional func didScanCodeFromAR(scannedCode:[String])
    @objc optional func didScanErrorMsgInTrigger(msg:String)
    @objc optional func triggerScanFailedArray(failedArr : [[String:Any]])

}
class MyTapGesture: UITapGestureRecognizer {
    var cV = CustomViewForMessageAR()
}
class ScanViewController: BaseViewController, ConfirmationViewDelegate{
    
    
    weak var delegate: ScanViewControllerDelegate?
    private enum Constants {
        static let barcodeToScreenTresholdRation: CGFloat = 0.1
        static let shelfCount = 4
        static let backRoomCount = 8
    }
    var isForEndPointURLScan: Bool = false
    var isForReceivingSerialVerificationScan: Bool = false
    var isForOnlyReceive : Bool = false
    var isForMultiRemove: Bool = false
    var isForInventory: Bool = false
    var isReturnShipmentSearch: Bool = false
    var isForReturnSerialVerificationScan: Bool = false
    var isForManualInbound: Bool = false
    
    var isForMessageAr: Bool = false
    var selectedMessageIndex:Int = -1
    var messageDict = Dictionary<String,Any>()

    var isOnlySerialFinederAR : Bool = false
    var isLookWithFilterAR : Bool = false //,,,sb11-2
    var isMatchOnlyAR : Bool = false //,,,sb11-2

    fileprivate var scannedCodes: Set<String> = []
    fileprivate var removedCodes: Set<String> = []
    fileprivate var scannedReturnCodes: Set<[String : String]> = []
    fileprivate var scannedCodesLookWithFilterAR_after: Set<String> = []//,,,sb11-2
    fileprivate var scannedCodesLookWithFilterAR_before: Set<String> = []//,,,sb11-2

    fileprivate var failedScan : Set<String> = []
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
    @IBOutlet weak var cameraContainer: UIView!
    
    @IBOutlet weak var returnConditionView: UIView!
    @IBOutlet weak var resalableButton: UIButton!
    @IBOutlet weak var quarantineButton: UIButton!
    @IBOutlet weak var destructButton: UIButton!
    var returnCondition: String = Return_Serials.Condition.Resalable.rawValue

    @IBOutlet weak var toggleTrackingButton: UISwitch!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noOfScannedSerials: UILabel!
    @IBOutlet weak var collectResults : UISwitch!
    @IBOutlet weak var collectResultsLabel : UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tblProduct: UITableView!
    @IBOutlet weak var upDownArrowButton:UIButton!
    @IBOutlet weak var itemscountStackView:UIStackView!
    @IBOutlet weak var tableviewHeightConstant:NSLayoutConstraint!
    @IBOutlet weak var serialScanLabelWidthConstant:NSLayoutConstraint!
    @IBOutlet weak var searchArButton:UIButton!
    //,,,sb11-2
    @IBOutlet weak var matchOnlyView: UIView!
    @IBOutlet weak var matchOnlySwitch: UISwitch!
    @IBOutlet weak var containerButton : UIButton!
    @IBOutlet weak var productButton:UIButton!
    //,,,sb11-2
    
    private var overlays: [Int: StockOverlay] = [:]
    private var overlaysCustom: [Int: CustomView] = [:]
    private var overlaysCustomForEndPointUrl: [Int: CustomViewOverlayForEndPointUrl] = [:]
    private var overlaysCustomForLookWithFilter: [Int: CustomViewForLookWithFilter] = [:]//,,,sb11-2

    private var overlaysCustomForMessageAR: [Int: CustomViewForMessageAR] = [:]

    private var overlaysCustomAll: [Int: UIImageView] = [:]
    var lineItemsArr : Array<Any>?
    var isReceiveProductInshipment:Bool!
    public var isForBottomSheetLotScan:Bool = false
    public var isForBottomSheetScan:Bool = false
    private var arrLotProductList : [ProductListModel]?
    var isTriggerEnableNotFound :Bool = false
    var failedItems = Array<Dictionary<String,Any>>()
    var pickSOItemDetails = NSDictionary()
    var isSOPickItemSelction : Bool = false
    var lotnumberselected : NSString!
    
    //,,,sb11-2
    var mainUUID = ""
    var lookWithfilterSearchArray = [[String : Any]]()
    var lookWithfilterSearchRequestDict = [String:Any]()
    //,,,sb11-2
    var dpProductList : Array<Any>?
    var isproductMatchInDpItems : Bool = false
    var containerProductCheckingArr = NSMutableArray()
    var isForPickingScanOption:Bool = false
    var isContainerScanEnable:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodes = []
        removedCodes = []
        scannedReturnCodes = []
        scannedCodesLookWithFilterAR_after = []//,,,sb11-2
        scannedCodesLookWithFilterAR_before = []//,,,sb11-2
        setupRecognition()
        sectionView.roundTopCorners(cornerRadious: 40)
        defaults.setValue(true, forKey: "collect_result")
        btnClear.setTitle("Clear All".localized(), for: UIControl.State.normal)//,,,sb-lang2
        matchOnlyView.isHidden = true //,,,sb11-5
        
        if isOnlySerialFinederAR {
            collectResults.isHidden = false
            collectResultsLabel.isHidden = false
            serialScanLabelWidthConstant.constant = 0
            doneButton.setImage(UIImage(named: ""), for: .normal)
            
            collectResults.isOn = false
            searchArButton.isHidden = false
            self.collectResultswitchAction_AR(collectResults)
            
            //,,,sb11-2
            if isLookWithFilterAR {
                collectResults.isHidden = true
                collectResultsLabel.isHidden = true
                
                matchOnlyView.isHidden = false
                matchOnlySwitch.isOn = false
                self.matchOnlySwitchAR(matchOnlySwitch)
            }
            else {
                matchOnlyView.isHidden = true
            }
            //,,,sb11-2

        }else{
            collectResults.isHidden = true
            collectResultsLabel.isHidden = true
            serialScanLabelWidthConstant.constant = 129
            doneButton.setImage(UIImage(named: "tick_circle_lg.png"), for: .normal)
            searchArButton.isHidden = true

        }
        if isForBottomSheetScan {
            itemscountStackView.isHidden = true
            tableviewHeightConstant.constant = 0
            upDownArrowButton.isSelected = false
            lblHeader.text = "Add items to your list".localized()//,,,sb-lang2
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
        unfreeze()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if failedItems.count > 0 && isForBottomSheetScan{
            self.delegate?.triggerScanFailedArray!(failedArr: self.failedItems)
        }
        freeze()
    }
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
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
        
        if isOnlySerialFinederAR {
            if isLookWithFilterAR {
                let str = "\(self.scannedCodesLookWithFilterAR_after.count) \n" + "found".localized()
                self.doneButton.setTitle( str, for: .normal)
            }//,,,sb11-2
            else {
                //,,,sb-lang2
    //            let str = "\(count) \nfound"
                let str = "\(count) \n" + "found".localized()
                //,,,sb-lang2
                
                doneButton.setTitle( str, for: .normal)
            }
        }
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
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        
        let symbologySettings = settings.settings(for: .dataMatrix)
        symbologySettings.isColorInvertedEnabled = true
        
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
        if isForMessageAr{
            captureView.scanAreaMargins = MarginsWithUnit(left: FloatWithUnit(value: 0.4, unit: .fraction),
            top: FloatWithUnit(value: 0.45, unit: .fraction),
            right: FloatWithUnit(value: 0.4, unit: .fraction),
            bottom: FloatWithUnit(value: 0.45, unit: .fraction))
        }
        
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sectionView.addSubview(captureView)
        sectionView.sendSubviewToBack(captureView)
        captureView.logoOffset = PointWithUnit(x: FloatWithUnit(value: captureView.frame.size.width - 10, unit: .pixel),
        y: FloatWithUnit(value: captureView.frame.size.height - 10, unit: .pixel))
        

        // Add a barcode tracking overlay to the data capture view to render the tracked barcodes on top of the video
        // preview. This is optional, but recommended for better visual feedback. The overlay is automatically added
        // to the view.
        DispatchQueue.main.async { [self] in
            overlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking, view: captureView)
            //overlay.shouldShowScanAreaGuides = true
            overlay.delegate = self
        }
        if (isForReceivingSerialVerificationScan || isForInventory
                || isForManualInbound || isForOnlyReceive || isOnlySerialFinederAR||isSOPickItemSelction || isproductMatchInDpItems){
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: false)
        }else if (isForReturnSerialVerificationScan){
            self.returnConditionView.isHidden = false
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: false)
        }else if(isForMultiRemove) {
            self.doneButton.isHidden = false
            self.noOfScannedSerials.isHidden = false
            self.populateItemsCount(isRemove: true)
        }else if(isForBottomSheetScan){
            self.doneButton.isHidden = true
            self.noOfScannedSerials.isHidden = true
        }else{
            self.doneButton.isHidden = true
            self.noOfScannedSerials.isHidden = true
            // Add another barcode tracking overlay to the data capture view to render other views. The overlay is
            // automatically added to the view.
        }
        self.returnConditionView.isHidden = !isForReturnSerialVerificationScan
        advancedOverlay = BarcodeTrackingAdvancedOverlay(barcodeTracking: barcodeTracking, view: captureView)
        advancedOverlay.delegate = self
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
    private func setupAfterAddScreen(){
        
        if lblHeader.text == "Add items to your list".localized(){//,,,sb-lang2
            self.btnConfirm.isHidden = true
            self.btnClear.isHidden = true
        }else{
            self.btnConfirm.isHidden = false
            self.btnClear.isHidden = false

        }
        //self.tblProduct.reloadSections([0], with: .automatic)
        //        self.lblHeader.text = productCount > 1 ? "\(productCount) items" : "\(productCount) item"
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
         self.tblProduct.reloadSections([0], with: .automatic)
        //,,,sb-lang2
//         self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) items" : "\(self.arrLotProductList?.count ?? 0) Item"
        self.lblHeader.text = self.arrLotProductList?.count ?? 0 > 1 ? "\(self.arrLotProductList?.count ?? 0) " + "items".localized() : "\(self.arrLotProductList?.count ?? 0) " + "Item".localized()
        //,,,sb-lang2
        
    }
    func ar_viewer_save_and_search_WebserviceCall(serials : String) {
        if !serials.isEmpty {
            self.scannedCodesLookWithFilterAR_before.insert(serials)//,,,sb11-2
            
            lookWithfilterSearchRequestDict["gs1_barcodes[]"] = serials

            let appendStr = ""
            Utility.POSTServiceCall(type: "ar_viewer_save_and_search", serviceParam:lookWithfilterSearchRequestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                    DispatchQueue.main.async{
                        if isDone! {
                            if let responseDict = responseData as? [String: Any] {
                                if let resultsArray: NSArray = responseDict["results"] as? NSArray {
                                    if resultsArray.count > 0 {
                                        if let serialDetailsArray = resultsArray as? [[String : Any]]{
        //                                    print("responseDict......",responseDict,serials)

                                            let verifiedItem = serialDetailsArray.first
//                                            var simpleserial = ""
//                                            if let simple_serial = verifiedItem?["simple_serial"] as? String {
//                                                simpleserial = simple_serial
//                                            }
                                            
                                            var filterMatch = "NOT_MATCHED" // MATCHED, NOT_MATCHED
                                            if let ar_filter_match_status = verifiedItem?["ar_filter_match_status"] as? String {
                                                filterMatch = ar_filter_match_status
                                            }
                                            if filterMatch == "MATCHED" {
                                                if !self.scannedCodesLookWithFilterAR_after.contains(serials){
                                                    self.scannedCodesLookWithFilterAR_before.remove(serials)
                                                    self.scannedCodesLookWithFilterAR_after.insert(serials)
                                                    self.lookWithfilterSearchArray.append(verifiedItem!)//,,,sb11-2
                                                }//,,,sb11-2
                                            }
                                            
                                            let str = "\(self.scannedCodesLookWithFilterAR_after.count) \n" + "found".localized()
                                            self.doneButton.setTitle( str, for: .normal)
                                        }
                                        else {
                                            self.scannedCodesLookWithFilterAR_before.remove(serials)

                                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                                        }
                                    }else {
                                        self.scannedCodesLookWithFilterAR_before.remove(serials)

                                        Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                                    }
                                }
                                else {
                                    self.scannedCodesLookWithFilterAR_before.remove(serials)
                                    
                                    Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                                }
                            }
                            else {
                                self.scannedCodesLookWithFilterAR_before.remove(serials)
                                
                                Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                            }
                        }else {
                            self.scannedCodesLookWithFilterAR_before.remove(serials)
                            
                            if responseData != nil{
                                let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                                let errorMsg = responseDict["message"] as? String ?? ""
                              //  Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)

                            }else{
                               // Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                            }
                        }
                    }
            }

        }
        
    }//,,,sb11-2
    private func ar_viewer_search_webserviceCall(serials : String) {
        //self.showSpinner(onView: self.captureView)
        
        if !serials.isEmpty {
            self.scannedCodesLookWithFilterAR_before.insert(serials)//,,,sb11-2
            
            let str = serials.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let appendStr = "/\(mainUUID)/search?gs1_barcodes=\(str ?? "")"

            Utility.GETServiceCall(type: "ar_viewer_search", serviceParam:{}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                // DispatchQueue.main.async{
               // self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let resultsArray: NSArray = responseDict["results"] as? NSArray {
                            if resultsArray.count > 0 {
                                if let serialDetailsArray = resultsArray as? [[String : Any]]{
//                                    print("responseDict......",responseDict,serials)

                                    let verifiedItem = serialDetailsArray.first
//                                    var simpleserial = ""
//                                    if let simple_serial = verifiedItem?["simple_serial"] as? String {
//                                        simpleserial = simple_serial
//                                    }
                                    
                                    var filterMatch = "NOT_MATCHED" // MATCHED, NOT_MATCHED
                                    if let ar_filter_match_status = verifiedItem?["ar_filter_match_status"] as? String {
                                        filterMatch = ar_filter_match_status
                                    }
                                    if filterMatch == "MATCHED" {
                                        if !self.scannedCodesLookWithFilterAR_after.contains(serials){
                                            self.scannedCodesLookWithFilterAR_before.remove(serials)
                                            self.scannedCodesLookWithFilterAR_after.insert(serials)
                                            self.lookWithfilterSearchArray.append(verifiedItem!)//,,,sb11-2
                                        }//,,,sb11-2
                                    }
                                    
                                    let str = "\(self.scannedCodesLookWithFilterAR_after.count) \n" + "found".localized()
                                    self.doneButton.setTitle( str, for: .normal)
                                }
                                else {
                                    self.scannedCodesLookWithFilterAR_before.remove(serials)

                                    Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                                }
                            }else {
                                self.scannedCodesLookWithFilterAR_before.remove(serials)

                                Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                            }
                        }
                        else {
                            self.scannedCodesLookWithFilterAR_before.remove(serials)
                            
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                        }
                    }
                    else {
                        self.scannedCodesLookWithFilterAR_before.remove(serials)
                        
                        Utility.showPopup(Title: App_Title, Message: "Something went wrong. Try again later.".localized() , InViewC: self)
                    }
                }else {
                    self.scannedCodesLookWithFilterAR_before.remove(serials)
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as? NSDictionary ?? NSDictionary()
                        let errorMsg = responseDict["message"] as? String ?? ""
                       // Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)

                    }else{
                       // Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }else {
            DispatchQueue.main.async{
                self.removeSpinner()
            }
        }
    }//,,,sb11-2
    private func getGS1BarcodeLookupDetails(serials : String,productName: String , uuid: String , lotnumber:String , gtin14:String){
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
                                return
                            }
                            if verifiedItem?["status"] as? String == "LOT_FOUND" && self.isSOPickItemSelction{
                                self.isTriggerEnableNotFound = true
                                return

                            }
                            if verifiedItem?["status"] as? String == "LOT_FOUND" && !self.isSOPickItemSelction{
                                self.isTriggerEnableNotFound = false
                                self.isForBottomSheetLotScan = true
                                if !self.gs1ValidScan.contains(serials){
                                    self.gs1ValidScan.insert(serials)
                                    
                                    if !self.scannedCodes.contains(serials){
                                        self.scannedCodes.insert(serials)
                                    }
                                        
                                    self.populatelotProductDetails(code: serials, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                }
                                
                            }else if verifiedItem?["status"] as? String == "FOUND" {
                                self.isForBottomSheetLotScan = false
                                if self.isSOPickItemSelction {
                                    if (self.pickSOItemDetails["product_uuid"] as? String == verifiedItem?["product_uuid"] as? String) && (self.lotnumberselected.isEqual(to: ((verifiedItem?["lot_number"] as? String)!))) {
                                            self.isTriggerEnableNotFound = false

                                        if !self.gs1ValidScan.contains(serials){
                                            self.gs1ValidScan.insert(serials)
                                            
                                            if !self.scannedCodes.contains(serials){
                                                self.scannedCodes.insert(serials)
                                            }
                                                
                                            self.populatelotProductDetails(code: serials, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                        }
                                    }else{
                                        self.isTriggerEnableNotFound = true

                                    }
                                }else{
                                    self.isTriggerEnableNotFound = false

                                    if !self.gs1ValidScan.contains(serials){
                                        self.gs1ValidScan.insert(serials)
                                        
                                        if !self.scannedCodes.contains(serials){
                                            self.scannedCodes.insert(serials)
                                        }
                                            
                                        self.populatelotProductDetails(code: serials, productName: productName, uuid: uuid, productGtin14: gtin14, lotNumber: lotnumber)
                                        }
                                }

                            }else if verifiedItem?["status"] as? String == "FOUND"{
                                print("ERROR ::: ALREADY LOT PRODUCT ADDED TO SESSION")
                            }else if verifiedItem?["status"] as? String == "NOT_FOUND"{
                                if !self.gs1InvalidScan.contains(serials){
                                    self.gs1InvalidScan.insert(serials)
                                }
                                self.isTriggerEnableNotFound = true
                                
                                if self.isOnlySerialFinederAR {
                                    if !self.scannedCodes.contains(serials){
                                        self.scannedCodes.insert(serials)
                                    }
                                    self.populateItemsCount(isRemove: false)
                                }
                                else{
                                    if !(self.failedItems as NSArray).contains(verifiedItem!){
                                        self.failedItems.append(verifiedItem!)
                                    }
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
        }
    }
    func addTriggerScanitemsindatabase(){
        self.delegate?.didLotBasedTriggerScanDetailsForLotBased!(arr: (arrLotProductList! as NSArray))
//        if arrLotProductList!.count>0{
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
                        var data = [String:String]()
                        data["code"] = code as String
                        data["condition"] = self.returnCondition
                        self.scannedReturnCodes.insert(data)
                        isReceiveProductInshipment = true;
                        self.scannedCodes.insert(code as String)
                        }
                }else{
                       isReceiveProductInshipment = false
                        if !failedScan.contains(code as String){
                            failedScan.insert(code as String)
                        }
                }
            }else{
                    if !self.scannedCodes.contains(code as String) {
                        var data = [String:String]()
                        data["code"] = code as String
                        data["condition"] = self.returnCondition
                        self.scannedReturnCodes.insert(data)
                        isReceiveProductInshipment = true;
                        self.scannedCodes.insert(code as String)
                        }
                    }
                }else{
                    isReceiveProductInshipment = false
                    if !failedScan.contains(code as String){
                        failedScan.insert(code as String)
                    }
                }
                self.populateItemsCount(isRemove: false)

            }else{
                isReceiveProductInshipment = false
                if !failedScan.contains(code as String){
                    failedScan.insert(code as String)
                }
            }
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
    @IBAction func removeAll(_ sender: UIButton){
        Utility.showAlertDefaultWithPopAction(Title: "Alert".localized(), Message: "Are you sure you want to delete all items?".localized(), InViewC: self) {//,,,sb-lang2
            self.arrLotProductList?.removeAll()
            self.scannedCodes.removeAll()
            self.tblProduct.reloadSections([0], with: .automatic)
            self.lblHeader.text = "Add items to your list".localized()//,,,sb-lang2
            self.setupAfterAddScreen()       //  self.removeDetailsView()
        }
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        if (isForReceivingSerialVerificationScan || isForOnlyReceive || isOnlySerialFinederAR||isSOPickItemSelction||isproductMatchInDpItems){
            
            //,,,sb11-2
//            self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
            if isLookWithFilterAR {
                self.delegate?.didScanCodeForReceiveSerialVerificationAndCodeDetails?(scannedCode: Array(self.scannedCodes), codeDetailsArray: lookWithfilterSearchArray)
            }
            else if isForPickingScanOption {
                
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
                        self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
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
                        self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                    }
                }
            }else{
                self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
            }
            //,,,sb11-2
            if isForOnlyReceive {
                self.delegate?.didScanCodeForFailedSerial?(scannedCode: Array(self.failedScan))
            }
            self.navigationController?.popViewController(animated: true)

        }else if (isForReturnSerialVerificationScan){
            self.navigationController?.popViewController(animated: true)
           // self.delegate?.didScanCodeForReturnSerialVerification?(scannedCode: Array(self.scannedCodes), condition: returnCondition)
            self.delegate?.didScanCodeForReturnSerialVerification?(scannedCode: Array(self.scannedReturnCodes))
            
        }else if(isForMultiRemove){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didScanCodeForRemoveMultiple?(willBeRemovedSerials: Array(self.removedCodes))
        }else if(isForInventory){
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didScanCodeForInventoryCount?(scannedCode: Array(self.scannedCodes))
        }else if isForManualInbound{
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didScanCodeForManualInboundShipment?(scannedCode: Array(self.scannedCodes))
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
    
    @IBAction func collectResultswitchAction_AR(_ sender: UISwitch){
            if sender.isOn{
                    tableviewHeightConstant.constant = 0
                    upDownArrowButton.isSelected = false
                    lblHeader.text = "Add items to your list"
                    self.addDetailsView()
                    
                    self.doneButton.isHidden = false
                    self.noOfScannedSerials.isHidden = false
                    self.populateItemsCount(isRemove: false)

                    
                    isForBottomSheetScan = true
                    itemscountStackView.isHidden = true
                    searchArButton.isHidden = false

                }else{
                    self.removeDetailsView()
                    isForBottomSheetScan = false
                    itemscountStackView.isHidden = false
                    searchArButton.isHidden = false
                    
                    self.doneButton.isHidden = false
                    self.noOfScannedSerials.isHidden = false
                    self.populateItemsCount(isRemove: false)

                }
            
        }
    func doneButtonPressed() {
        //,,,sb11-3
        if (isLookWithFilterAR) {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.backToScanViewController?()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        //,,,sb11-3
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
    @IBAction func increaseProduct(_ sender: UIButton){
        print("Plus")
        self.arrLotProductList?[sender.tag].productCount! += 1
        self.tblProduct.reloadSections([0], with: .automatic)
    }
    @IBAction func deleteProduct(_ sender: UIButton){
        
        Utility.showAlertDefaultWithPopAction(Title: "Alert".localized(), Message: "Are you sure you want to delete this item?".localized(), InViewC: self) {//,,,sb-lang2
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
                self.lblHeader.text = "Add items to your list".localized()//,,,sb-lang2
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
    
    @IBAction func done(_ sender: UIButton){
        
        self.removeDetailsView(completionHandler: {_ in
            self.addTriggerScanitemsindatabase()
            self.delegate?.didScanCodeForReceiveSerialVerification?(scannedCode: Array(self.scannedCodes))
                self.navigationController?.popViewController(animated: true)
        })
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
    @IBAction func matchOnlySwitchAR(_ sender: UISwitch) {
        if sender.isOn{
            isMatchOnlyAR = true
        }else {
            isMatchOnlyAR = false
            
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
        //,,,sb11-2
//    @IBAction func triggerScanEnableSwitch(_ sender: UISwitch){
//        if sender.isOn{
//            tableviewHeightConstant.constant = 0
//            upDownArrowButton.isSelected = false
//            lblHeader.text = "Add items to your list"
//            self.addDetailsView()
//
//            self.doneButton.isHidden = true
//            self.noOfScannedSerials.isHidden = true
//
//            isForBottomSheetScan = true
//            itemscountStackView.isHidden = true
//            isOnlySerialFinederAR = false
//
//        }else{
//            isForBottomSheetScan = false
//            itemscountStackView.isHidden = false
//            isOnlySerialFinederAR = true
//
//            self.doneButton.isHidden = false
//            self.noOfScannedSerials.isHidden = false
//            self.populateItemsCount(isRemove: false)
//        }
//    }
    
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
    private func customOverlay(for trackedCode: TrackedBarcode) -> CustomView {
        let identifier = trackedCode.identifier
        var overlayTemp: CustomView
        if overlaysCustom.keys.contains(identifier) {
            overlayTemp = overlaysCustom[identifier]!
        } else {
            // Get the information you want to show from your back end system/database.
            //overlayTemp = CustomView().loadView(barCode: trackedCode)
            //overlayTemp = CustomView(frame: CGRect(x: 0, y: 0, width: 260, height: 56))
            overlayTemp = CustomView().prepareView(barCode: trackedCode)
            overlayTemp.delegate = self
            overlaysCustom[identifier] = overlayTemp
            overlayTemp.sizeToFit()

        }
        overlayTemp.isHidden = !canShowOverlay(of: trackedCode)
        return overlayTemp
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

            if(scannedCodesLookWithFilterAR_after.contains(trackedCode.barcode.data!)){
                if self.isMatchOnlyAR {
                    overlayTemp.mainContainerView.backgroundColor = UIColor.white
                    overlayTemp.triangleImageView.image = UIImage.init(named: "triangle")

                }else {
                    overlayTemp.mainContainerView.backgroundColor = Utility.hexStringToUIColor(hex: "FEF851")
                    overlayTemp.triangleImageView.image = UIImage.init(named: "yelow_triangle")
                }
            }
            //,,,sb11-2
            
            overlayTemp.sizeToFit()
        }
        overlayTemp.isHidden = !canShowOverlay(of: trackedCode)
        return overlayTemp
    }//,,,sb11-2
    private func customOverlayForEndPointUrl(for trackedCode: TrackedBarcode) -> CustomViewOverlayForEndPointUrl {
        let identifier = trackedCode.identifier
        var overlay: CustomViewOverlayForEndPointUrl
        if overlaysCustomForEndPointUrl.keys.contains(identifier) {
            overlay = overlaysCustomForEndPointUrl[identifier]!
        } else {
            // Get the information you want to show from your back end system/database.
            overlay = CustomViewOverlayForEndPointUrl().loadView(barCode: trackedCode)
            overlay.delegate = self
            overlaysCustomForEndPointUrl[identifier] = overlay
        }
        overlay.isHidden = !canShowOverlay(of: trackedCode)
        return overlay
    }
    private func customOverlayForMessageAR(for trackedCode: TrackedBarcode) -> CustomViewForMessageAR {
        let identifier = trackedCode.identifier
        var overlay: CustomViewForMessageAR
        if overlaysCustomForMessageAR.keys.contains(identifier) {
            overlay = overlaysCustomForMessageAR[identifier]!
        } else {
            // Get the information you want to show from your back end system/database.
            overlay = CustomViewForMessageAR().loadView(message :messageDict)
            overlaysCustomForMessageAR[identifier] = overlay
            let tap = MyTapGesture(target: self, action: #selector(self.handleTap(_:)))
            tap.cV = overlay
            overlay.addGestureRecognizer(tap)
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
            /*
            if(removedCodes.contains(trackedCode.barcode.data!)){
                overlay.image = UIImage.init(named: "red_cross")//red_cross
            }else if(scannedCodes.contains(trackedCode.barcode.data!)) && !isForMultiRemove && !isTriggerEnableNotFound{
                overlay.image = UIImage.init(named: "green_tick")
            }else if(scannedCodes.contains(trackedCode.barcode.data!)) && isForMultiRemove{
                overlay.image = UIImage.init(named: "green_tick")
            }else if (isReceiveProductInshipment != nil) && !isReceiveProductInshipment{
                overlay.image = UIImage.init(named: "red_cross")
            }else if (isTriggerEnableNotFound){
                overlay.image = UIImage.init(named: "red_cross")
            }else{
                if  (isReceiveProductInshipment != nil) && !isReceiveProductInshipment{
                    overlay.image = UIImage.init(named: "blue1_tick")
                }
                
            }
             */
            if isLookWithFilterAR {
                overlay.image = UIImage.init(named: "red_cross")//gray_cross
            }else if(removedCodes.contains(trackedCode.barcode.data!)){
                    overlay.image = UIImage.init(named: "red_cross")//red_cross
            }else if(scannedCodes.contains(trackedCode.barcode.data!)) && !isForMultiRemove && !isTriggerEnableNotFound{
                    overlay.image = UIImage.init(named: "green_tick")
            }else if(scannedCodes.contains(trackedCode.barcode.data!)) && isForMultiRemove{
                    overlay.image = UIImage.init(named: "green_tick")
            }else if (isReceiveProductInshipment != nil) && !isReceiveProductInshipment{
                    overlay.image = UIImage.init(named: "red_cross")
            }else if (isTriggerEnableNotFound){
                    overlay.image = UIImage.init(named: "red_cross")
            }else if (isproductMatchInDpItems){
                if scannedCodes.contains(trackedCode.barcode.data!){
                    overlay.image = UIImage.init(named: "green_tick")
                }else{
                    overlay.image = UIImage.init(named: "red_cross")
                }
            }else{
                if  (isReceiveProductInshipment != nil) && !isReceiveProductInshipment{
                    overlay.image = UIImage.init(named: "blue1_tick")
                }
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
    
   
    private func canShowOverlay(of trackedCode: TrackedBarcode) -> Bool {
        //let captureViewWidth = captureView.frame.width

        // If the barcode is wider than the desired percent of the data capture view's width,
        // show it to the user.
        ////return (width / captureViewWidth) >= Constants.barcodeToScreenTresholdRation
        return true
    }
    
    
}
// MARK: - Barcode extension

extension Barcode {
    var isRejected: Bool {
        return data?.first == "7"
    }
    var decodedInfo: [String :[String : Any]] {
        return UtilityScanning(with:data!).decoded_info
    }
}

// MARK: - BarcodeTrackingListener

extension ScanViewController: BarcodeTrackingListener {

    // This function is called whenever objects are updated and it's the right place to react to the tracking results.
    func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                         didUpdate session: BarcodeTrackingSession,
                         frameData: FrameData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.barcodeTracking.isEnabled {
                return
            }
            /*
             for identifier in session.removedTrackedBarcodes {
             self.overlays.removeValue(forKey: identifier.intValue)
             }
             for trackedCode in session.trackedBarcodes.values {
             
             guard let code = trackedCode.barcode.data, !code.isEmpty else {
             return
             }
             if !self.scannedCodes.contains(code) {
             self.scannedCodes.insert(code)
             }
             
             self.overlays[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
             }
             */
//            if !session.addedTrackedBarcodes.isEmpty {
//                self.feedback?.emit()
//            }
            for identifier in session.removedTrackedBarcodes {
                if (self.isForReceivingSerialVerificationScan || self.isForInventory || self.isForMultiRemove || self.isForReturnSerialVerificationScan || self.isForManualInbound || self.isForOnlyReceive || self.isOnlySerialFinederAR || self.isForBottomSheetScan || self.isSOPickItemSelction || self.isproductMatchInDpItems){
                    
                    //,,,sb11-2
//                    self.overlaysCustomAll.removeValue(forKey: identifier.intValue)

                    if self.isLookWithFilterAR {
                        if self.isMatchOnlyAR {
                            self.overlaysCustomForLookWithFilter.removeValue(forKey: identifier.intValue)
                            self.overlaysCustomAll.removeValue(forKey: identifier.intValue)
                        }
                        else {
                            self.overlaysCustomForLookWithFilter.removeValue(forKey: identifier.intValue)
                        }
                    }else {
                        self.overlaysCustomAll.removeValue(forKey: identifier.intValue)
                    }
                    //,,,sb11-2
                    
                    
                }else if self.isForEndPointURLScan{
                    self.overlaysCustomForEndPointUrl.removeValue(forKey: identifier.intValue)
                }else if self.isForMessageAr{
                    self.overlaysCustomForMessageAR.removeValue(forKey: identifier.intValue)
                }else{
                    self.overlaysCustom.removeValue(forKey: identifier.intValue)
                }
            }
            for trackedCode in session.trackedBarcodes.values {
//                guard let code = trackedCode.barcode.data, !code.isEmpty else {
//                    return
//                }
//                if !self.scannedCodes.contains(code) {
//                    if(!self.isForMultiRemove) {
//                        self.feedback?.emit()
//                    }
//                    self.scannedCodes.insert(code)
//                }
                if (self.isForReceivingSerialVerificationScan || self.isForInventory || self.isForMultiRemove || self.isForReturnSerialVerificationScan || self.isForManualInbound || self.isForOnlyReceive || self.isOnlySerialFinederAR || self.isForBottomSheetScan||self.isSOPickItemSelction || self.isproductMatchInDpItems){
                                    
                    //,,,sb11-2
//                    self.overlaysCustomAll[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                    if self.isLookWithFilterAR {
                        if self.isMatchOnlyAR {
                            if(self.scannedCodesLookWithFilterAR_after.contains(trackedCode.barcode.data!)){
                                self.overlaysCustomForLookWithFilter[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                            }
                            else {
                                self.overlaysCustomAll[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                            }
                        }
                        else {
                            self.overlaysCustomForLookWithFilter[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)

                        }
                    }
                    else {
                        self.overlaysCustomAll[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                    }
                    //,,,sb11-2
                    
                    
                }else if self.isForEndPointURLScan{
                    self.overlaysCustomForEndPointUrl[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                }else if self.isForMessageAr{
                    self.overlaysCustomForMessageAR[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                }else{
                    self.overlaysCustom[trackedCode.identifier]?.isHidden = !self.canShowOverlay(of: trackedCode)
                }
            }
            if (self.isForReceivingSerialVerificationScan || self.isForInventory || self.isForReturnSerialVerificationScan || self.isForManualInbound || self.isForOnlyReceive || self.isOnlySerialFinederAR||self.isSOPickItemSelction || self.isproductMatchInDpItems){
                self.populateItemsCount(isRemove: false)
            }
        }
    }
}

// MARK: - BarcodeTrackingBasicOverlayDelegate
extension ScanViewController: BarcodeTrackingBasicOverlayDelegate {
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
        if(isForMultiRemove){
            if(removedCodes.contains(trackedBarcode.barcode.data!)){
                let identifier = trackedBarcode.identifier
                if overlaysCustomAll.keys.contains(identifier) {
                    let imageView = overlaysCustomAll[identifier]!
                    imageView.image = UIImage.init(named: "green_tick")

//                    if(scannedCodes.contains(trackedBarcode.barcode.data!)){
//                        imageView.image = UIImage.init(named: "green_tick")
//                    }else{
//                        imageView.image = UIImage.init(named: "blue1_tick")
//                    }
                }
                overlay.setBrush(Brush.highlighted, for: trackedBarcode)
                removedCodes.remove(trackedBarcode.barcode.data!)
            }else{
                let identifier = trackedBarcode.identifier
                if overlaysCustomAll.keys.contains(identifier) {
                    let imageView = overlaysCustomAll[identifier]!
                    imageView.image = UIImage.init(named: "red_cross")
                }
                overlay.setBrush(Brush.removed, for: trackedBarcode)
                removedCodes.insert(trackedBarcode.barcode.data!)
                self.feedback?.emit()
            }
            self.populateItemsCount(isRemove: true)
        }
    }
}

// MARK: - BarcodeTrackingAdvancedOverlayDelegate
extension ScanViewController: BarcodeTrackingAdvancedOverlayDelegate {
    
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        viewFor trackedBarcode: TrackedBarcode) -> UIView? {
        //return stockOverlay(for: trackedBarcode)
        guard let code = trackedBarcode.barcode.data, !code.isEmpty else {
            return nil
        }
        var overlayTemp : UIView
        if (isForReceivingSerialVerificationScan || isForInventory || isForMultiRemove || isForReturnSerialVerificationScan || self.isForManualInbound || isForOnlyReceive || isOnlySerialFinederAR || isForBottomSheetScan || isSOPickItemSelction || isproductMatchInDpItems){
            
            //,,,sb11-2
//            overlayTemp = customOverlayForAll(for: trackedBarcode)
            if isLookWithFilterAR {
                if isMatchOnlyAR {
                    if(scannedCodesLookWithFilterAR_after.contains(trackedBarcode.barcode.data!)){
                        overlayTemp = customOverlayForLookWithFilter(for: trackedBarcode)
                    }
                    else {
                        overlayTemp = customOverlayForAll(for: trackedBarcode)
                    }
                }
                else {
                    overlayTemp = customOverlayForLookWithFilter(for: trackedBarcode)
                }
            }
            else {
                overlayTemp = customOverlayForAll(for: trackedBarcode)
            }
            //,,,sb11-2
            
            
        }else if self.isForEndPointURLScan{
            overlayTemp = customOverlayForEndPointUrl(for: trackedBarcode)
        }else if self.isForMessageAr{
            overlayTemp = customOverlayForMessageAR(for: trackedBarcode)
        }else{
            overlayTemp = customOverlay(for: trackedBarcode)
        }
        let details = UtilityScanning(with:code).decoded_info
        if details.count <= 0 {
            return nil
        }
        if !self.scannedCodes.contains(code){
            if(!self.isForMultiRemove) {
                self.feedback?.emit()
            }
            if self.isForReturnSerialVerificationScan{
                var data = [String:String]()
                data["code"] = code
                data["condition"] = self.returnCondition
                self.scannedReturnCodes.insert(data)

            }
            
            //print("================================\(trackedBarcode.barcode.jsonString)")
            if self.isForMultiRemove  && !scannedCodes.contains(code) {
                self.removedCodes.insert(code)
                self.scannedCodes.insert(code)
                self.populateItemsCount(isRemove: true)

            }else{
                if (!isForOnlyReceive && !isForBottomSheetScan && !isSOPickItemSelction && !isproductMatchInDpItems){
                    self.scannedCodes.insert(code)
                }
                self.overlay.setBrush(.newlyAdded, for: trackedBarcode)
            }
        }else{
//            if(removedCodes.contains(trackedBarcode.barcode.data!)){
//                self.overlay.setBrush(.removed, for: trackedBarcode)
//            }else{
                self.overlay.setBrush(.highlighted, for: trackedBarcode)
//            }
        }
        if self.isForBottomSheetScan {//&& !scannedCodes.contains(code)
            
            let details = UtilityScanning(with:code).decoded_info
            if details.count > 0 {
                var containerSerialNumber = ""
                var productName = ""
                var productGtin14 = ""
                var serialNumber = ""
                var lotNumber = ""
                var expirationDate = ""
                var uuid = ""
                var productIdentifier = ""

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
                                            uuid = (filteredArray.first?["uuid"] as? String)!
                                        }else{
                                            let productDict = Utility.gtin14ToNdc(gtin14str: productGtin14)
                                            if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                productName = product_name
                                            }
                                            if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                productIdentifier = product_identifier
                                            }
                                            if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
                                                uuid = product_uuid
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
                        
                        if (details.keys.contains("17")){
                            if let expiration = details["17"]?["value"] as? String{
                                let splitarr = expiration.split(separator: "T")
                                if splitarr.count>0{
                                    expirationDate = String(splitarr[0])
                                }
                            }
                        }
                        if(details.keys.contains("21")){
                            if let serial = details["21"]?["value"] as? String{
                                serialNumber = serial
                            }
                        }
                    
                if (lineItemsArr != nil) && !lineItemsArr!.isEmpty{
                    let lineitem = lineItemsArr! as NSArray
                    let predicate : NSPredicate
                    if productGtin14 == "" {
                         predicate = NSPredicate(format: "ndc = '\(productIdentifier)'")
                        
                    }else{
                         predicate = NSPredicate(format: "gtin14 = '\(productGtin14)'")

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
                                    isReceiveProductInshipment = true;
                                    }
                            }else{
                                   isReceiveProductInshipment = false
                                    if !failedScan.contains(code as String){
                                        failedScan.insert(code as String)
                                    }
                            }
                        }else{
                                if !self.scannedCodes.contains(code as String) {
                                    isReceiveProductInshipment = true;
                                    }
                                }
                            }else{
                                isReceiveProductInshipment = false
                                if !failedScan.contains(code as String){
                                    failedScan.insert(code as String)
                                }
                            }
                            self.populateItemsCount(isRemove: false)

                        }else{
                            isReceiveProductInshipment = false
                            if !failedScan.contains(code as String){
                                failedScan.insert(code as String)
                            }
                        }
                    self.delegate?.didScanCodeForFailedSerial?(scannedCode: Array(self.failedScan))

                    if isReceiveProductInshipment != nil && isReceiveProductInshipment{
                     DispatchQueue.main.async {
                         if self.gs1ValidScan.contains(code){
                            self.isTriggerEnableNotFound = false
                         }else if (self.gs1InvalidScan.contains(code)){
                            self.isTriggerEnableNotFound = true
                        }else{
                            self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, lotnumber: lotNumber, gtin14: productGtin14)
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        if self.gs1ValidScan.contains(code){
                           self.isTriggerEnableNotFound = false
                        }else if (self.gs1InvalidScan.contains(code)){
                           self.isTriggerEnableNotFound = true
                       }else{
                           self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, lotnumber: lotNumber, gtin14: productGtin14)
                           }
                       }
                    
                   }
                }
              }
            }
        if self.isOnlySerialFinederAR || self.isForReceivingSerialVerificationScan || self.isForInventory || self.isSOPickItemSelction{
            
         let details = UtilityScanning(with:code).decoded_info
            if details.count > 0 {
                
                //,,,sb11-2

                if isLookWithFilterAR {
                    if !scannedCodesLookWithFilterAR_before.contains(code) && !scannedCodesLookWithFilterAR_after.contains(code) {
                        
                        if mainUUID == "" {
                            self.ar_viewer_save_and_search_WebserviceCall(serials: code)
                        }
                        else {
                            self.ar_viewer_search_webserviceCall(serials: code)
                        }
                    }
                }else{
                var containerSerialNumber = ""
                var productName = ""
                var productGtin14 = ""
                var serialNumber = ""
                var lotNumber = ""
                var expirationDate = ""
                var uuid = ""
                var productIdentifier = ""

                if(details.keys.contains("00")){
                    if let cSerial = details["00"]?["value"] as? String{
                        containerSerialNumber = cSerial
                    }else if let cSerial = details["00"]?["value"] as? NSNumber{
                        containerSerialNumber = "\(cSerial)"
                    }
                    if isForPickingScanOption {
                        let dict = NSMutableDictionary()
                        dict.setValue("CONTAINER", forKey: "type")
                        dict.setValue(code, forKey: "Value")
                        if !containerProductCheckingArr.contains(dict){
                            containerProductCheckingArr.add(dict)
                        }
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
                                            uuid = (filteredArray.first?["uuid"] as? String)!
                                        }else{
                                            let productDict = Utility.gtin14ToNdc(gtin14str: productGtin14)
                                            if let product_name = productDict["name"] as? String,!product_name.isEmpty{
                                                productName = product_name
                                            }
                                            if let product_identifier = productDict["identifier_us_ndc"] as? String,!product_identifier.isEmpty{
                                                productIdentifier = product_identifier
                                            }
                                            if let product_uuid = productDict["uuid"] as? String,!product_uuid.isEmpty{
                                                uuid = product_uuid
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
                        
                        if (details.keys.contains("17")){
                            if let expiration = details["17"]?["value"] as? String{
                                let splitarr = expiration.split(separator: "T")
                                if splitarr.count>0{
                                    expirationDate = String(splitarr[0])
                                }
                            }
                        }
                        if(details.keys.contains("21")){
                            if let serial = details["21"]?["value"] as? String{
                                serialNumber = serial
                            }
                        }
                    if isForPickingScanOption {
                        let dict = NSMutableDictionary()
                        dict.setValue("PRODUCT", forKey: "type")
                        dict.setValue(code, forKey: "Value")
                        if !containerProductCheckingArr.contains(dict){
                            containerProductCheckingArr.add(dict)
                        }
                    }
                }
                DispatchQueue.main.async {
                    if self.gs1ValidScan.contains(code){
                       self.isTriggerEnableNotFound = false
                    }else if (self.gs1InvalidScan.contains(code)){
                       self.isTriggerEnableNotFound = true
                   }else{
                       self.getGS1BarcodeLookupDetails(serials: code, productName: productName, uuid: uuid, lotnumber: lotNumber, gtin14: productGtin14)
                       }
                   }
                }//,,,sb11-2
            }
        }
        if isproductMatchInDpItems{
            var containerSerialNumber = ""
            var productName = ""
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
                arr.addObjects(from: dpProductList!)
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
        }
        if self.isForReceivingSerialVerificationScan || self.isForInventory || self.isForReturnSerialVerificationScan || self.isOnlySerialFinederAR || self.isForManualInbound || self.isForOnlyReceive||self.isSOPickItemSelction || self.isproductMatchInDpItems{
            self.populateItemsCount(isRemove: false)
        }
        if isForOnlyReceive {
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
        
    
}
        return overlayTemp

}
    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        anchorFor trackedBarcode: TrackedBarcode) -> Anchor {
        // The offset of our overlay will be calculated from the top center anchoring point.
        if (isForReceivingSerialVerificationScan || isForInventory || isForMultiRemove || isForReturnSerialVerificationScan || isForOnlyReceive || isOnlySerialFinederAR || isForBottomSheetScan||isSOPickItemSelction || isproductMatchInDpItems){
            //,,,sb11-2
            /*
            if isLookWithFilterAR {
                if self.isMatchOnlyAR {
                    if(self.scannedCodesLookWithFilterAR_after.contains(trackedBarcode.barcode.data!)){
                        return .center
                    }
                    else {
                        return .center
                    }
                }
                else {
                    return .center
                }
            }
            else {
                return .center
            }
             */
            return .center
            //,,,sb11-2
           
        }else if(isForMessageAr){
            return .topCenter
        }else{
            return .bottomCenter
        }
    }

    func barcodeTrackingAdvancedOverlay(_ overlay: BarcodeTrackingAdvancedOverlay,
                                        offsetFor trackedBarcode: TrackedBarcode) -> PointWithUnit {
        // We set the offset's height to be equal of the 100 percent of our overlay.
        // The minus sign means that the overlay will be above the barcode.
        if (isForReceivingSerialVerificationScan || isForInventory || isForMultiRemove || isForReturnSerialVerificationScan || isForOnlyReceive || isOnlySerialFinederAR || isForBottomSheetScan||isSOPickItemSelction || isproductMatchInDpItems){
        
            
            //,,,sb11-2
//            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
//                                 y: FloatWithUnit(value: 0, unit: .fraction))

            if isLookWithFilterAR {
                
                
                if isMatchOnlyAR {
                    if(scannedCodesLookWithFilterAR_after.contains(trackedBarcode.barcode.data!)){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            if let overlayTemp = self.overlaysCustomForLookWithFilter[trackedBarcode.identifier]{
                                overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                            }
                        }
                        return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                             y: FloatWithUnit(value: 0.5, unit: .fraction))
                    }
                    else {
                        return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                             y: FloatWithUnit(value: 0, unit: .fraction))
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if let overlayTemp = self.overlaysCustomForLookWithFilter[trackedBarcode.identifier]{
                            overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                        }
                    }
                    return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                         y: FloatWithUnit(value: 0.5, unit: .fraction))
                }
        
            }
            else {
                return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                     y: FloatWithUnit(value: 0, unit: .fraction))
            }
            //,,,sb11-2
        }else if(isForMessageAr){
            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                 y: FloatWithUnit(value: -0.5, unit: .fraction))
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if let overlayTemp = self.overlaysCustom[trackedBarcode.identifier]{
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                }
            }
            return PointWithUnit(x: FloatWithUnit(value: 0, unit: .fraction),
                                 y: FloatWithUnit(value: 0.5, unit: .fraction))
        }
    }
}

extension ScanViewController : CustomViewDelegate{
    func didGetError(customView: CustomView) {
        Utility.showPopup(Title: App_Title, Message: "Not a valid Product".localized(), InViewC: self)
    }
    
    func didTappedOnProceed(trackedBarcode: TrackedBarcode) {
        guard let scannedCode = trackedBarcode.barcode.data?.trimmingCharacters(in: .whitespacesAndNewlines), !scannedCode.isEmpty else {
            Utility.showPopup(Title: App_Title, Message: "Scanned Code is not valid. Please try again later.".localized(), InViewC: self)
            return
        }
        
        var msg = ""
        if self.isReturnShipmentSearch{
            msg = "Do you want to proceed with this Return?".localized() + "\n\(scannedCode)"
        }else{
            msg = "Do you want to proceed with this Code?".localized() + "\n\(scannedCode)"
        }
        
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            if(self.isReturnShipmentSearch){
                self.delegate?.didScanCodeForReturnShipmentSearch?(codeDetails: ["scannedCode" : scannedCode])
            }else{
                self.delegate?.didScanCodeForReceive?(codeDetails: ["scannedCode" : scannedCode])
            }
        })
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    func didTappedOnSummaryView(customView: CustomView) {
        for identifier in self.overlaysCustom.keys {
            if let overlayTemp = overlaysCustom[identifier]{
                if identifier == customView.trackedBarcode.identifier {
                    overlayTemp.codeContainer.isSelected.toggle()
                }else{
                    overlayTemp.codeContainer.isSelected = false
                }
                overlayTemp.detailsContainerView.isHidden = !overlayTemp.codeContainer.isSelected
                overlayTemp.layoutIfNeeded()
                overlayTemp.updateConstraintsIfNeeded()
                overlayTemp.sizeToFit()
                if overlayTemp.codeContainer.isSelected {
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + overlayTemp.detailsContainerView.frame.size.height + 21
                    overlayTemp.superview?.bringSubviewToFront(overlayTemp)
                }else{
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                }
            }
        }
    }
}
//,,,sb11-2
/*
extension ScanViewController : CustomViewForLookWithFilterDelegate {
    func didGetError(customViewForLookWithFilter: CustomViewForLookWithFilter) {
        Utility.showPopup(Title: App_Title, Message: "Not a valid Product".localized(), InViewC: self)
    }
    
    func didTappedOnProceedForLookWithFilter(trackedBarcode: TrackedBarcode) {
        guard let scannedCode = trackedBarcode.barcode.data?.trimmingCharacters(in: .whitespacesAndNewlines), !scannedCode.isEmpty else {
            Utility.showPopup(Title: App_Title, Message: "Scanned Code is not valid. Please try again later.".localized(), InViewC: self)
            return
        }
        
        var msg = ""
        if self.isReturnShipmentSearch{
            msg = "Do you want to proceed with this Return?".localized() + "\n\(scannedCode)"
        }else{
            msg = "Do you want to proceed with this Code?".localized() + "\n\(scannedCode)"
        }
        
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            if(self.isReturnShipmentSearch){
                self.delegate?.didScanCodeForReturnShipmentSearch?(codeDetails: ["scannedCode" : scannedCode])
            }else{
                self.delegate?.didScanCodeForReceive?(codeDetails: ["scannedCode" : scannedCode])
            }
        })
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
    
    func didTappedOnSummaryView(customViewForLookWithFilter: CustomViewForLookWithFilter) {
        for identifier in self.overlaysCustomForLookWithFilter.keys {
            if let overlayTemp = overlaysCustomForLookWithFilter[identifier]{
                if identifier == customViewForLookWithFilter.trackedBarcode.identifier {
                    overlayTemp.codeContainer.isSelected.toggle()
                }else{
                    overlayTemp.codeContainer.isSelected = false
                }
                overlayTemp.detailsContainerView.isHidden = !overlayTemp.codeContainer.isSelected
                overlayTemp.layoutIfNeeded()
                overlayTemp.updateConstraintsIfNeeded()
                overlayTemp.sizeToFit()
                if overlayTemp.codeContainer.isSelected {
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + overlayTemp.detailsContainerView.frame.size.height + 21
                    overlayTemp.superview?.bringSubviewToFront(overlayTemp)
                }else{
                    overlayTemp.frame.size.height = overlayTemp.codeContainerView.frame.size.height + 21
                }
            }
        }
    }
}
 */
//,,,sb11-2

extension ScanViewController : CustomViewOverlayForEndPointUrlDelegate{
    func didTappedOnProceedCustomOverlay(trackedBarcode: TrackedBarcode) {
        guard let scannedUrl = URL(string: trackedBarcode.barcode.data!) else {
            Utility.showPopup(Title: App_Title, Message: "Not a valid url. Please try again.".localized(), InViewC: self)
            return
        }
        let msg = "Do you want to proceed with this url?".localized() + "\n\n\(scannedUrl.absoluteString)"
        
        let confirmAlert = UIAlertController(title: "Confirmation".localized(), message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .default, handler: { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didScanCompleteForEndPointURL!(urlString: scannedUrl.absoluteString)
        })
        confirmAlert.addAction(action)
        confirmAlert.addAction(okAction)
        self.navigationController?.present(confirmAlert, animated: true, completion: nil)
    }
}
//MARK : TableviewDataSource & Delegate
extension ScanViewController : UITableViewDataSource,UITableViewDelegate{
     func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrLotProductList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell",for:indexPath) as! ProductCell
        cell.selectionStyle = .none
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
        (cell.btnPlus.tag, cell.btnMinus.tag ,cell.btnDelete.tag,cell.btnCount.tag ,cell.bigPlusButton.tag) = (indexPath.row,indexPath.row,indexPath.row,indexPath.row,indexPath.row)
        let item = arrLotProductList?[indexPath.row]
        cell.lblProductName.text = item?.productName
        cell.btnCount.setTitle("\(item?.productCount ?? 0)", for: .normal)
        return cell
    }
}
