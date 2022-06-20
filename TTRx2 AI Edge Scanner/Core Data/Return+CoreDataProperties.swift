//
//  Return+CoreDataProperties.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 18/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension Return {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Return> {
        return NSFetchRequest<Return>(entityName: "Return")
    }
    
    @nonobjc public class func fetchReturnRequest(serial:String) -> NSFetchRequest<Return> {
        let request: NSFetchRequest<Return> = Return.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == '\(serial)'")
        return request
    }

    @NSManaged public var items: String?
    @NSManaged public var rma: String?
    @NSManaged public var source_shipment: String?
    @NSManaged public var uuid: String?
    @NSManaged public var is_active: Bool

}
