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
            print(userDefaults.stringForKey("testAgain"))
        } else {
            print("Impossible de se connecter au groupe")
        }
    }
    
    @IBAction func createFile(sender: UIButton) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            userDefaults.setObject("{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\":\"css-display-none\",\"selector\":\".testContentBlockerFour\"}},", forKey: "testAgain")
        }
    }
    
    @IBAction func update(sender: UIButton) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                print("Le base passe")
            } else {
                print(error)
            }
        }

    }
}