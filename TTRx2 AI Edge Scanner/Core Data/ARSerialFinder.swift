//
//  ARSerialFinder.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 30/03/22.
//  Copyright © 2022 AQB Solutions Private Limited. All rights reserved.
//,,,sb11-1

import Foundation
import CoreData

public class ARSerialFinder: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ARCriterias> {
        return NSFetchRequest<ARCriterias>(entityName: "ARCriterias")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<ARCriterias> {
        let request: NSFetchRequest<ARCriterias> = ARCriterias.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }
    
    @nonobjc public class func fetchAutoIncrementId() -> NSFetchRequest<ARCriterias> {
        let request: NSFetchRequest<ARCriterias> = ARCriterias.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        return request
    }
}
