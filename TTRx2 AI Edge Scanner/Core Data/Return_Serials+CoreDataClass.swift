//
//  Return_Serials+CoreDataClass.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 23/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Return_Serials)
public class Return_Serials: NSManagedObject {
    enum Condition:String {
        case Resalable = "REUSABLE"
        case Quarantine = "QUARANTINE"
        case Destruct = "DESTRUCT"
    }
    
    enum Status:String {
        case Pending = "PENDING"
        case Removed = "REMOVED"
        case Failed = "FAILED"
        case Verified = "VERFIED"
    }
}
