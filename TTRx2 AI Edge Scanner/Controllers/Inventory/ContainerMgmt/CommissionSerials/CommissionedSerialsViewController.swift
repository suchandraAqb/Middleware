//
//  CommissionedSerialsViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 25/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class CommissionedSerialsViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet weak var serialListTable: UITableView!
    @IBOutlet var downloadButton:UIButton!

    var serialList = Array<String>()
    var serialsFormat: String = ""
    var serialsUuid: String = ""
    var csvName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        
        let btn = UIButton()
        btn.tag = 2
        typeButtonPressed(btn)

        // Do any additional setup after loading the view.
    }
    
    
    

    // MARK: - Action
    @IBAction func typeButtonPressed(_ sender: UIButton) {
    
       if sender.isSelected {
           return
       }
       for btn in typeButtons {
           
           if btn.tag == sender.tag {
               btn.isSelected = true
           }else{
               btn.isSelected = false
           }
           
           if btn.isSelected && btn.tag == 1{
               serialsFormat = "GS1_URI"
               csvName = "Commissioned_\(serialsUuid)_GS1_Serials_URI"
           }else if btn.isSelected && btn.tag == 2{
               serialsFormat = "GS1_BARCODE"
               csvName = "Commissioned_\(serialsUuid)_GS1_Barcodes"
           }else if btn.isSelected && btn.tag == 3{
               serialsFormat = "SIMPLE_SERIAL"
               csvName = "Commissioned_\(serialsUuid)_Serials"
           }
       }
       
       generatedContainerSerials()
       
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        if serialList.count > 0 {
            var csvString = "\("Commissioned Serials")\n"
            for serial in serialList {
                csvString = csvString.appending("\(String(describing: serial))\n")
            }
            
            let fileManager = FileManager.default
            do {
                let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
                let fileURL = path.appendingPathComponent(csvName)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("error creating file")
            }

            let pathUrl = Utility.getDocumentsDirectory().appendingPathComponent(csvName)
            

            if FileManager.default.fileExists(atPath: pathUrl.path){
                //let documento = NSData(contentsOfFile: pathUrl.path)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pathUrl], applicationActivities: nil)
                
                if (UI_USER_INTERFACE_IDIOM() == .pad){
                    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                    activityViewController.popoverPresentationController?.sourceView=self.downloadButton

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
            Utility.showPopup(Title: App_Title, Message: "Please try again later.".localized(), InViewC: self)
        }
    }
    
   
    
    // MARK: -End
    
    //MARK: - Call API
    
    
    
    func generatedContainerSerials() {
        let url = "/\(serialsUuid)/serials?serials_format=\(serialsFormat)&_=\(Date().currentTimeMillis())"
        self.showSpinner(onView: self.view)
        Utility.GETServiceCall(type: "GetContainerSerials", serviceParam: {}, parentViewC: self, willShowLoader: false,viewController: self, appendStr: url,isOpt: false) { (responseData:Any?, isDone:Bool?, message:String?) in
            DispatchQueue.main.async{
                self.removeSpinner()
                if isDone! {
                    if let responseDict = responseData as? [String: Any] {
                        if let serialListTemp = responseDict["serials"] as? [String] {
                            self.serialList = serialListTemp
                            self.serialListTable.reloadData()
                        }
                    }
                }else{

                    if responseData != nil{
                        let responseDict: NSDictionary = responseData as! NSDictionary
                        let errorMsg = responseDict["message"] as! String
                        Utility.showPopup(Title: App_Title, Message: errorMsg , InViewC: self)

                    }else{
                        Utility.showPopup(Title: App_Title, Message: message ?? "", InViewC: self)
                    }
                }
            }
        }

    }
    
    //MARK: End
    
    //MARK: - Tableview Delegate and Datasource

    
    func numberOfSections(in tableView: UITableView) -> Int{
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serialList.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventorySerialListTableViewCell") as! InventorySerialListTableViewCell
        let name =  serialList[indexPath.row]
        cell.serialLabel.text = name
        //cell.deleteButton.tag = indexPath.row
        return cell
    }
    //MARK: - End
    

}
