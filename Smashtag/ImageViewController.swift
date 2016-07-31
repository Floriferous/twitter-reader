//
//  ImageViewController.swift
//  Cassini
//
//  Created by Florian Bienefelt on 7/7/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    var imageURL: NSURL? //this is the model
        {
        didSet {
            image = nil
            if view.window != nil { // reliable way to test if you are on screen. You wouldn't want to start fetching the image if you're not on screen
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) { //back to the main queue
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("ignored data from url: \(url)")
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
        {
        didSet {
            scrollView?.contentSize = imageView.frame.size //both here and in the image
            scrollView.delegate = self //understand this
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size //since this is an outlet, the app would crash if you didn't unwrap it
            spinner?.stopAnimating()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if image != nil {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            let imageView = UIImageView(image: self.image!)
            imageView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
            
            if image!.size.height > image!.size.width {
                imageView.contentMode = .ScaleAspectFill  // Portrait
            } else {
                imageView.contentMode = .ScaleAspectFit  // Landscape
            }
        }
        
        scrollView.addSubview(imageView)
    }
    
    
    
}
