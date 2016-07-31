//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/7/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    let colors = ["hashtag": UIColor.brownColor(), "url": UIColor.blueColor(), "mention": UIColor.redColor()]
    
    private func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        //Load new information from our tweet (if any)
        if let tweet = self.tweet {
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil {
                
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
                
                changeColor(tweet.userMentions, color: colors["mention"]!)
                changeColor(tweet.urls, color: colors["url"]!)
                changeColor(tweet.hashtags, color: colors["hashtag"]!)
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    if let imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread!
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
            
        }
        
    }
    
    func changeColor(keywords: [Twitter.Mention], color: UIColor) {
        for keyword in keywords {
            let attributedTweet = NSMutableAttributedString(attributedString: tweetTextLabel.attributedText!)
            attributedTweet.addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
            tweetTextLabel.attributedText = attributedTweet
        }
    }
    
}
