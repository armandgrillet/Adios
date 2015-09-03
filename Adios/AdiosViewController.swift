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
    @IBOutlet weak var countries: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var lastUpdate: UIButton!
    
    @IBOutlet weak var configureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressOnConfigure:")
        configureButton.addGestureRecognizer(longPressRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
        var followedLists = ListsManager.getFollowedLists()
        if followedLists != [] {
            configurationState.text = "Adios is configured! Your configuration:"
            
            var countriesText = "You're blocking ads on websites based in "
            countriesText += onboardManager.getCountryFromList(followedLists[0])!
            if followedLists.count > 1 {
                if let secondCountry = onboardManager.getCountryFromList(followedLists[1]) {
                    countriesText += " & \(secondCountry)"
                }
            }
            
            countries.text = countriesText
            
            if followedLists.contains("EasyList_SocialMedia") || followedLists.contains("EasyPrivacy") || followedLists.contains("AdblockWarningRemoval") {
                var detailsText = "You're also blocking "
                if followedLists.contains("EasyList_SocialMedia") {
                    detailsText += "social buttons, "
                }
                if followedLists.contains("EasyPrivacy") {
                    detailsText += "malicious scripts "
                }
                if followedLists.contains("AdblockWarningRemoval") {
                    if followedLists.contains("EasyList_SocialMedia") || followedLists.contains("EasyPrivacy") {
                        detailsText += "and "
                    }
                    detailsText += "messages against ad blockers"
                }
                details.text = detailsText
            } else {
                details.text = ""
            }
            
            if let lastUpdateTimestamp = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdateTimestamp") {
                let formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                formatter.dateStyle = .ShortStyle
                lastUpdate.setTitle("Last update: " + formatter.stringFromDate(lastUpdateTimestamp as! NSDate), forState: .Normal)
            }
            
        } else {
            configurationState.text = "Adios doesn't block ads yet! Configure Adios first."
            countries.text = ""
            details.text = ""
            lastUpdate.enabled = false
            lastUpdate.setTitle("", forState: .Disabled)
        }
    }
    
    @IBAction func longPressOnConfigure(sender: UILongPressGestureRecognizer) {
        self.performSegueWithIdentifier("Advanced", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Configure" {
            onboardManager.reset()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


