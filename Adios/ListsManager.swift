//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

public class ListsManager {
    public class func addList(listName: String, listContent: [String]) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            userDefaults.setObject(listContent, forKey: listName)
            userDefaults.synchronize()
        }

    }
    
    public class func getFollowedLists() -> [String] {
        if let followedLists = NSUserDefaults(suiteName: "group.AG.Adios")!.arrayForKey("followedLists") {
            return followedLists as! [String]
        } else {
            return []
        }
    }
    
    public class func printLists() {
        let followedLists = getFollowedLists()
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            for list in followedLists {
                if let displayedList = userDefaults.arrayForKey("\(list)Block") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)BlockCookies") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)CSSDisplayNone") as! [String]? {
                    print(displayedList)
                }
                if let displayedList = userDefaults.arrayForKey("\(list)IgnorePreviousRules") as! [String]? {
                    print(displayedList)
                }
            }
        }
    }
    
    public class func setFollowedLists(newFollowedLists: [String]) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let followedLists = userDefaults.arrayForKey("followedLists") {
                for list in followedLists {
                    userDefaults.removeObjectForKey("\(list)Block")
                    userDefaults.removeObjectForKey("\(list)BlockCookies")
                    userDefaults.removeObjectForKey("\(list)CSSDisplayNone")
                    userDefaults.removeObjectForKey("\(list)IgnorePreviousRules")
                }
                userDefaults.removeObjectForKey("followedLists")
            }
            userDefaults.setObject(newFollowedLists, forKey: "followedLists")
        }
    }
}