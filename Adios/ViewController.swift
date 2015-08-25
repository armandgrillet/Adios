//
//  ViewController.swift
//  Adios
//
//  Created by Armand Grillet on 09/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var followed: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            followed.text = userDefaults.arrayForKey("followedLists")?.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func seeLogs(sender: UIButton) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let groupDebugRules = userDefaults.stringForKey("debugRules") {
                print(groupDebugRules)
            } else {
                print("Debugrules doesn't exist")
            }
        } else {
            print("Impossible de se connecter au groupe")
        }
    }
    
    @IBAction func update(sender: UIButton) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                print("Le base passe")
                NSUserDefaults.standardUserDefaults().setObject("Applying user's content blocker", forKey: "updateStatus")
                NSUserDefaults.standardUserDefaults().synchronize()
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if error == nil {
                        print("Listes appliquees")
                    } else {
                        print(otherError)
                    }
                }
            } else {
                print(error)
            }
        }

    }
}