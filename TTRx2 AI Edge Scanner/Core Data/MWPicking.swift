//
//  MWPicking.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 14/10/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm4

import UIKit
import CoreData

public class MWPicking {
    @nonobjc public class func removeAllMW_PickingEntityDataFromDB() {
        MWPickingLineItem.removeAllMW_PickingLineItemFromDB()
        MWPickingManualLotOrScanSerial.removeAllMW_PickingManualLotOrScanSerialFromDB()
        MWPickingScanProduct.removeAllMW_PickingScanProductFromDB()
    }
}

public class MWPickingLineItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingLineItem> {
        return NSFetchRequest<MW_PickingLineItem>(entityName: "MW_PickingLineItem")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_PickingLineItem> {
        let request: NSFetchRequest<MW_PickingLineItem> = MW_PickingLineItem.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_PickingLineItem> {
        let request: NSFetchRequest<MW_PickingLineItem> = MW_PickingLineItem.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWPickingLineItem.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)

        }
        return autoId
    }
    
    @nonobjc public class func removeAllMW_PickingLineItemFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_PickingLineItem.fetchRequest())
            print("Existing MW_PickingLineItem Fetched for Removed")
            
            if !objArray.isEmpty {
                for obj in objArray {
                    PersistenceService.context.delete(obj)
                }
                PersistenceService.saveContext()
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
}


public class MWPickingManualLotOrScanSerial: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingManualLotOrScanSerial> {
        return NSFetchRequest<MW_PickingManualLotOrScanSerial>(entityName: "MW_PickingManualLotOrScanSerial")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_PickingManualLotOrScanSerial> {
        let request: NSFetchRequest<MW_PickingManualLotOrScanSerial> = MW_PickingManualLotOrScanSerial.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_PickingManualLotOrScanSerial> {
        let request: NSFetchRequest<MW_PickingManualLotOrScanSerial> = MW_PickingManualLotOrScanSerial.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWPickingManualLotOrScanSerial.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)

        }
        return autoId
    }
    
    @nonobjc public class func removeAllMW_PickingManualLotOrScanSerialFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_PickingManualLotOrScanSerial.fetchRequest())
            print("Existing MW_PickingManualLotOrScanSerial Fetched for Removed")
            
            if !objArray.isEmpty {
                for obj in objArray {
                    PersistenceService.context.delete(obj)
                }
                PersistenceService.saveContext()
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
}


public class MWPickingScanProduct: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingScanProduct> {
        return NSFetchRequest<MW_PickingScanProduct>(entityName: "MW_PickingScanProduct")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_PickingScanProduct> {
        let request: NSFetchRequest<MW_PickingScanProduct> = MW_PickingScanProduct.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_PickingScanProduct> {
        let request: NSFetchRequest<MW_PickingScanProduct> = MW_PickingScanProduct.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWPickingScanProduct.fetchAutoIncrementId())
            if !serial_obj.isEmpty{
                if let obj = serial_obj.first {
                    autoId = obj.id + Int16(1)
                }
            }
        }catch let error{
            print(error.localizedDescription)

        }
        return autoId
    }
    
    @nonobjc public class func removeAllMW_PickingScanProductFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_PickingScanProduct.fetchRequest())
            print("Existing MW_PickingScanProduct Fetched for Removed")
            
            if !objArray.isEmpty {
                for obj in objArray {
                    PersistenceService.context.delete(obj)
                }
                PersistenceService.saveContext()
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
