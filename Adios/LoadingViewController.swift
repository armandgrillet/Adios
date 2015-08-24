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
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    let listsManager = ListsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSUserDefaults.standardUserDefaults().setObject(onboardManager.getRealListsFromChoices(), forKey: "settledLists")
        NSUserDefaults.standardUserDefaults().setObject("Downloading", forKey: "updateStatus")
        NSUserDefaults.standardUserDefaults().synchronize()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateStatus"), name: NSUserDefaultsDidChangeNotification, object: nil)
        listsManager.setFollowedLists(onboardManager.getRealListsFromChoices())
        downloadManager.downloadFollowedLists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        seeUpdate()
    }
    
    func seeUpdate() {
        if NSUserDefaults.standardUserDefaults().stringForKey("updateStatus") != "✅" {
            status.text = NSUserDefaults.standardUserDefaults().stringForKey("updateStatus")
        } else {
            self.performSegueWithIdentifier("Done", sender: self)
        }
        
    }
    
    deinit {
        //Remove observer
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "updateStatus")
    }
}
