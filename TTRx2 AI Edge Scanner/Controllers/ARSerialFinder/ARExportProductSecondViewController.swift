//
//  ARExportProductSecondViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Admin on 03/09/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class ARExportProductSecondViewController: BaseViewController, SingleSelectDropdownDelegate {//,,,sb10
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet var productName: UILabel!
    
    @IBOutlet var summaryCountButton:UIButton!

    @IBOutlet weak var listOfSerialsFoundButton: UIButton!//,,,sb3
    
    @IBOutlet var includeproductInfo:UIButton!

    @IBOutlet var simpleFormat: UIButton!
    
    @IBOutlet var gs1UrnFormat: UIButton!
    
    @IBOutlet var rawBarcode: UIButton!

    @IBOutlet var exportButton: UIButton!
        
    //,,,sb10
    @IBOutlet weak var fileTypeView: UIView!
    @IBOutlet weak var fileTypeLabel: UILabel!
    @IBOutlet weak var fileTypeButton: UIButton!
    //,,,sb10
    
    var finalArray : NSArray!
    var productDetailsArr = Array<Dictionary<String,Any>>()
    var requestDict = [String:Any]()//,,,sb3
    var productNameString : NSString!
    var fileTypeList: [[String: Any]] = [] //,,,sb10
    var selectedDetailsDict = [String:Any]()//,,,sb11-10

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        detailsView.layer.cornerRadius = 15.0
        detailsView.clipsToBounds = true
        exportButton.setRoundCorner(cornerRadious: 10)
                
        if productDetailsArr.count>0 {
            productName.text = productNameString as String?
        }
        
        //,,,sb10
        fileTypeView.setRoundCorner(cornerRadious: 10)

        fileTypeList = [["name" : "PDF" , "value" : "PDF"],["name" : "CSV" , "value" : "CSV"]]
        let dataDict:[String:Any] = fileTypeList[0]
        if let name = dataDict["name"] as? String {
            let value = dataDict["value"] as? String
            fileTypeLabel.text = name
            fileTypeLabel.accessibilityHint = value
            fileTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
        }
        //,,,sb10
        
        self.serialNumberFormatCheckuncheck(simpleFormat)//,,,sb3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //MARK:- End
    
    //MARK: - IBAction
    @IBAction func pickerButtonPressed(_ sender: UIButton) {
        doneTyping()
        
        if sender.tag == 1 {
            let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
            let controller = storyboard.instantiateViewController(withIdentifier: "SingleSelectDropdownView") as! SingleSelectDropdownViewController
            controller.isDataWithDict = false
            controller.nameKeyName = "name"
            controller.listItems = fileTypeList
            controller.type = "File Type".localized()//,,,sb10
            controller.delegate = self
            controller.sender = sender
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
    }//,,,sb10
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        self.prepareExportData()
    }
    @IBAction func checkUncheckButtonPreseed(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        
        //,,,sb3
        if sender == includeproductInfo || sender == rawBarcode {
            if sender.isSelected {
                listOfSerialsFoundButton.isSelected = sender.isSelected
            }
        }
        else if sender == listOfSerialsFoundButton {
            listOfSerialsFoundButton.isSelected = true
        }
        //,,,sb3
    }
    
    @IBAction func serialNumberFormatCheckuncheck(_ sender: UIButton){
        if sender == simpleFormat {
            simpleFormat.isSelected = true
            gs1UrnFormat.isSelected = false
        }else{
            simpleFormat.isSelected = false
            gs1UrnFormat.isSelected = true
        }
        
        listOfSerialsFoundButton.isSelected = sender.isSelected//,,,sb3
    }
    //MARK:- End
    
    
    //MARK: - Privete Method
    func prepareExportData() {
        //,,,sb3
        /*
        optionDict["summery_count_product"] = summaryCountButton.isSelected
        optionDict["include_product_info"] = includeproductInfo.isSelected
        optionDict["raw_barcode"] = rawBarcode.isSelected
        
        if simpleFormat.isSelected{
            optionDict["serial_format"] = "normal"
        }else{
            optionDict["serial_format"] = "gs1"
        }
        requestDict.setValue(optionDict, forKey: "options")
        requestDict.setValue(productDetailsArr, forKey: "product_details")
        requestDict.setValue("LOT", forKey: "export_data_of")
        requestDict.setValue({}, forKey: "filter_details")
        
         print(requestDict)
        */
        
        var optionDict = [String:Any]()
        optionDict["summery_count_lots"] = summaryCountButton.isSelected
        optionDict["list_of_serial_found"] = listOfSerialsFoundButton.isSelected
        optionDict["include_product_info"] = includeproductInfo.isSelected
        if simpleFormat.isSelected{
            optionDict["serial_format"] = "simple"
        }else{
            optionDict["serial_format"] = "gs1"
        }
        optionDict["raw_barcode"] = rawBarcode.isSelected
        
        optionDict["summery_count_product"] = 0
//        optionDict["include_count_per_lot"] = includeCountPerLot.isSelected
        
        //,,,sb11-10
        var filter_detailsDict = [String:Any]()
        if selectedDetailsDict.isEmpty {
            filter_detailsDict["is_look_with_filter"] = false
        }
        else {
            filter_detailsDict["is_look_with_filter"] = true
            
            var filterName = "Look with filter"
            if let filter_name = selectedDetailsDict["filter_name"] as? String,!filter_name.isEmpty{
                filterName = filter_name
            }
            filter_detailsDict["filter_name"] = filterName
            
            var filterDescription = ""
            if let description = selectedDetailsDict["description"] as? String,!description.isEmpty{
                filterDescription = description
            }
            filter_detailsDict["filter_description"] = filterDescription
        }
        //,,,sb11-10
        
        let productDetailsArrJsonString = Utility.json(from: productDetailsArr)
        requestDict["data"] = productDetailsArrJsonString
        
        let optionDictJsonString = Utility.json(from: optionDict)
        requestDict["options"] = optionDictJsonString
        
        //,,,sb11-10
//        requestDict["filter_details"] = filter_detailsDict
        let filter_detailsDictJsonString = Utility.json(from: filter_detailsDict)
        requestDict["filter_details"] = filter_detailsDictJsonString
        //,,,sb11-10
        
        requestDict["type"] = "PRODUCT"
        requestDict["file_type"] = fileTypeLabel.accessibilityHint//,,,sb10

//        print ("requestDict....second",requestDict)
        //,,,sb3
        
        self.exportDataApiCall()
    }
    //MARK:- End
    
    //MARK: - Webservice Call
    func exportDataApiCall() {
            let appendStr = ""
        DispatchQueue.main.async{
            self.showSpinner(onView: self.view)
        }
        Utility.POSTServiceCall(type: "SerialFinderExport", serviceParam:requestDict as NSDictionary, parentViewC: self, willShowLoader: false,viewController: self, appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
                DispatchQueue.main.async{
                    self.removeSpinner()
                    if isDone! {
                        let msg = "Data exported successfully".localized()

                        Utility.showPopupWithAction(Title: Success_Title, Message: msg, InViewC: self, action:{
                            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ARExportProductDownloadableFilesController") as! ARExportProductDownloadableFilesController
                            self.navigationController?.pushViewController(controller, animated: true)
                        })//,,,sb4
                    }else {
                        let dict = responseData as! NSDictionary
                        let error = dict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message:error , InViewC: self)
                    }
                }
        }
    }//,,,sb3
    //MARK:- End
    
    //MARK: - SingleSelectDropdownDelegate
    func selecteditem(data: NSDictionary,sender:UIButton?) {
        if sender != nil {
            if sender == fileTypeButton {
                if let name = data["name"] as? String {
                    let value = data["value"] as? String
                    fileTypeLabel.text = name
                    fileTypeLabel.accessibilityHint = value
                    fileTypeLabel.textColor = Utility.hexStringToUIColor(hex: "072144")
                }
            }
        }
    }//,,,sb10
    //MARK: - End
}
