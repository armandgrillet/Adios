//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit
import SafariServices

public class ListsManager {
    
    public class func getFollowedLists() -> [String] {
        if let followedLists = NSUserDefaults(suiteName: "group.AG.Adios")!.arrayForKey("followedLists") {
            return followedLists as! [String]
        } else {
            return []
        }
    }
    
    public class func setList(list: String, value: String) {
        if getFollowedLists().indexOf(list) > -1 {
            print("\(list): \(value.characters.count)")
            if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                print("On la set tranquillement")
                userDefaults.setObject(value, forKey: list)
                userDefaults.synchronize()
            }
        }
    }
}