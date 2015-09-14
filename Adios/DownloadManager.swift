//
//  DownloadManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Alamofire
import Foundation

class DownloadManager {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func applyDownloads() {
        ListsManager.applyLists { () -> Void in
            self.userDefaults.setObject("Applying the rules...", forKey: "updateStatus")
            self.userDefaults.synchronize()
            ContentBlockers.reload({ (success: Bool) -> Void in
                if success {
                    self.userDefaults.setObject("success", forKey: "updateStatus")
                } else {
                    self.userDefaults.setObject("fail", forKey: "updateStatus")
                }
                self.userDefaults.synchronize()
            })
        }
    }
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        print("Downloading \(list)")
        Alamofire
        .request(.GET, ListsManager.getUrlOfList(list)!)
        .responseString { _, _, result in
            if result.isSuccess {
                var rules = ""
                var downloadedList = result.value!.componentsSeparatedByString("\n")
                downloadedList.removeFirst() // Remove the [AdBlock] stuff.
                
                for rule in Parser.parseRules(downloadedList) {
                    rules += rule
                }
                
                if list == "EasyList" {
                    rulesBaseContentBlocker += rules
                } else {
                    rulesContentBlocker += rules
                }
                
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), rulesBaseContentBlocker: rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                } else {
                    if rulesBaseContentBlocker != "" {
                        var baseListWithoutWhitelist = ""
                        if let lastBaseListCharacter = rulesBaseContentBlocker.characters.last {
                            if lastBaseListCharacter == "," { // Normal
                                baseListWithoutWhitelist = rulesBaseContentBlocker
                            }
                        }
                        if baseListWithoutWhitelist == "" {
                            baseListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerOne\"}},"
                        }
                        NSUserDefaults.standardUserDefaults().setObject(baseListWithoutWhitelist, forKey: "baseListWithoutWhitelist")
                    }
                    
                    if rulesContentBlocker != "" {
                        var secondListWithoutWhitelist = ""
                        if let lastSecondListCharacter = rulesContentBlocker.characters.last {
                            if lastSecondListCharacter == "," { // Normal
                                secondListWithoutWhitelist = rulesContentBlocker
                            }
                        }
                        if secondListWithoutWhitelist == "" {
                            secondListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerTwo\"}},"
                        }
                        
                        NSUserDefaults.standardUserDefaults().setObject(secondListWithoutWhitelist, forKey: "secondListWithoutWhitelist")
                    }
                    
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.applyDownloads()
                }
            } else {
                self.userDefaults.setObject("fail", forKey: "updateStatus")
                self.userDefaults.synchronize()
            }
        }
    }
    
    func downloadLists(lists: [String]) {
        if lists.count > 0 {
            userDefaults.setObject("Downloading the lists...", forKey: "updateStatus")
            userDefaults.synchronize()
            downloadRulesFromList(lists[0], nextLists: Array(lists.dropFirst()), rulesBaseContentBlocker: "", rulesContentBlocker: "")
        }
    }
    
    func downloadFollowedLists() {
        downloadLists(ListsManager.getFollowedLists())
    }
}