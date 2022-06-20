//
//  MISInitialViewController.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 16/12/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit

class MISInitialViewController: BaseViewController {

    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.roundTopCorners(cornerRadious: 40)
        mainView.setRoundCorner(cornerRadious: 20.0)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        removeMISDefaults()
        removeMISFromDB()
    }
    
    //MARK: - Private Method
    func removeMISFromDB(){
        //Item
        do{
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                for obj in serial_obj {
                    PersistenceService.context.delete(obj)
                    PersistenceService.saveContext()
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        //Lot Item
        do{
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataLotItem.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                for obj in serial_obj {
                    PersistenceService.context.delete(obj)
                    PersistenceService.saveContext()
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        //Aggregation
        do{
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let serial_obj = try PersistenceService.context.fetch(MISDataAggregation.fetchRequestWithPredicate(predicate: predicate))
            if !serial_obj.isEmpty{
                for obj in serial_obj {
                    PersistenceService.context.delete(obj)
                    PersistenceService.saveContext()
                }
            }
        }catch let error{
            print(error.localizedDescription)
        }
        
        
    }
    
    func removeMISDefaults(){
        defaults.removeObject(forKey: "MIS_1stStep")
        defaults.removeObject(forKey: "MIS_2ndStep")
        defaults.removeObject(forKey: "MIS_3rdStep")
        defaults.removeObject(forKey: "MIS_4thStep")

        defaults.removeObject(forKey: "MIS_create_new")
        
        defaults.removeObject(forKey: "MIS_selectedLocation")
        defaults.removeObject(forKey: "MIS_selectedSeller")
        defaults.removeObject(forKey: "MIS_broughtBy")
        defaults.removeObject(forKey: "MIS_shipTo")
        defaults.removeObject(forKey: "MIS_soldBy")
        defaults.removeObject(forKey: "MIS_shipFrom")
        defaults.removeObject(forKey: "MIS_PurchaseOrderDetails")
        defaults.removeObject(forKey: "MIS_ShipmentsDetails")
        
        
        defaults.removeObject(forKey: "isShippingTypeCustom")
    }
    //MARK: - End
    
    //MARK: - IBAction
    @IBAction func createButtonPressed(_ sender: UIButton) {
        defaults.set(true, forKey: "MIS_create_new")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaseOrderView") as! MISPurchaseOrderViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func existingButtonPressed(_ sender: UIButton) {
        defaults.set(false, forKey: "MIS_create_new")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MISPurchaceOrderListView") as! MISPurchaceOrderListViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: - End
}
