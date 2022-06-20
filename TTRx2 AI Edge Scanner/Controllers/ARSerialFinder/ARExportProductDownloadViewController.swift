//
//  ARExportProductDownloadViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Nova on 18/01/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb3

import UIKit
import WebKit

class ARExportProductDownloadViewController: BaseViewController {
    @IBOutlet weak var mainWebView: WKWebView!
    @IBOutlet weak var headerLabel: UILabel!//,,,sb10
    @IBOutlet weak var shareButton: UIButton!//,,,sb7
    
    var downloadable_files_uuid = ""
    var file_type = "" //,,,sb10

    var serviceUrl = ""
    var downloadPDFPath:URL?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainWebView.navigationDelegate = self
        headerLabel.text = file_type
//        let appendStr = "/\(downloadable_files_uuid)/download_report"
        let appendStr = "/\(downloadable_files_uuid)/download_report?file_type=\(file_type)"//,,,sb10

        serviceUrl = Utility.getURL(type: "downloadable_files", isOpt: false)
        serviceUrl = serviceUrl + appendStr
        
        var urlRequest = URLRequest(url: URL(string: serviceUrl)!)
        let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
        if !authToken.isEmpty {
            urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
        }
//        print ("serviceUrl....",serviceUrl) //,,,sb11-12
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
        }else {
            self.downloadPDF { (isDone, path) in
                if isDone! {
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
    func openSharePicker() {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [self] in
                self.removeSpinner()
                
                //,,,sb10
//                let documento = NSData(contentsOf: self.downloadPDFPath!)
//                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [self.downloadPDFPath!], applicationActivities: nil)
//                print ("self.downloadPDFPath!.....",self.downloadPDFPath!) //,,,sb11-12
                //,,,sb10
                
                //,,,sb7
                if (UI_USER_INTERFACE_IDIOM() == .pad) {
                    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
                    activityViewController.popoverPresentationController?.sourceView = self.shareButton
                }
                else {
                    activityViewController.popoverPresentationController?.sourceView = self.view
                }
                //,,,sb7
                
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

extension ARExportProductDownloadViewController: WKNavigationDelegate {
    
    func downloadPDF(ServiceCompletion:@escaping (_ isDone:Bool?,_ localPath:URL?) -> Void) {
        if AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWiFi || AFNetworkReachabilityManager.shared().networkReachabilityStatus == .reachableViaWWAN {
        
            var urlRequest = URLRequest(url: URL(string: serviceUrl)!)
            let authToken = (defaults.value(forKey: "session_token") ?? "") as! String
            if !authToken.isEmpty {
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
                }else {
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

