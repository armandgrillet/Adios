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
    var downloadsAppliedCallback: ((UIBackgroundFetchResult) -> Void)?
    
    func applyDownloads() {
        ListsManager.applyLists { () -> Void in
            self.userDefaults.setObject("Applying the rules...", forKey: "updateStatus")
            self.userDefaults.synchronize()
            if self.downloadsAppliedCallback != nil { // We're in background.
                let lastUpdateWasForEasyList = NSUserDefaults.standardUserDefaults().boolForKey("lastUpdateWasForEasyList")
                
                var contentBlockerToUpdate = ""
                if lastUpdateWasForEasyList == false {
                    if ListsManager.getFollowedLists().contains("EasyList") { // We have EasyList
                        self.userDefaults.setBool(true, forKey: "lastUpdateWasForEasyList")
                        contentBlockerToUpdate = "AG.Adios.BaseContentBlocker"
                    } else {
                        contentBlockerToUpdate = "AG.Adios.ContentBlocker"
                    }
                } else {
                    if ListsManager.getFollowedLists() != ["EasyList"] { // Not just EasyList
                        self.userDefaults.setBool(false, forKey: "lastUpdateWasForEasyList")
                        contentBlockerToUpdate = "AG.Adios.ContentBlocker"
                    } else {
                        contentBlockerToUpdate = "AG.Adios.BaseContentBlocker"
                    }
                }
                self.userDefaults.synchronize()
                ContentBlockers.reloadOneContentBlocker(contentBlockerToUpdate, callback: self.downloadsAppliedCallback!)
            } else {
                ContentBlockers.reload({ (success: Bool) -> Void in
                    print(success)
                    if success {
                        self.userDefaults.setObject("success", forKey: "updateStatus")
                    } else {
                        self.userDefaults.setObject("fail", forKey: "updateStatus")
                    }
                    self.userDefaults.synchronize()
                })
            }
        }
    }
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        userDefaults.setObject("Downloading \(list)...", forKey: "updateStatus")
        userDefaults.synchronize()
        Alamofire
        .request(.GET, ListsManager.getUrlOfList(list))
        .responseString { _, _, result in
            if result.isSuccess {
                if list == "EasyList" {
                    rulesBaseContentBlocker += result.value!
                } else {
                    rulesContentBlocker += result.value!
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
    
    func downloadLists(lists: [String], callback: ((UIBackgroundFetchResult) -> Void)?) {
        if lists.count > 0 {
            if callback != nil {
                downloadsAppliedCallback = callback!
            }
            downloadRulesFromList(lists[0], nextLists: Array(lists.dropFirst()), rulesBaseContentBlocker: "", rulesContentBlocker: "")
        }
    }
    
    func downloadFollowedLists() {
        downloadLists(ListsManager.getFollowedLists(), callback: nil)
    }
}