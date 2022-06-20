//
//  CustomOverlayForEndPointUrl.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 11/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import ScanditBarcodeCapture

@objc protocol CustomViewOverlayForEndPointUrlDelegate: class {
    func didTappedOnProceedCustomOverlay(trackedBarcode:TrackedBarcode)
}
class CustomViewOverlayForEndPointUrl: UIView {
    var trackedBarcode:TrackedBarcode!
    @IBOutlet weak var scannedCodeLabel: UILabel!
    @IBOutlet weak var codeContainer: UIButton!
    
    weak var delegate: CustomViewOverlayForEndPointUrlDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView(barCode : TrackedBarcode) -> CustomViewOverlayForEndPointUrl{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomViewOverlayForEndPointUrl", owner: self, options: nil)?.first as! CustomViewOverlayForEndPointUrl
        customInfoWindow.trackedBarcode = barCode
        customInfoWindow.scannedCodeLabel.text = barCode.barcode.data
        return customInfoWindow
    }
     
    @IBAction func proceed(_ sender: UIButton) {
       self.delegate?.didTappedOnProceedCustomOverlay(trackedBarcode: trackedBarcode)
    }
}
