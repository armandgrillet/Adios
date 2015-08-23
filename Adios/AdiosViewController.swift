//
//  AdiosViewController.swift
//  Adios
//
//  Created by Armand Grillet on 16/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class AdiosViewController: UIViewController {
    let listsManager = ListsManager()
    let onboardManager = OnboardManager()
    
    @IBOutlet weak var configurationState: UILabel!
    @IBOutlet weak var countries: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var lastUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var followedLists = listsManager.getFollowedLists()
        if followedLists != [] {
            configurationState.text = "Adios is configured! Here is your configuration:"
            
            var countriesText = "You're blocking ads on websites based in "
            countriesText += onboardManager.getCountryFromList(followedLists[0])!
            if let secondCountry = onboardManager.getCountryFromList(followedLists[0]) {
                countriesText += " & \(secondCountry)"
            }
            countries.text = countriesText
            
            if followedLists.contains("EasyList_SocialMedia") || followedLists.contains("EasyPrivacy") || followedLists.contains("AdblockWarningRemoval") {
                var detailsText = "You're also blocking "
                if followedLists.contains("EasyList_SocialMedia") {
                    detailsText += "social buttons, "
                }
                if followedLists.contains("EasyPrivacy") {
                    detailsText += "malicious scripts, "
                }
                if followedLists.contains("AdblockWarningRemoval") {
                    detailsText += "messages against Adios"
                }
                details.text = detailsText
            } else {
                details.text = ""
            }
            
            let lastUpdateTimestamp = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdateTimestamp") as NSDate
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            lastUpdate.text = formatter.stringFromDate(lastUpdateTimestamp)
        } else {
            configurationState.text = "Adios doesn't block ads yet! Configure Adios first."
            countries.text = ""
            details.text = ""
            lastUpdate.text = ""
        }
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


