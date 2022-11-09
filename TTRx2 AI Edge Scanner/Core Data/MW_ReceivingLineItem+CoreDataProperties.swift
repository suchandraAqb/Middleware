//
//  MW_ReceivingLineItem+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 17/10/22.
//
//,,,sbm2

import Foundation
import CoreData


extension MW_ReceivingLineItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_ReceivingLineItem> {
        return NSFetchRequest<MW_ReceivingLineItem>(entityName: "MW_ReceivingLineItem")
    }

    @NSManaged public var erp_name: String?
    @NSManaged public var erp_uuid: String?
    @NSManaged public var is_edited: Bool
    @NSManaged public var line_item_uuid: String?
    @NSManaged public var po_number: String?
    @NSManaged public var po_unique_id: String?
    @NSManaged public var product_code: String?
    @NSManaged public var product_demand_qty: String?
    @NSManaged public var product_flow_type: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_qty_to_receive: String?
    @NSManaged public var product_received_qty: String?
    @NSManaged public var product_tracking: String?
    @NSManaged public var product_unique_id: String?
    @NSManaged public var product_uom_id: String?
    @NSManaged public var id: Int16
    
    
    func convertCoreDataRequestsToMWViewItemsModel() -> MWViewItemsModel {
        return MWViewItemsModel(primaryID:id,
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
                                lineItemUUID: self.line_item_uuid,
                                productUomID: self.product_uom_id,
                                productFlowType: self.product_flow_type,
                                isEdited: self.is_edited
                              )
    }//,,,sbm2
}
