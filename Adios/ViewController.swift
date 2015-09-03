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

    @IBAction func printWhitelist(sender: UIButton) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let ignoredList = userDefaults.arrayForKey("whitelist") as! [String]? {
                for domain in ignoredList {
                    print(domain)
                }
            }
        }
    }
    
    @IBAction func seeLogs(sender: UIButton) {
        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
        let sharedContainerPathLocation = groupUrl?.path
        let fileManager = NSFileManager()
        
        let filePath = sharedContainerPathLocation! + "/baseList.json"
        if let content = fileManager.contentsAtPath(filePath) {
            let list = String(data: content, encoding: NSUTF8StringEncoding)
            print(list!)
        }
    }
    
    @IBAction func createFile(sender: UIButton) {
//        let path = NSBundle.mainBundle().pathForResource("list", ofType: "json")
//        let data = NSData(contentsOfFile: path!)
//        if (data != nil) {
//            let json = JSON(data: data!)
//            for jsonRule in json.array! {
//                let rule = Rule(jsonRule: jsonRule)
//                print(rule.toString())
//            }
//        }
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let adiosList = userDefaults.stringForKey("testAgain") {
                print(adiosList)
            }
        }
    }
    
    @IBAction func update(sender: UIButton) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                print("Le base passe")
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if otherError == nil {
                        print("Le CB passe")
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