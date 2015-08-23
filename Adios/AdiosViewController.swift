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
    @IBOutlet weak var mainList: UILabel!
    @IBOutlet weak var secondList: UILabel!
    @IBOutlet weak var socialList: UILabel!
    @IBOutlet weak var lastUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let alwaysFollowedLists = ["AdiosList", "EasyPrivacy", "AdblockWarningRemoval", "EasyList_SocialMedia"]
        var followedLists = listsManager.getFollowedLists()
        if followedLists != [] {
            configurationState.text = "Adios is configured! Here is your configuration:"
            if followedLists.contains("EasyList_SocialMedia") {
                socialList.text = "You're blocking social buttons"
            } else {
                socialList.text = "You're allowing social buttons"
            }
            
            followedLists = followedLists.filter { !alwaysFollowedLists.contains($0) } // Removing the lists that are always followed.
            if followedLists.count > 1 {
                mainList.text = "Main list: \(followedLists[0])"
                secondList.text = "Second list: \(followedLists[1])"
            } else if followedLists.count == 1 {
                mainList.text = "Main list: \(followedLists[0])"
                secondList.text = ""
            }
        } else {
            configurationState.text = "Adios doesn't block ads yet! Configure Adios first."
            mainList.text = ""
            secondList.text = ""
            socialList.text = ""
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


