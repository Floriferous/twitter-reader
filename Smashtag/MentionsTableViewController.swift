//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import CoreData

class MentionsTableViewController: CoreDataTableViewController {
    
    var searchKey: String? { didSet { updateUI() } }
    
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    
    private func updateUI() {
        if let context = managedObjectContext where searchKey!.characters.count > 0 {
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "amount > 1 and searchkey.name contains[c] %@", searchKey!)
            
            let sort1 = NSSortDescriptor(key: "amount", ascending: false)
            let sort2 = NSSortDescriptor(key: "keyword", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            
            request.sortDescriptors = [sort1, sort2]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
        } else {
            fetchedResultsController = nil
        }
    }
    
    
    
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    //
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 1
    //    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Popular Mention", forIndexPath: indexPath)
        
        if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var mentionName: String?
            var count: Int?
            mention.managedObjectContext?.performBlockAndWait {
                mentionName = mention.keyword
                count = Int(mention.amount!)
            }
            cell.textLabel?.text = mentionName
            cell.detailTextLabel?.text = String(count!)
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Search Tweets" {
            if let vc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    vc.searchText = cell.textLabel?.text
                    vc.title = cell.textLabel?.text
                }
            }
        }
    }
}
