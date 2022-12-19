//
//  MW_PickingManualLotOrScanSerial+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 04/11/22.
//
//,,,sbm4

import Foundation
import CoreData


extension MW_PickingManualLotOrScanSerial {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingManualLotOrScanSerial> {
        return NSFetchRequest<MW_PickingManualLotOrScanSerial>(entityName: "MW_PickingManualLotOrScanSerial")
    }

    @NSManaged public var erp_uuid: String?
    @NSManaged public var erp_name: String?
    @NSManaged public var so_number: String?
    @NSManaged public var so_unique_id: String?
    @NSManaged public var product_unique_id: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_code: String?
    @NSManaged public var product_delivered_qty: String?
    @NSManaged public var product_demand_qty: String?
    @NSManaged public var product_qty_to_deliver: String?
    @NSManaged public var product_tracking: String?
    @NSManaged public var lot_number: String?
    @NSManaged public var quantity: String?
    @NSManaged public var is_container: Bool
    @NSManaged public var c_serial: String?
    @NSManaged public var c_gtin: String?
    @NSManaged public var p_serials: String?
    @NSManaged public var p_gtins: String?
    @NSManaged public var serial_number: String?
    @NSManaged public var is_edited: Bool
    @NSManaged public var id: Int16
    
    
    func convertCoreDataRequestsToMWPickingManuallyLotOrScanSerialBaseModel() -> MWPickingManuallyLotOrScanSerialBaseModel {
        let pSerialsArr = Utility.converJsonToArray(string: self.p_serials!)
        let pGtinsArr = Utility.converJsonToArray(string: self.p_gtins!)

        return MWPickingManuallyLotOrScanSerialBaseModel(primaryID: id,
                                                           erpUUID: self.erp_uuid,
                                                           erpName: self.erp_name,
                                                           soNumber: self.so_number,
                                                           soUniqueID: self.so_unique_id,
                                                           productUniqueID: self.product_unique_id,
                                                           productName: self.product_name,
                                                           productCode: self.product_code,
                                                           productDeliveredQuantity: self.product_delivered_qty,
                                                           productDemandQuantity: self.product_demand_qty,
                                                           productQtyToDeliver: self.product_qty_to_deliver,
                                                           productTracking: self.product_tracking,
                                                           lotNumber: self.lot_number,
                                                           quantity: self.quantity,
                                                           isContainer: self.is_container,
                                                           cSerial: self.c_serial,
                                                           cGtin: self.c_gtin,
                                                           pSerials: pSerialsArr,
                                                           pGtins: pGtinsArr,
                                                           serialNumber: self.serial_number,
                                                           isEdited: self.is_edited)
    }//,,,sbm2
}
