//
//  PPShipmentDownloadViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 12/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import WebKit

class PPShipmentDownloadViewController: BaseViewController {
    
    @IBOutlet weak var mainWebView: WKWebView!
    @IBOutlet weak var downloadButton:UIButton!
    var type = ""
    var shipmentId = ""
    var serviceUrl = ""
    var downloadPDFPath:URL?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainWebView.navigationDelegate = self
        let appendStr = "\(type.capitalized)/\(shipmentId)/download_pdf"
        serviceUrl = Utility.getURL(type: "ConfirmShipment", isOpt: false)
        serviceUrl = serviceUrl + appendStr
        
        
        var urlRequest = URLRequest(url: URL(string: serviceUrl)!)
        let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
        if !authToken.isEmpty{
            urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        mainWebView.load(urlRequest)
        
        
    }
    //MARK: End
    
    //MARK: IBAction
    @IBAction func crossButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        self.showSpinner(onView: self.view)
        
        if self.downloadPDFPath != nil {
           openSharePicker()
        }else{
            self.downloadPDF { (isDone, path) in
                
                if isDone!{
                    self.downloadPDFPath = path
                    self.openSharePicker()
                }else{
                    DispatchQueue.main.async {
                        self.removeSpinner()
                    }
                }
                
            }
        }
        
    }
    //MARK: End
    
    //MARK: Custom Method
    
    func openSharePicker(){
        
        DispatchQueue.global(qos: .default).async {
            let documento = NSData(contentsOf: self.downloadPDFPath!)
            DispatchQueue.main.async {
                self.removeSpinner()
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
                
                if (UI_USER_INTERFACE_IDIOM() == .pad){
                    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
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
        }
        
    }
    
    //MARK: End
    
    
    
 }



extension PPShipmentDownloadViewController: WKNavigationDelegate {
    
    
    func downloadPDF(ServiceCompletion:@escaping (_ isDone:Bool?,_ localPath:URL?) -> Void){
        
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
        
            var urlRequest = URLRequest(url: URL(string: serviceUrl)!)
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            if !authToken.isEmpty{
                urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
            }
            
            let manager = AFHTTPSessionManager()
            let downloadTask = manager.downloadTask(with: urlRequest, progress: { (progress) in
                
            }, destination: { (url, response) -> URL in
                
                let url = Utility.getDocumentsDirectory()
                return url.appendingPathComponent(response.suggestedFilename ?? "")
                
            }) { (response, url, error) in
                
                if error == nil {
                    ServiceCompletion(true,url)
                }else{
                    ServiceCompletion(false,nil)
                }
                
            }
            
            downloadTask.resume()
            
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async{
            self.removeSpinner()
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Utility.showPopup(Title: App_Title, Message: error.localizedDescription , InViewC: self)
        self.crossButtonPressed(UIButton())
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showSpinner(onView: self.view)
    }
    
}
