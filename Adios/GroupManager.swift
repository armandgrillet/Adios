//
//  GroupManager.swift
//  Adios
//
//  Created by Armand Grillet on 20/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class GroupManager {
    static func getFollowedLists() -> [String]? {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            return userDefaults.arrayForKey("followedLists") as! [String]?
        } else {
            return nil
        }
    }
}