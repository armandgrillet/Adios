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
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    let listsManager = ListsManager()
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios", optionalDirectory: "wormhole")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ListsManager.removeFollowedListsData()
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            userDefaults.setObject(onboardManager.getRealListsFromChoices(), forKey: "followedLists")
            userDefaults.synchronize()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        wormhole.listenForMessageWithIdentifier("updateStatus") { (messageObject: AnyObject?) -> Void in
            if let message = messageObject as! String? {
                if message != "✅" {
                    self.status.text = message
                } else {
                    self.performSegueWithIdentifier("Done", sender: self)
                }
            }
        }
        downloadManager.downloadFollowedLists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
