//
//  Mention+CoreDataProperties.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mention {

    @NSManaged var amount: NSNumber?
    @NSManaged var keyword: String?
    @NSManaged var searchkey: SearchKey?
    @NSManaged var ids: NSSet?

}