//
//  DetailsViewController.swift
//  Adios
//
//  Created by Armand Grillet on 23/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var blockAdblockWarningsSwitch: UISwitch!
    @IBOutlet weak var antisocialSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    
    let onboardManager = OnboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blockAdblockWarningsSwitch.on = onboardManager.blockAdblockWarnings
        antisocialSwitch.on = onboardManager.antisocial
        privacySwitch.on = onboardManager.privacy
    }
    
    @IBAction func setBlockAdblockWarnings(sender: UISwitch) {
        onboardManager.blockAdblockWarnings = sender.on
    }
    
    @IBAction func setAntisocial(sender: UISwitch) {
        onboardManager.antisocial = sender.on
    }
    
    @IBAction func setPrivacy(sender: UISwitch) {
        onboardManager.privacy = sender.on
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

