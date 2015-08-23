//
//  UpdateViewController.swift
//  Adios
//
//  Created by Armand Grillet on 23/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

private var defaultsContext = 0

class UpdateViewController: UIViewController {
    @IBOutlet weak var status: UILabel!
    let onboardManager = OnboardManager()
    let downloadManager = DownloadManager()
    let listsManager = ListsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "updateStatus", options: NSKeyValueObservingOptions(), context: &defaultsContext)
        downloadManager.getNewRecordsManually()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &defaultsContext {
            seeUpdate()
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
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
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "updateStatus", context: &defaultsContext)
    }
}
