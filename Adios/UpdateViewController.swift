//
//  UpdateViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotification:", name: NSUserDefaultsDidChangeNotification, object: nil)
        self.downloadManager.downloadLists(ListsManager.getFollowedLists(), callback: nil)
    }
    
    func updateNotification(notification:NSNotification?) {
        let message = NSUserDefaults.standardUserDefaults().stringForKey("updateStatus")
        if message == "success" {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("Done", sender: self)
            })
        } else if message == "fail" {
            self.status.text = "Something went wrong!"
            self.cancelButton.enabled = true
            self.cancelButton.setTitle("Cancel", forState: .Normal)
        } else {
            self.status.text = message
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
