//
//  MW_ReceivingManualLotOrScanSerial+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 21/10/22.
//
//,,,sbm2

import Foundation
import CoreData


extension MW_ReceivingManualLotOrScanSerial {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingManualLotOrScanSerial> {
        return NSFetchRequest<MW_ReceivingManualLotOrScanSerial>(entityName: "MW_ReceivingManualLotOrScanSerial")
    }

    @NSManaged public var erp_uuid: String?
    @NSManaged public var erp_name: String?
    @NSManaged public var po_number: String?
    @NSManaged public var po_unique_id: String?
    @NSManaged public var product_unique_id: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_code: String?
    @NSManaged public var product_received_qty: String?
    @NSManaged public var product_demand_qty: String?
    @NSManaged public var product_qty_to_receive: String?
    @NSManaged public var product_tracking: String?
    @NSManaged public var product_uom_id: String?
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
    
    
    func convertCoreDataRequestsToMWReceivingManuallyLotOrScanSerialBaseModel() -> MWReceivingManuallyLotOrScanSerialBaseModel {
        let pSerialsArr = Utility.converJsonToArray(string: self.p_serials!)
        let pGtinsArr = Utility.converJsonToArray(string: self.p_gtins!)

        return MWReceivingManuallyLotOrScanSerialBaseModel(primaryID: id,
                                                           erpUUID: self.erp_uuid,
                                                           erpName: self.erp_name,
                                                           poNumber: self.po_number,
                                                           poUniqueID: self.po_unique_id,
                                                           productUniqueID: self.product_unique_id,
                                                           productName: self.product_name,
                                                           productCode: self.product_code,
                                                           productReceivedQuantity: self.product_received_qty,
                                                           productDemandQuantity: self.product_demand_qty,
                                                           productQtyToReceive: self.product_qty_to_receive,
                                                           productTracking: self.product_tracking,
                                                           productUomID: self.product_uom_id,
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
