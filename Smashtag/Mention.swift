//
//  Mention.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Mention: NSManagedObject {
    
    
    // returns a mention from the database
    
    class func mentionWithSearchKey(mention: Twitter.Mention, searchKeyName: String, identifier: String, inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
        
        let request = NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "keyword matches[c] %@ and searchkey.name matches[c] %@", mention.keyword, searchKeyName)
        
        if let fetchedMention =  (try? context.executeFetchRequest(request))?.first as? Mention {
            if let idSet = fetchedMention.ids {
                let idArray = idSet.allObjects
                var found = false
                var count = 0
                for id in idArray {
                    count += 1
                    if let iteratedID = id as? ID {
                        if iteratedID.id == identifier {
                            found = true
                            break
                        }
                    }
                }
                
                if found == false {
                    fetchedMention.amount = NSNumber(integer: Int(fetchedMention.amount!) + 1)
                    _ = ID.addIdentifier(identifier, mention: fetchedMention, inManagedObjectContext: context)!
                }
            }
            
            return fetchedMention
            
        } else if let newMention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            newMention.amount = NSNumber(integer: 1)
            newMention.keyword = mention.keyword
            newMention.searchkey = SearchKey.searchKeyWithName(searchKeyName, inManagedObjectContext: context)
            _ = ID.addIdentifier(identifier, mention: newMention, inManagedObjectContext: context)!
            return newMention
        }
        return nil
    }
    
}
