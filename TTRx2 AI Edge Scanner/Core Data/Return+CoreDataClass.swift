//
//  Return+CoreDataClass.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Saugata Bhandari on 18/06/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Return)
public class Return: NSManagedObject {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    static var sortedFetchRequest: NSFetchRequest<Return> {
        let request: NSFetchRequest<Return> = Return.fetchRequest()
        request.sortDescriptors = Return.defaultSortDescriptors
        return request
    }
    static var activeFetchRequest: NSFetchRequest<Return> {
        let request: NSFetchRequest<Return> = Return.fetchRequest()
        request.predicate = NSPredicate(format: "is_active == true")
        return request
    }
}
