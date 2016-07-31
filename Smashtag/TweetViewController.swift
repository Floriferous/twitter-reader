//
//  TweetViewController.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/7/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import Twitter

class TweetViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.screenName
            if let media = tweet?.media {
                if media.count > 0 {
                    mentions.append(Mentions(title: "Images",
                        data: media.map { MentionItem.Image($0.url, $0.aspectRatio) }))
                }
            }
            if let urls = tweet?.urls {
                if urls.count > 0 {
                    mentions.append(Mentions(title: "URLs",
                        data: urls.map { MentionItem.Keyword($0.keyword) }))
                }
            }
            if let hashtags = tweet?.hashtags {
                if hashtags.count > 0 {
                    mentions.append(Mentions(title: "Hashtags",
                        data: hashtags.map { MentionItem.Keyword($0.keyword) }))
                }
            }
            if let users = tweet?.userMentions {
                var userItems = [MentionItem.Keyword("@" + tweet!.user.screenName)]
                if users.count > 0 {
                    userItems += users.map { MentionItem.Keyword($0.keyword) }
                }
                mentions.append(Mentions(title: "Users", data: userItems))
            }
        }
    }
    
    var mentions: [Mentions] = []
    
    struct Mentions
    {
        var title: String
        var data: [MentionItem]
        
        var description: String { return "\(title): \(data)" }
    }
    
    enum MentionItem
    {
        case Keyword(String)
        case Image(NSURL, Double)
        
        var description: String {
            switch self {
            case .Keyword(let keyword): return keyword
            case .Image(let url, _): return url.path!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image (_, let ratio): return tableView.bounds.size.width / CGFloat(ratio)
        default: break
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "Image Cell"
        static let RegularCellIdentifier = "Regular Cell"
        static let SearchSegue = "Search Tweets"
        static let WebSegue = "Open Browser"
        static let ImageSegue = "Show Image"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(
                Storyboard.RegularCellIdentifier,
                forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = keyword
            return cell
        case .Image(let url, let ratio):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
            cell.imageUrl = url
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
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
            } else if identifier == Storyboard.ImageSegue {
                if let ivc = (segue.destinationViewController.contentViewController as? ImageViewController) {
                    if let imageCell = sender as? ImageTableViewCell {
                        ivc.imageURL = imageCell.imageUrl
                    }
                }
            }
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.SearchSegue {
            if let sendingCell = sender as? UITableViewCell {
                if !(sendingCell.textLabel!.text!.hasPrefix("@") || sendingCell.textLabel!.text!.hasPrefix("#")) {
                    //performSegueWithIdentifier(Storyboard.WebSegue, sender: sender)
                    UIApplication.sharedApplication().openURL(NSURL(string: sendingCell.textLabel!.text!)!)
                    return false
                }
            }
        }
        return true
    }
    
    
    
}
