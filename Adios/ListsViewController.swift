//
//  ListsViewController.swift
//  Adios
//
//  Created by Armand Grillet on 20/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {
    
    @IBOutlet weak var lists: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var text = ""
        
        let followedLists = ListsManager.getFollowedLists()
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            for list in followedLists {
                if let displayedList = userDefaults.stringForKey("\(list)") {
                    text += displayedList
                }
            }
        }
        lists.text = text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}