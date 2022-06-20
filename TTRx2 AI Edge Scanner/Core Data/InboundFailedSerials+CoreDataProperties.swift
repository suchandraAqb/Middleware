//
//  InboundFailedSerials+CoreDataProperties.swift
//  TTRx2 AI Edge Scanner
//
//  Created by AQB Solutions Private Limited on 13/12/21.
//  Copyright © 2021 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension InboundFailedSerials {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboundFailedSerials> {
        return NSFetchRequest<InboundFailedSerials>(entityName: "InboundFailedSerials")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<InboundFailedSerials> {
        let request: NSFetchRequest<InboundFailedSerials> = InboundFailedSerials.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
        return request
    }
    

    @NSManaged public var scanned_code: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_uuid: String?
    @NSManaged public var serial_number: String?
    @NSManaged public var lot_number: String?
    @NSManaged public var gtin14: String?
    @NSManaged public var expiration_date: String?
    @NSManaged public var shipment_id: String?
    @NSManaged public var reason: String?

}
