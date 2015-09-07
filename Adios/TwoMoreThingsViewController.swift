//
//  SocialViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import iAd
import UIKit

class TwoMoreThingsViewController: UIViewController {
    
    @IBOutlet weak var adBanner: ADBannerView!
    
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
            let alertController = UIAlertController(title: NSLocalizedString("Internet is required", comment: "Alert label to signal no internet connection"), message:
                NSLocalizedString("Adios needs to download some ad filters, please activate your data connection", comment: "Message explaining why we need an internet connection"), preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
    }
}
