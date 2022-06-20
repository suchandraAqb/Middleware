//
//  DirectPicking+CoreDataProperties.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 27/07/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension DirectPicking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DirectPicking> {
        return NSFetchRequest<DirectPicking>(entityName: "DirectPicking")
    }
    
    @nonobjc public class func fetchRequestWithPredicate(predicate:NSPredicate?) -> NSFetchRequest<DirectPicking> {
        let request: NSFetchRequest<DirectPicking> = DirectPicking.fetchRequest()
        if predicate != nil{
            request.predicate = predicate!
        }
       
        return request
    }

    @NSManaged public var barcode: String?
    @NSManaged public var gs1_serial: String?
    @NSManaged public var gtin: String?
    @NSManaged public var is_lot_based: Bool
    @NSManaged public var is_send_for_verification: Bool
    @NSManaged public var is_valid: Bool
    @NSManaged public var location_uuid: String?
    @NSManaged public var lot_max_quantity: Int16
    @NSManaged public var lot_no: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_uuid: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var serial: String?
    @NSManaged public var shelf_uuid: String?
    @NSManaged public var storage_uuid: String?
    @NSManaged public var is_container: Bool
    @NSManaged public var identifier_type: String?
    @NSManaged public var identifier_value: String?
    @NSManaged public var expiration_date: String?

}
