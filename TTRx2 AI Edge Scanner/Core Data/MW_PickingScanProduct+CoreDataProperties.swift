//
//  MW_PickingScanProduct+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 04/11/22.
//
//,,,sbm4

import Foundation
import CoreData


extension MW_PickingScanProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingScanProduct> {
        return NSFetchRequest<MW_PickingScanProduct>(entityName: "MW_PickingScanProduct")
    }

    @NSManaged public var id: Int16
    @NSManaged public var erp_uuid: String?
    @NSManaged public var erp_name: String?
    @NSManaged public var so_number: String?
    @NSManaged public var so_unique_id: String?
    @NSManaged public var gtin: String?
    @NSManaged public var indicator: String?
    @NSManaged public var serial_number: String?
    @NSManaged public var day: String?
    @NSManaged public var month: String?
    @NSManaged public var year: String?
    @NSManaged public var lot_number: String?
    @NSManaged public var product_tracking: String?//,,,sbm2-1
    @NSManaged public var quantity: String?//,,,sbm2-1
    
    func convertCoreDataRequestsToMWPickingScanProductModel() -> MWPickingScanProductModel {
        return MWPickingScanProductModel(primaryID: id,
                                           erpUUID: self.erp_uuid,
                                           erpName: self.erp_name,
                                           soUniqueID: self.so_unique_id,
                                           soNumber: self.so_number,
                                           GTIN: self.gtin,
                                           indicator: self.indicator,
                                           serialNumber: self.serial_number,
                                           day: self.day,
                                           month: self.month,
                                           year: self.year,
                                           lotNumber: self.lot_number,
                                           productTracking: self.product_tracking,
                                           quantity: self.quantity)//,,,sbm2-1
    }//,,,sbm2
}
