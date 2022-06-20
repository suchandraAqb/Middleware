//
//  InventorySerialListViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 29/05/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class InventorySerialListViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate {
    var serialList = Array<String>()
    @IBOutlet weak var serialListTable: UITableView!
    @IBOutlet weak var downloadButton:UIButton!
    
    //MARK: - Update Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - End
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        self.serialListTable.reloadData()
    }
    //MARK: - End
    
    
    //MARK: - IBAction
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
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
        } else{
            Utility.showPopup(Title: App_Title, Message: "Please scan some serials and try again later.".localized(), InViewC: self)
        }
    }
    
    @IBAction func printButtonPressed(_ sender: UIButton) {
        if serialList.count > 0 {
            var csvString = "\("Scanned Raw Serials")\n"
            for serial in serialList {
                csvString = csvString.appending("\(String(describing: serial))\n")
            }
            let attrs = [NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 18.0)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let str = NSAttributedString(string: csvString, attributes: attrs)
            let print = UISimpleTextPrintFormatter(attributedText: str)

            let vc = UIActivityViewController(activityItems: [print], applicationActivities: nil)
            if let popoverController = vc.popoverPresentationController{
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            present(vc, animated: true)
        }else{
            Utility.showPopup(Title: App_Title, Message: "Please scan some serials and try again later.".localized(), InViewC: self)
        }
    }
    //MARK: - End
    
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
class InventorySerialListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
