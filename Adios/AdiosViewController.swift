//
//  AdiosViewController.swift
//  Adios
//
//  Created by Armand Grillet on 16/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class AdiosViewController: UIViewController {
    let onboardManager = OnboardManager()
    
    @IBOutlet weak var configurationState: UILabel!
    @IBOutlet weak var lastUpdateButton: UIButton!
    
    @IBOutlet weak var configureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foregroundNotification:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressOnConfigure:")
        configureButton.addGestureRecognizer(longPressRecognizer)
        displayAdiosState()
    }
    
    func displayAdiosState() {
        let followedLists = ListsManager.getFollowedLists()
        if followedLists != [] {
            configurationState.text = "Adios is configured"
            
            if let lastUpdateTimestamp = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdateTimestamp") {
                let formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                formatter.dateStyle = .ShortStyle
                lastUpdateButton.setTitle("Last download: " + formatter.stringFromDate(lastUpdateTimestamp as! NSDate), forState: .Normal)
                lastUpdateButton.enabled = true
            }
            
        } else {
            configurationState.text = "Adios doesn't block ads yet! Configure Adios first."
            lastUpdateButton.enabled = false
            lastUpdateButton.setTitle("", forState: .Disabled)
        }
    }
    
    func foregroundNotification(notification:NSNotification?) {
        displayAdiosState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayAdiosState()
    }
    
    @IBAction func longPressOnConfigure(sender: UILongPressGestureRecognizer) {
        self.performSegueWithIdentifier("Advanced", sender: self)
    }
    
    @IBAction func updateLists(sender: UIButton) {
        let alertController = UIAlertController(title: "Update the lists?", message: "", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.performSegueWithIdentifier("Update", sender: self)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Configure" || segue.identifier == "Advanced" {
            onboardManager.reset()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
}


