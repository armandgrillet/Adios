//
//  ListsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit

public class ListsManager {
    public class func applyLists(completion: (() -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var whitelistAssembled = ""
            if let whitelist = NSUserDefaults.standardUserDefaults().arrayForKey("whitelist") as! [String]? {
                for domain in whitelist {
                    whitelistAssembled += IgnoringRule(domain: domain).toString()
                }
            }
            var baseListWithoutWhitelist = ""
            if let userDefaultsBaseListWithoutWhitelist = NSUserDefaults.standardUserDefaults().stringForKey("baseListWithoutWhitelist") {
                if userDefaultsBaseListWithoutWhitelist.characters.last == "," { // Normal
                    baseListWithoutWhitelist = userDefaultsBaseListWithoutWhitelist
                }
            }
            var secondListWithoutWhitelist = ""
            if let userDefaultsSecondListWithoutWhitelist = NSUserDefaults.standardUserDefaults().stringForKey("secondListWithoutWhitelist") {
                if userDefaultsSecondListWithoutWhitelist.characters.last == "," { // Normal
                    secondListWithoutWhitelist = userDefaultsSecondListWithoutWhitelist
                }
            }
            
            
            let fileManager = NSFileManager()
            let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
            let sharedContainerPathLocation = groupUrl?.path

            if baseListWithoutWhitelist == "" {
                baseListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerTwo\"}},"
            }
            
            var baseList = baseListWithoutWhitelist + whitelistAssembled
            baseList = "[" + baseList.substringToIndex(baseList.endIndex.predecessor()) + "]" // Removing the last coma
            let baseListPath = sharedContainerPathLocation! + "/baseList.json"
            if !fileManager.fileExistsAtPath(baseListPath) {
                fileManager.createFileAtPath(baseListPath, contents: baseList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
            } else {
                try! baseList.writeToFile(baseListPath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            
            
            if secondListWithoutWhitelist == "" {
                secondListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerTwo\"}},"
            }
            
            var secondList = secondListWithoutWhitelist + whitelistAssembled
            secondList = "[" + secondList.substringToIndex(secondList.endIndex.predecessor()) + "]" // Removing the last coma
            let secondListPath = sharedContainerPathLocation! + "/secondList.json"
            if !fileManager.fileExistsAtPath(secondListPath) {
                fileManager.createFileAtPath(secondListPath, contents: secondList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
            } else {
                try! secondList.writeToFile(secondListPath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            dispatch_async(dispatch_get_main_queue()) {
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
                NSUserDefaults.standardUserDefaults().synchronize()
                completion()
            }
        }
    }
    
    public class func getFollowedLists() -> [String] {
        if let followedLists = NSUserDefaults.standardUserDefaults().arrayForKey("followedLists") {
            return followedLists as! [String]
        } else {
            return []
        }
    }
    
    public class func getRealListFromCountry(country: String) -> String? {
        switch country {
        case "Arabic region":
            return "EasyList_Arabic"
        case "Bulgaria":
            return "EasyList_Bulgaria"
        case "China":
            return "EasyList_China"
        case "Czech and Slovak Rep.":
            return "EasyList_Czechoslovakia"
        case "Denmark":
            return "List_Danish"
        case "France":
            return "EasyList_France"
        case "Estonia":
            return "List_Estonia"
        case "Germany":
            return "EasyList_Germany"
        case "Greece":
            return "EasyList_Greece"
        case "Hungary":
            return "List_Hungary"
        case "Iceland":
            return "EasyList_Iceland"
        case "Indonesia":
            return "EasyList_Indonesia"
        case "Italy":
            return "EasyList_Italy"
        case "Israel":
            return "EasyList_Hebrew"
        case "Japan":
            return "List_Japan"
        case "Latvia":
            return "EasyList_Latvia"
        case "Netherlands":
            return "EasyList_Dutch"
        case "Poland":
            return "EasyList_Poland"
        case "Romania":
            return "EasyList_Romania"
        case "Russia":
            return "EasyList_Russia"
        case "United Kingdom":
            return "List_England"
        case "U.S.A":
            return "EasyList"
        default:
            return nil
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
    
    public class func getUrlOfList(list: String) -> String {
        return "https://gitlab.com/ArmandGrillet/lists/raw/master/" + list + ".txt"
    }
}