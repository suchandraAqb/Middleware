//
//  MW_ReceivingScanProduct+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 28/10/22.
//
//,,,sbm2

import Foundation
import CoreData


extension MW_ReceivingScanProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingScanProduct> {
        return NSFetchRequest<MW_ReceivingScanProduct>(entityName: "MW_ReceivingScanProduct")
    }

    @NSManaged public var id: Int16
    @NSManaged public var erp_uuid: String?
    @NSManaged public var erp_name: String?
    @NSManaged public var po_number: String?
    @NSManaged public var po_unique_id: String?
    @NSManaged public var gtin: String?
    @NSManaged public var indicator: String?
    @NSManaged public var serial_number: String?
    @NSManaged public var day: String?
    @NSManaged public var month: String?
    @NSManaged public var year: String?
    @NSManaged public var lot_number: String?
    @NSManaged public var product_tracking: String?//,,,sbm2-1

    func convertCoreDataRequestsToMWReceivingScanProductModel() -> MWReceivingScanProductModel {
        return MWReceivingScanProductModel(primaryID: id,
                                           erpUUID: self.erp_uuid,
                                           erpName: self.erp_name,
                                           poUniqueID: self.po_unique_id,
                                           poNumber: self.po_number,
                                           GTIN: self.gtin,
                                           indicator: self.indicator,
                                           serialNumber: self.serial_number,
                                           day: self.day,
                                           month: self.month,
                                           year: self.year,
                                           lotNumber: self.lot_number,
                                           productTracking: self.product_tracking)//,,,sbm2-1)
    }//,,,sbm2
}
