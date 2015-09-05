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
    let listsManager = ListsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            ListsManager.removeFollowedListsData()
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotification:", name: NSUserDefaultsDidChangeNotification, object: nil)
                self.downloadManager.downloadLists(self.onboardManager.getRealListsFromChoices(), callback: nil)
            }
        }
    }
    
    func updateNotification(notification:NSNotification?) {
        let message = NSUserDefaults.standardUserDefaults().stringForKey("updateStatus")
        if message == "success" {
            let subscriptionsManager = SubscriptionsManager()
            subscriptionsManager.subscribeToUpdates({ () -> Void in
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil) // No loop
                NSUserDefaults.standardUserDefaults().setObject(self.onboardManager.getRealListsFromChoices(), forKey: "followedLists")
                NSUserDefaults.standardUserDefaults().synchronize()
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
