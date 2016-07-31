//
//  SearchKey.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import Foundation
import CoreData


class SearchKey: NSManagedObject {

    class func searchKeyWithName(searchKeyName: String, inManagedObjectContext context: NSManagedObjectContext) -> SearchKey? {
        
        let request = NSFetchRequest(entityName: "SearchKey")
        request.predicate = NSPredicate(format: "name matches[c] %@", searchKeyName)
        if let fetchedSearchKey = (try? context.executeFetchRequest(request))?.first as? SearchKey {
            
            return fetchedSearchKey
        } else if let newSearchKey = NSEntityDescription.insertNewObjectForEntityForName("SearchKey", inManagedObjectContext: context) as? SearchKey {
            newSearchKey.name = searchKeyName
            
            return newSearchKey
        }
        
        return nil
    }
    
}
