//
//  Receiving.swift
//  TTRx2 AI Edge Scanner
//
//  Created by sayak sarkar on 26/03/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//

import Foundation
import CoreData

public class Receiving: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiveLotEdit> {
        return NSFetchRequest<ReceiveLotEdit>(entityName: "ReceiveLotEdit")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<ReceiveLotEdit> {
        let request: NSFetchRequest<ReceiveLotEdit> = ReceiveLotEdit.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<ReceiveLotEdit> {
        let request: NSFetchRequest<ReceiveLotEdit> = ReceiveLotEdit.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
}
public class ReceivingLineItem{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiveLineItem> {
        return NSFetchRequest<ReceiveLineItem>(entityName: "ReceiveLineItem")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<ReceiveLineItem> {
        let request: NSFetchRequest<ReceiveLineItem> = ReceiveLineItem.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<ReceiveLineItem> {
        let request: NSFetchRequest<ReceiveLineItem> = ReceiveLineItem.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
}
