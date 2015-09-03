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
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            ListsManager.removeFollowedListsData()
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotification:", name: NSUserDefaultsDidChangeNotification, object: nil)
                self.downloadManager.downloadLists(self.onboardManager.getRealListsFromChoices())
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateNotification(notification:NSNotification?) {
        let message = NSUserDefaults.standardUserDefaults().stringForKey("updateStatus")
        if message == "✅" {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil) // No infinite loop.
            let realLists = onboardManager.getRealListsFromChoices()
            NSUserDefaults.standardUserDefaults().setObject(realLists, forKey: "followedLists")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotification:", name: NSUserDefaultsDidChangeNotification, object: nil) // For the deinit
            self.performSegueWithIdentifier("Done", sender: self)
        } else if message == "❌" {
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
}
