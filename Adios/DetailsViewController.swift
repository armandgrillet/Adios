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
    @IBOutlet weak var socialSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    
    let onboardManager = OnboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        onboardManager.blockAdblockWarnings = blockAdblockWarningsSwitch.on
        onboardManager.social = blockAdblockWarningsSwitch.on
        onboardManager.privacy = privacySwitch.on
    }
    
    @IBAction func setBlockAdblockWarnings(sender: UISwitch) {
        onboardManager.blockAdblockWarnings = sender.on
    }
    
    @IBAction func setSocial(sender: UISwitch) {
        onboardManager.social = sender.on
    }
    
    @IBAction func setPrivacy(sender: UISwitch) {
        onboardManager.privacy = sender.on
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

