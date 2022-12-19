//
//  MW_PickingLineItem+CoreDataProperties.swift
//  
//
//  Created by aqbsol on 04/11/22.
//
//,,,sbm4

import Foundation
import CoreData


extension MW_PickingLineItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MW_PickingLineItem> {
        return NSFetchRequest<MW_PickingLineItem>(entityName: "MW_PickingLineItem")
    }

    @NSManaged public var erp_name: String?
    @NSManaged public var erp_uuid: String?
    @NSManaged public var is_edited: Bool
    @NSManaged public var so_number: String?
    @NSManaged public var so_unique_id: String?
    @NSManaged public var product_code: String?
    @NSManaged public var product_demand_qty: String?
    @NSManaged public var product_flow_type: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_qty_to_deliver: String?
    @NSManaged public var product_delivered_qty: String?
    @NSManaged public var product_tracking: String?
    @NSManaged public var product_unique_id: String?
    @NSManaged public var id: Int16
    @NSManaged public var transaction_type: String?
    
    
    func convertCoreDataRequestsToMWPickingViewItemsModel() -> MWPickingViewItemsModel {
        return MWPickingViewItemsModel(primaryID:id,
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
                                transactionType: self.transaction_type,
                                productFlowType: self.product_flow_type,
                                isEdited: self.is_edited
                              )
    }//,,,sbm2
}
