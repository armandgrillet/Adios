//
//  CloudKitViewController.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import CloudKit
import SafariServices

class CloudKitViewController: UIViewController {
    let downloadManager = DownloadManager()
    let subscriptionsManager = SubscriptionsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func downloadAdiosList(sender: UIButton) {
        downloadManager.downloadLists(["AdiosList"])
    }
    
    @IBAction func subscribeToAdiosList(sender: UIButton) {
        subscriptionsManager.subscribeToUpdates()
    }
    
    @IBAction func applyContentBlockers(sender: UIButton) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if error == nil {
                        print("Rules applied")
                    } else {
                        print(otherError)
                    }
                }
            } else {
                print(error)
            }
        }

    }
    @IBAction func printAdiosList(sender: UIButton) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            
            print(userDefaults.arrayForKey("AdiosListBlock"))
            print(userDefaults.arrayForKey("AdiosListBlockCookies"))
            print(userDefaults.arrayForKey("AdiosListCSSDisplayNone"))
            print(userDefaults.arrayForKey("AdiosListIgnorePreviousRules"))
        }
    }
}
