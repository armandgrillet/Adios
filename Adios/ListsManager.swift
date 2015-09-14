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
    
    public class func getUrlOfList(list: String) -> String? {
        switch list {
        case "EasyList_Arabic":
            return "https://liste-ar-adblock.googlecode.com/hg/Liste_AR.txt"
        case "EasyList_Bulgaria":
            return "http://stanev.org/abp/adblock_bg.txt"
        case "EasyList_China":
            return "https://easylist-downloads.adblockplus.org/easylistchina.txt"
        case "EasyList_Czechoslovakia":
            return "https://adblock-czechoslovaklist.googlecode.com/svn/filters.txt"
        case "List_Danish":
            return "http://adblock.schack.dk/block.txt"
        case "EasyList_France":
            return "https://easylist-downloads.adblockplus.org/liste_fr.txt"
        case "List_Estonia":
            return "http://gurud.ee/ab.txt"
        case "EasyList_Germany":
            return "https://easylist-downloads.adblockplus.org/easylistgermany.txt"
        case "EasyList_Greece":
            return "http://www.void.gr/kargig/void-gr-filters.txt"
        case "List_Hungary":
            return "https://raw.githubusercontent.com/szpeter80/hufilter/master/hufilter.txt"
        case "EasyList_Iceland":
            return "http://adblock.gardar.net/is.abp.txt"
        case "EasyList_Indonesia":
            return "https://indonesianadblockrules.googlecode.com/hg/subscriptions/abpindo.txt"
        case "EasyList_Italy":
            return "https://easylist-downloads.adblockplus.org/easylistitaly.txt"
        case "EasyList_Hebrew":
            return "https://raw.githubusercontent.com/AdBlockPlusIsrael/EasyListHebrew/master/EasyListHebrew.txt"
        case "List_Japan":
            return "https://raw.githubusercontent.com/k2jp/abp-japanese-filters/master/abpjf.txt"
        case "EasyList_Latvia":
            return "https://notabug.org/latvian-list/adblock-latvian/raw/master/lists/latvian-list.txt"
        case "EasyList_Dutch":
            return "https://easylist-downloads.adblockplus.org/easylistdutch.txt"
        case "EasyList_Poland":
            return "https://raw.githubusercontent.com/adblockpolska/Adblock_PL_List/master/adblock_polska.txt"
        case "EasyList_Romania":
            return "http://www.zoso.ro/rolist"
        case "EasyList_Russia":
            return "https://easylist-downloads.adblockplus.org/advblock.txt"
        case "List_England":
            return "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=0&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext"
        case "EasyList":
            return "https://easylist-downloads.adblockplus.org/easylist.txt"
        case "EasyPrivacy":
            return "https://easylist-downloads.adblockplus.org/easyprivacy.txt"
        case "AdblockWarningRemoval":
            return "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
        case "EasyList_SocialMedia":
            return "https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt"
        default:
            return nil
        }
    }
}