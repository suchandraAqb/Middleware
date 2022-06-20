//
//  SerialRequestDetailsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 07/10/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

enum SerialFormat:String {
    case SimpleSerial = "SERIALS_ONLY"
    case GS1Serial = "GS1_SERIALS"
    case GS1Barcode = "GS1_BARCODE"
}

class SerialRequestDetailsViewController: BaseViewController {
    
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var requestedLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    @IBOutlet weak var downloadSerialHedaerView: UIView!
    @IBOutlet weak var simpleSerialsView: UIView!
    
    @IBOutlet weak var gs1DownloadButton:UIButton!
    @IBOutlet weak var gs1BarcodeDownloadButton:UIButton!
    @IBOutlet weak var simpleSerialDownloadButton:UIButton!

    var product_uuid = ""
    var lot_uuid = ""
    var request_uuid = ""
    var serialDetails = [String:Any]()
    var serialList = [Any]()
    var button = UIButton()
   
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        statusButton.isHidden = true
        detailsContainer.setRoundCorner(cornerRadious: 20)
        statusButton.setRoundCorner(cornerRadious: statusButton.frame.size.height/2.0)
        downloadSerialHedaerView.roundTopCorners(cornerRadious: 20)
        simpleSerialsView.roundBottomCorners(cornerRadious: 20)
        getSerialRequestDetails()
        
    }
    //MARK: - End
    
    //MARK: - Custom Methods
    func populateDetails(){
        
        if !self.serialDetails.isEmpty{
            
            var dataStr = ""
            if let txt = serialDetails["quantity"] as? Int{
                dataStr = "\(txt)"
            }
            quantityLabel.text = dataStr
            
            
            dataStr = ""
            if let txt = serialDetails["requested_by_name"] as? String{
                dataStr = txt
            }
            createdByLabel.text = dataStr
            
            
            dataStr = ""
            // let outputDateFormat = (defaults.value(forKey: "dateformat") ?? "y-m-d") as! String
            
            if let date = serialDetails["created_on"] as? String{
                if let formattedDate:String = Utility.getDateFromString(sourceformat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "MM-dd-yyyy \(stdTimeFormat)", dateStr: date){
                    dataStr = formattedDate
                }
            }
            requestedLabel.text = dataStr
            
            
            if let status = serialDetails["is_completed"] as? Bool,status{
                statusButton.setTitle("Completed".localized(), for: .normal)
                statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "65dfa7")
                
            }else{
                statusButton.setTitle("In Progress".localized(), for: .normal)
                statusButton.backgroundColor = Utility.hexStringToUIColor(hex: "00AFEF")
                
            }
            
            statusButton.isHidden = false 
            
            
        }
        
    }
    func getSerialRequestDetails(){
        
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials/\(request_uuid)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    
                    
                    if let responseDict = responseData as? [String:Any]{
                        self.serialDetails = responseDict
                        self.populateDetails()
                    }
                    
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                        
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                    
                    
                }
                
            }
        }
    }
    
    func getSerialRequestSerials(format:String){
        
        let appendStr = "\(product_uuid)/manufacturer/lot/\(lot_uuid)/serials/\(request_uuid)/serials?serials_format=\(format)"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "AddUpdateManufacturerLot", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self,appendStr: appendStr) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseArr = responseData as? Array<Any> {
                        self.serialList = responseArr
                        self.shareCSV()
                        
                    }
                    
                }else{
                    
                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        if let errorMsg = responseDict["message"] as? String , let details = responseDict["details"] as? String {
                            Utility.showPopup(Title: errorMsg, Message: details , InViewC: self)
                        }else  if let errorMsg = responseDict["message"] as? String {
                            Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)
                        }else{
                            Utility.showPopup(Title: App_Title, Message: "Something went wrong..".localized() , InViewC: self)
                        }
                        
                        
                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                    
                    
                }
                
            }
        }
    }
    
    func shareCSV(){
        if serialList.count > 0 {
                   var csvString = "\("Scanned Raw Serials")\n"
                   for serial in serialList {
                       csvString = csvString.appending("\(String(describing: serial))\n")
                   }
                   
                   let fileManager = FileManager.default
                   do {
                       let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
                       let fileURL = path.appendingPathComponent("seriallist.csv")
                       if FileManager.default.fileExists(atPath: fileURL.path) {
                           try? FileManager.default.removeItem(at: fileURL)
                       }
                       try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                   } catch {
                       print("error creating file")
                   }
                   
                   let pathUrl = Utility.getDocumentsDirectory().appendingPathComponent("seriallist.csv")
                   
                   if FileManager.default.fileExists(atPath: pathUrl.path){
                       //let documento = NSData(contentsOfFile: pathUrl.path)
                       let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pathUrl], applicationActivities: nil)
                       
                       if (UI_USER_INTERFACE_IDIOM() == .pad){
                           activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
                           activityViewController.popoverPresentationController?.sourceView=self.button

                       }else{
                           activityViewController.popoverPresentationController?.sourceView=self.view

                       }
                       self.present(activityViewController, animated: true, completion: nil)
                      
                       
                       activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                           if completed {
                               activityViewController.dismiss(animated: true, completion: nil)
                           }
                       }
                   }
               }else{
                   //Utility.showPopup(Title: App_Title, Message: "Please scan some serials and try again later.".localized(), InViewC: self)
               }
    }
    
    //MARK: - End
    //MARK: - IBAction
    
    @IBAction func viewButtonPressed(_ sender: UIButton) {
        
        var format = ""
        
        if sender.tag == 1 {
            format = SerialFormat.GS1Serial.rawValue
        }else if sender.tag == 2 {
            format = SerialFormat.GS1Barcode.rawValue
        }else if sender.tag == 3 {
            format = SerialFormat.SimpleSerial.rawValue
        }
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SerialRequestSerialsView") as! SerialRequestSerialsViewController
        controller.lot_uuid = lot_uuid
        controller.product_uuid = product_uuid
        controller.request_uuid = request_uuid
        controller.format = format
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        
        var format = ""
        
        if sender.tag == 1 {
            format = SerialFormat.GS1Serial.rawValue
            button = gs1DownloadButton
        }else if sender.tag == 2 {
            format = SerialFormat.GS1Barcode.rawValue
            button = gs1BarcodeDownloadButton
        }else if sender.tag == 3 {
            format = SerialFormat.SimpleSerial.rawValue
            button = simpleSerialDownloadButton 
        }
        
        getSerialRequestSerials(format: format)
    }
    
    
    
    //MARK: - End
    
    
}
