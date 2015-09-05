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
                lastUpdateButton.setTitle("Last update: " + formatter.stringFromDate(lastUpdateTimestamp as! NSDate), forState: .Normal)
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


