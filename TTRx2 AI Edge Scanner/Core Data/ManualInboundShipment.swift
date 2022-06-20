//
//  ManualInboundShipment.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Prasenjit Ghara on 25/01/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import Foundation
import CoreData

public class MISDataItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MISItem> {
        return NSFetchRequest<MISItem>(entityName: "MISItem")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MISItem> {
        let request: NSFetchRequest<MISItem> = MISItem.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MISItem> {
        let request: NSFetchRequest<MISItem> = MISItem.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
    
}

public class MISDataLotItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MISLotItem> {
        return NSFetchRequest<MISLotItem>(entityName: "MISLotItem")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MISLotItem> {
        let request: NSFetchRequest<MISLotItem> = MISLotItem.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MISLotItem> {
        let request: NSFetchRequest<MISLotItem> = MISLotItem.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
}

public class MISDataAggregation: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MISAggregation> {
        return NSFetchRequest<MISAggregation>(entityName: "MISAggregation")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<MISAggregation> {
        let request: NSFetchRequest<MISAggregation> = MISAggregation.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<MISAggregation> {
        let request: NSFetchRequest<MISAggregation> = MISAggregation.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
}
