//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/8/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import CoreData

class RecentTableViewController: UITableViewController {

    private var defaults = NSUserDefaults.standardUserDefaults()
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    private struct Storyboard {
        static let RegularCellIdentifier = "Regular Cell"
        static let SearchSegue = "Search Tweets"
        static let MentionsSegue = "Show Mentions"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaults.getAmountOfKeys()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RegularCellIdentifier, forIndexPath: indexPath)

        let row = indexPath.row
        if let searchKey = defaults.stringForKey(String(row + 1)) {
            cell.textLabel?.text = searchKey
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.SearchSegue {
                if let sendingCell = sender as? UITableViewCell {
                    if let vc = segue.destinationViewController.contentViewController as? TweetTableViewController {
                        vc.searchText = sendingCell.textLabel?.text
                        //defaults.addKeyAtTop((sendingCell.textLabel?.text)!)
                    }
                }
            }
            if identifier == Storyboard.MentionsSegue {
                if let sendingCell = sender as? UITableViewCell {
                    if let vc = segue.destinationViewController.contentViewController as? MentionsTableViewController {
                        vc.searchKey = sendingCell.textLabel?.text
                        vc.title = sendingCell.textLabel?.text
                        vc.managedObjectContext = managedObjectContext
                    }
                }
            }
        }
    }
    
    

}
