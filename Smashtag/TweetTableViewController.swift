//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/7/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    var dateFormatter = NSDateFormatter()
    
    
    
    //Having an array of an array of things is great because you can load individual sections into your table view instead of individual rows.
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
        }
    }
    
    private var twitterRequest: Twitter.Request?
    {
        if let query = searchText where !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: defaults.integerForKey("Number Of Tweets"))
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    @objc private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets{ [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            self.defaults.addKeyAtTop(self.searchText!)
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                }
            }
        }
        
        refreshControl?.endRefreshing()
    }
    
    private func appendOlderTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets{ [weak weakSelf = self] olderTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !olderTweets.isEmpty {
                            weakSelf?.tweets.insert(olderTweets, atIndex: self.tweets.endIndex)
                            weakSelf?.updateDatabase(olderTweets)
                        }
                    }
                }
            }
        }
        refreshControl?.endRefreshing()
    }
    
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock {
            for tweet in newTweets {
                for mention in tweet.userMentions {
                    if mention.keyword.lowercaseString != self.searchText?.lowercaseString {
                        _ = Mention.mentionWithSearchKey(mention, searchKeyName: self.searchText!, identifier: tweet.id, inManagedObjectContext: self.managedObjectContext!)
                    }
                }
                for hashtag in tweet.hashtags {
                    if hashtag.keyword.lowercaseString != self.searchText?.lowercaseString {
                        _ = Mention.mentionWithSearchKey(hashtag, searchKeyName: self.searchText!, identifier: tweet.id,inManagedObjectContext: self.managedObjectContext!)
                    }
                }
            }
            
            
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("save error: \(error)")
            }
            
        }
    }
    
    
    
    @IBOutlet weak var searchTextField: UITextField!
        {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTweets), forControlEvents: UIControlEvents.ValueChanged)
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
    
    @objc private func refreshTweets() {
        twitterRequest!.requestForNewer
        searchForTweets()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    @IBAction func StartOver(sender: UIBarButtonItem) {
        //if self.navigationController.
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "Show Tweet" {
                if let vc = segue.destinationViewController.contentViewController as? TweetViewController {
                    if let sendingCell = sender as? TweetTableViewCell {
                        vc.tweet = sendingCell.tweet!
                        vc.navigationItem.title = sendingCell.tweet!.user.name + "'s Tweet"
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
        {
            // app already launched
        }
        else
        {
            // This is the first launch ever
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSUserDefaults.standardUserDefaults().setObject(20, forKey: "Max Recent")
            NSUserDefaults.standardUserDefaults().setObject(100, forKey: "Number Of Tweets")
        }
    }
    
}



extension UIViewController {
    var contentViewController: UIViewController{
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
    
}

