//
//  SettingsTableViewController.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/9/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import CoreData


class SettingsTableViewController: UITableViewController {
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            // Do nothing
        }))
        
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.deleteEntity("ID")
            self.deleteEntity("Mention")
            self.deleteEntity("SearchKey")
            
            
            // erase recent searches
            for i in 1...self.defaults.integerForKey("Max Recent") {
                self.defaults.setObject(nil, forKey: String(i))
            }
        }))
        

    }
    
    @IBOutlet weak var SliderValueFetch: UILabel!
    
    @IBOutlet weak var SliderValueRecent: UILabel!
    
    @IBAction func maxRecent(sender: UISlider) {
        defaults.setObject(Int(sender.value), forKey: "Max Recent")
        SliderValueRecent.text = String(Int(sender.value))
    }
    
    
    @IBAction func tweetNumberSlider(sender: UISlider) {
        defaults.setObject(Int(sender.value), forKey: "Number Of Tweets")
        SliderValueFetch.text = String(Int(sender.value))
    }
    
    var refreshAlert = UIAlertController(title: "Clear Everything", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
    
    @IBAction func clearRecent(sender: UIButton) {
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    private func deleteEntity(entity: String) {
        let fetchRequest = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // delegate objects
        let myManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let myPersistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
        
        // perform the delete
        do {
            try myPersistentStoreCoordinator.executeRequest(deleteRequest, withContext: myManagedObjectContext)
        } catch let error as NSError {
            print(error)
        }
    }
}