//
//  MWReceiving.swift
//  TTRx2 AI Edge Scanner
//
//  Created by aqbsol on 14/10/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sbm2

import UIKit
import CoreData

public class MWReceiving {
    @nonobjc public class func removeAllMW_ReceivingEntityDataFromDB() {
        MWReceivingLineItem.removeAllMW_ReceivingLineItemFromDB()
        MWReceivingManualLotOrScanSerial.removeAllMW_ReceivingManualLotOrScanSerialFromDB()
        MWReceivingScanProduct.removeAllMW_ReceivingScanProductFromDB()
    }
}

public class MWReceivingLineItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingLineItem> {
        return NSFetchRequest<MW_ReceivingLineItem>(entityName: "MW_ReceivingLineItem")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_ReceivingLineItem> {
        let request: NSFetchRequest<MW_ReceivingLineItem> = MW_ReceivingLineItem.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_ReceivingLineItem> {
        let request: NSFetchRequest<MW_ReceivingLineItem> = MW_ReceivingLineItem.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWReceivingLineItem.fetchAutoIncrementId())
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
    
    @nonobjc public class func removeAllMW_ReceivingLineItemFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_ReceivingLineItem.fetchRequest())
            print("Existing MW_ReceivingLineItem Fetched for Removed")
            
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


public class MWReceivingManualLotOrScanSerial: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingManualLotOrScanSerial> {
        return NSFetchRequest<MW_ReceivingManualLotOrScanSerial>(entityName: "MW_ReceivingManualLotOrScanSerial")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_ReceivingManualLotOrScanSerial> {
        let request: NSFetchRequest<MW_ReceivingManualLotOrScanSerial> = MW_ReceivingManualLotOrScanSerial.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_ReceivingManualLotOrScanSerial> {
        let request: NSFetchRequest<MW_ReceivingManualLotOrScanSerial> = MW_ReceivingManualLotOrScanSerial.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWReceivingManualLotOrScanSerial.fetchAutoIncrementId())
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
    
    @nonobjc public class func removeAllMW_ReceivingManualLotOrScanSerialFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_ReceivingManualLotOrScanSerial.fetchRequest())
            print("Existing MW_ReceivingManualLotOrScanSerial Fetched for Removed")
            
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


public class MWReceivingScanProduct: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingScanProduct> {
        return NSFetchRequest<MW_ReceivingScanProduct>(entityName: "MW_ReceivingScanProduct")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MW_ReceivingScanProduct> {
        let request: NSFetchRequest<MW_ReceivingScanProduct> = MW_ReceivingScanProduct.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MW_ReceivingScanProduct> {
        let request: NSFetchRequest<MW_ReceivingScanProduct> = MW_ReceivingScanProduct.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
    @nonobjc public class func getAutoIncrementId() -> Int16 {
        var autoId:Int16 = 1
        do{
            let serial_obj = try PersistenceService.context.fetch(MWReceivingScanProduct.fetchAutoIncrementId())
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
    
    @nonobjc public class func removeAllMW_ReceivingScanProductFromDB() {
        do{
            let objArray = try PersistenceService.context.fetch(MW_ReceivingScanProduct.fetchRequest())
            print("Existing MW_ReceivingScanProduct Fetched for Removed")
            
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
