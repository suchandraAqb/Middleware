//
//  InventoryHomeViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 17/08/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class InventoryHomeViewController: BaseViewController {
    
    @IBOutlet var roundedView:[UIView]!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sectionView.roundTopCorners(cornerRadious: 40)
        for view in roundedView{
            view.setRoundCorner(cornerRadious: 10)
        }
    }
    //MARK:- End
    
    //MARK:- IBAction
    
    @IBAction func ItemsInInventoryButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ItemsInInventoryListView") as! ItemsInInventoryListViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    @IBAction func InventoryPerLotButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InventoryListView") as! InventoryListViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    @IBAction func ICButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SFSerialScanView") as! SFSerialScanViewController
        controller.delegate = self
        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func CMButtonPressed(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ContainerMgmtHomeView") as! ContainerMgmtHomeViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    //MARK:- End
    
}

extension InventoryHomeViewController:SFSerialScanViewDelegate{
    func didClickOnCamera() {
        DispatchQueue.main.async{
            if(defaults.bool(forKey: "IsMultiScan")){
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
                controller.isForInventory = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "SingleScanViewController") as! SingleScanViewController
                controller.isForInventory = true
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension InventoryHomeViewController : ScanViewControllerDelegate{
    
    func didScanCodeForInventoryCount(scannedCode: [String]) {
        DispatchQueue.main.async{
            print("Scanned Barcodes")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "InventorySerialListViewController") as! InventorySerialListViewController
            controller.serialList = scannedCode
            self.navigationController?.pushViewController(controller, animated: true)
         }
    }
}

extension InventoryHomeViewController : SingleScanViewControllerDelegate{
    func didSingleScanCodeForInventoryCount(scannedCode: [String]) {
        DispatchQueue.main.async{
            print("Scanned Barcodes")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "InventorySerialListViewController") as! InventorySerialListViewController
            controller.serialList = scannedCode
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
