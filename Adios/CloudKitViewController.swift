//
//  CloudKitViewController.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import CloudKit

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
    
    @IBAction func checkCloudKit(sender: UIButton) {
        downloadManager.downloadRulesFromList("AdiosList", nextLists: [])
    }
    
    @IBAction func askForNotifications(sender: UIButton) {
        subscriptionsManager.addSubscription("AdiosList")
    }
}
