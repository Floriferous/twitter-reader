//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/8/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    var imageUrl: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var ImageCell: UIImageView!
    
    private func updateUI() {
        if let profileImageURL = imageUrl {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                if let imageData = NSData(contentsOfURL: profileImageURL) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if UIImage(data: imageData) != nil {
                            self.ImageCell.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
}
