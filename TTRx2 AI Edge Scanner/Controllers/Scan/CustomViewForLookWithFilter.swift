//
//  CustomViewForLookWithFilter.swift
//  MatrixScanBubblesSample
//
//  Created by Saugata Bhandari on 16/04/20.
//  Copyright © 2020 Scandit. All rights reserved.
//,,,sb11-2

import UIKit
import ScanditBarcodeCapture

@objc protocol CustomViewForLookWithFilterDelegate: class {
    func didGetError(customViewForLookWithFilter : CustomViewForLookWithFilter)
    func didTappedOnSummaryView(customViewForLookWithFilter : CustomViewForLookWithFilter)
    func didTappedOnProceedForLookWithFilter(trackedBarcode:TrackedBarcode)
}

class CustomViewForLookWithFilter: UIView {
    var trackedBarcode:TrackedBarcode!
    @IBOutlet weak var productIcon: UIImageView!
    @IBOutlet weak var codeContainerView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var triangleImageView: UIImageView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var codeContainer: UIButton!

    @IBOutlet weak var scannedCodeLabel: UILabel!
 
    @IBOutlet weak var valueName1: UILabel!
    @IBOutlet weak var valueName2: UILabel!
    @IBOutlet weak var valueName3: UILabel!


    
    weak var delegate: CustomViewForLookWithFilterDelegate?

    
    override init(frame: CGRect) {
//        super.init(frame: CGRect(x: 0, y: 0, width: 260, height: 60))
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))//,,,sb11-2
        self.loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromNib()
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.codeContainerView.setNeedsDisplay()
        self.detailsContainerView.setNeedsDisplay()
    }
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        
        self.addSubview(view)
        self.detailsContainerView.isHidden = true

        
//        // Start using auto layout
//        view.translatesAutoresizingMaskIntoConstraints = false
//        let constraints = [
//            view.topAnchor.constraint(equalTo:topAnchor),
//            view.leftAnchor.constraint(equalTo:leftAnchor),
//            view.bottomAnchor.constraint(equalTo:bottomAnchor),
//            view.rightAnchor.constraint(equalTo:rightAnchor)
//        ]
//        NSLayoutConstraint.activate(constraints)
//        self.detailsContainerView.isHidden = true
//        self.layoutIfNeeded()
    }
    func prepareView(barCode : TrackedBarcode) -> CustomViewForLookWithFilter{
        self.trackedBarcode = barCode
        let details = barCode.barcode.decodedInfo
        print("================================\(details as NSDictionary)")
        
        //,,,sb11-16
        self.scannedCodeLabel.text = ""
        self.valueName1.text = ""
        self.valueName2.text = ""
        self.valueName3.text = ""
        //,,,sb11-16
        
      
            if details.count > 0 {
                var containerSerialNumber = ""
                var productName = ""
                var productGtin14 = ""
                var serialNumber = ""
                var lotNumber = ""
            if(details.keys.contains("00")){
                if let cSerial = details["00"]?["value"] as? String{
                    containerSerialNumber = cSerial
                }else if let cSerial = details["00"]?["value"] as? NSNumber{
                    containerSerialNumber = "\(cSerial)"
                }
                self.scannedCodeLabel.text = "Container Sl.No : \(containerSerialNumber)"
                self.productIcon.image = UIImage(named: "container_sm")
                self.valueName1.text = ""
                self.valueName3.text = ""
            }else{
                self.productIcon.image = UIImage(named: "overlay_product")
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
                if let gtin14 = details["01"]?["value"] as? String{
                    productGtin14 = gtin14
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
            }
            if containerSerialNumber.isEmpty{
                if(!productName.isEmpty){
                    self.scannedCodeLabel.text = productName
                    if(!serialNumber.isEmpty){
                        self.valueName1.text = "Sl.No. - \(serialNumber)"
                    }else{
                       self.valueName1.text = ""
                    }
                }else{
                    if(!serialNumber.isEmpty){
                        self.scannedCodeLabel.text = "Product Sl.No : \(serialNumber)"
                    }else{
                       self.scannedCodeLabel.text = "Product Serial Missing"
                    }
                    self.valueName1.text = ""
                }
                if(!productGtin14.isEmpty){
                    self.valueName2.text = "GTIN. - \(productGtin14)"
                }else{
                    self.valueName2.text = ""
                }
                
                if(!lotNumber.isEmpty){
                    self.valueName3.text = "Batch/Lot No. - \(lotNumber)"
                }else{
                    self.valueName3.text = ""
                }
                
                
            }
        }else{
            self.scannedCodeLabel.text = "Code is not valid."
        }
      
        return self
    }
//    func loadView(barCode : TrackedBarcode) -> CustomViewForLookWithFilter{
//        let customInfoWindow = Bundle.main.loadNibNamed("CustomViewForLookWithFilter", owner: self, options: nil)?[0] as! CustomViewForLookWithFilter
//        customInfoWindow.autoresizingMask = [
//         UIView.AutoresizingMask.flexibleHeight
//        ]
//        customInfoWindow.detailsContainerView.isHidden = true
//        customInfoWindow.trackedBarcode = barCode
//        return customInfoWindow
//    }
     override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    /*
    @IBAction func proceed(_ sender: UIButton) {
       self.delegate?.didTappedOnProceedForLookWithFilter(trackedBarcode: trackedBarcode)
    }
    
    @IBAction func press(_ sender: UIButton) {
        let details = self.trackedBarcode.barcode.decodedInfo
        if details.count > 0 {
//            if details["00"] != nil {
//                self.valueName1.text = details["00"]!["value"] as? String
//            }else{
//                if details["21"] != nil{
//                    self.valueName1.text = details["21"]!["value"] as? String
//
//                }
//                if details["01"] != nil {
//                    self.valueName2.text = details["01"]!["value"] as? String
//
//                }
//                if details["10"] != nil {
//                    self.valueName3.text = details["10"]!["value"] as? String
//                }
//            }
            self.delegate?.didTappedOnSummaryView(customViewForLookWithFilter: self)

        }else{
            self.delegate?.didGetError(customViewForLookWithFilter: self)
        }
    }
     */
}
    
