//
//  LoadingViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            ListsManager.removeFollowedListsData()
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.updateNotification(_:)), name: NSUserDefaultsDidChangeNotification, object: nil)
                self.downloadManager.downloadLists(self.onboardManager.getRealListsFromChoices())
            }
        }
    }
    
    func updateNotification(notification:NSNotification?) {
        let message = NSUserDefaults.standardUserDefaults().stringForKey("updateStatus")
        if message == "success" {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil) // No loop
            NSUserDefaults.standardUserDefaults().setObject(self.onboardManager.getRealListsFromChoices(), forKey: "followedLists")
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
            NSUserDefaults.standardUserDefaults().synchronize()
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("Done", sender: self)
            })
        } else if message == "fail" {
            self.status.text = NSLocalizedString("Something went wrong!", comment: "Alert label when something went wrong")
            self.cancelButton.enabled = true
            self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Button label to cancel something"), forState: .Normal)
        } else if message != nil {
            self.status.text = NSLocalizedString(message!, comment: "Message from the model to tell what's happening when loading the lists")
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
