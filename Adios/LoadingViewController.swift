//
//  LoadingViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MMWormhole

class LoadingViewController: UIViewController {
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    let listsManager = ListsManager()
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios", optionalDirectory: "wormhole")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            ListsManager.removeFollowedListsData()
            dispatch_async(dispatch_get_main_queue()) {
                NSUserDefaults().setObject(self.onboardManager.getRealListsFromChoices(), forKey: "followedLists")
                
                // Do any additional setup after loading the view, typically from a nib.
                self.wormhole.listenForMessageWithIdentifier("updateStatus") { (messageObject: AnyObject?) -> Void in
                    if let message = messageObject as! String? {
                        if message == "✅" {
                            self.performSegueWithIdentifier("Done", sender: self)
                        } else if message == "❌" {
                            self.status.text = "Something went wrong!"
                            self.cancelButton.enabled = true
                            self.cancelButton.setTitle("Cancel", forState: .Normal)
                        } else {
                            self.status.text = message
                        }
                    }
                }
                self.downloadManager.downloadFollowedLists()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
