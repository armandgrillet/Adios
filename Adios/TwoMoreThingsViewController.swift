//
//  SocialViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class TwoMoreThingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openSettingsActivateBackgroundUpdates(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if Reachability.isConnectedToNetwork() {
            return true
        } else {
            let alertController = UIAlertController(title: "Internet is required", message:
                "Adios needs to download some ad filters for you, please activate your data connection", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
    }
}
