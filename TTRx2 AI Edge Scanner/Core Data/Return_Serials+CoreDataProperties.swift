//
//  Return_Serials+CoreDataProperties.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension Return_Serials {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Return_Serials> {
        return NSFetchRequest<Return_Serials>(entityName: "Return_Serials")
    }
    
    @nonobjc public class func fetchSerialRequest(barcode:String) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "barcode == '\(barcode)'")
        return request
    }
    
    @nonobjc public class func fetchSerialForReturnRequest(uuid:String) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "return_uuid == '\(uuid)'")
        return request
    }
    
    @nonobjc public class func fetchValidSerialRequest(uuid:String,isDistinct:Bool = false) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "return_uuid == '\(uuid)' and status != 'REMOVED'")
        request.returnsDistinctResults = isDistinct
        return request
    }
    
    @nonobjc public class func fetchSerialWithStatusRequest(uuid:String,status:String) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "return_uuid == '\(uuid)' and status == '\(status)'")
        return request
    }
    
    @nonobjc public class func fetchReturnSerialWithConditionRequest(uuid:String,condition:String) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "return_uuid == '\(uuid)' and condition == '\(condition)' and status != 'REMOVED'")
        return request
    }
    
    @nonobjc public class func fetchSerialWithConditionRequest(return_uuid:String,product_uuid:String,condition:String) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = NSPredicate(format: "return_uuid == '\(return_uuid)' and product_uuid == '\(product_uuid)' and condition == '\(condition)' and status != 'REMOVED'")
        return request
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate) -> NSFetchRequest<Return_Serials> {
        let request: NSFetchRequest<Return_Serials> = Return_Serials.fetchRequest()
        request.predicate = predicate
        return request
    }
    
    
    @NSManaged public var condition: String?
    @NSManaged public var event_id: String?
    @NSManaged public var product_name: String?
    @NSManaged public var return_uuid: String?
    @NSManaged public var serial: String?
    @NSManaged public var status: String?
    @NSManaged public var is_send_for_verification: Bool
    @NSManaged public var lot: String?
    @NSManaged public var product_uuid: String?
    @NSManaged public var gtin: String?
    @NSManaged public var barcode: String?
    @NSManaged public var gs1_serial: String?
    @NSManaged public var expiration_date: String?
    @NSManaged public var failed_reason: String?
    @NSManaged public var is_lot_based: Bool
    @NSManaged public var lot_based_qty_reusable: Int16
    @NSManaged public var lot_based_qty_desturction: Int16
    @NSManaged public var lot_based_qty_quarantine: Int16
    @NSManaged public var is_valid: Bool
    @NSManaged public var error: String?
    
}
