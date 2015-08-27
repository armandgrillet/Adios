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
        if let followedLists = NSUserDefaults().arrayForKey("followedLists") {
            return followedLists as! [String]
        } else {
            return []
        }
    }
    
    public class func removeFollowedListsData() {
        if let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios") {
            if let groupPath = groupUrl.path {
                if NSFileManager().fileExistsAtPath(groupPath + "/baseList.json") {
                    try! NSFileManager().removeItemAtPath(groupPath + "/baseList.json")
                }
                if NSFileManager().fileExistsAtPath(groupPath + "/secondList.json") {
                    try! NSFileManager().removeItemAtPath(groupPath + "/secondList.json")
                }
            }
        }
    }
}