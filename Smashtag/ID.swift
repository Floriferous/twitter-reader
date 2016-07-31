//
//  ID.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class ID: NSManagedObject {
    
    
    class func addIdentifier(identifier: String, mention: Mention, inManagedObjectContext context: NSManagedObjectContext) -> ID? {
        
        let request = NSFetchRequest(entityName: "ID")
        request.predicate = NSPredicate(format: "id = %@ and mention.keyword matches[c] %@", identifier, mention.keyword!)
        if let fetchedID = (try? context.executeFetchRequest(request))?.first as? ID {
            return fetchedID
        } else if let newID = NSEntityDescription.insertNewObjectForEntityForName("ID", inManagedObjectContext: context) as? ID {
            newID.id = identifier
            newID.mention = mention
            return newID
        }
        return nil
    }
    
}
