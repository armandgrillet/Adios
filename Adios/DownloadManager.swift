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
        print("On applique")
        ListsManager.applyLists { () -> Void in
            self.userDefaults.setObject("Applying the rules...", forKey: "updateStatus")
            self.userDefaults.synchronize()
            
            if self.downloadsAppliedCallback != nil { // We're in background.
                print("We're in background")
                let lastUpdateWasForEasyList = NSUserDefaults.standardUserDefaults().boolForKey("lastUpdateWasForEasyList")
                if lastUpdateWasForEasyList == true { // We had updated EasyList before, today we updated the other lists, we reload ContentBlocker
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "lastUpdateWasForEasyList")
                    ContentBlockers.reloadContentBlocker(self.downloadsAppliedCallback!)
                } else {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "lastUpdateWasForEasyList")
                    ContentBlockers.reloadBaseContentBlocker(self.downloadsAppliedCallback!)
                }
            }
            
            ContentBlockers.reload({
                self.userDefaults.setObject("✅", forKey: "updateStatus")
                self.userDefaults.synchronize()
                }, badCompletion: {
                    self.userDefaults.setObject("❌", forKey: "updateStatus")
                    self.userDefaults.synchronize()
            })
        }
    }
    
    private func saveDownloads(rulesBaseContentBlocker: String?, rulesContentBlocker: String?, callback: (() -> Void)) {
        if rulesBaseContentBlocker != nil {
            var baseListWithoutWhitelist = ""
            if let lastBaseListCharacter = rulesBaseContentBlocker!.characters.last {
                if lastBaseListCharacter == "," { // Normal
                    baseListWithoutWhitelist = rulesBaseContentBlocker!
                }
            }
            if baseListWithoutWhitelist == "" {
                baseListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerOne\"}},"
            }
            NSUserDefaults.standardUserDefaults().setObject(baseListWithoutWhitelist, forKey: "baseListWithoutWhitelist")
        }
        
        if rulesContentBlocker != nil {
            var secondListWithoutWhitelist = ""
            if let lastSecondListCharacter = rulesContentBlocker!.characters.last {
                if lastSecondListCharacter == "," { // Normal
                    secondListWithoutWhitelist = rulesContentBlocker!
                }
            }
            if secondListWithoutWhitelist == "" {
                secondListWithoutWhitelist = "{\"trigger\":{\"url-filter\":\"armand.gr\"},\"action\":{\"type\": \"css-display-none\",\"selector\": \".testContentBlockerTwo\"}},"
            }
            
            NSUserDefaults.standardUserDefaults().setObject(secondListWithoutWhitelist, forKey: "secondListWithoutWhitelist")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        callback()
    }
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        userDefaults.setObject("Downloading \(list)...", forKey: "updateStatus")
        userDefaults.synchronize()
        print("Downloading \(list)")
        Alamofire
        .request(.GET, ListsManager.getUrlOfList(list))
        .responseString { _, _, result in
            if result.isSuccess {
                self.userDefaults.setObject("Processing \(list)...", forKey: "updateStatus")
                self.userDefaults.synchronize()
                print("\(list) done")
                
                if list == "AdiosList" || list == "EasyList" {
                    rulesBaseContentBlocker += result.value!
                } else {
                    rulesContentBlocker += result.value!
                }
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), rulesBaseContentBlocker: rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                } else {
                    if rulesBaseContentBlocker == "" {
                        self.saveDownloads(nil, rulesContentBlocker: rulesContentBlocker, callback: self.applyDownloads)
                    } else if rulesContentBlocker == "" {
                        self.saveDownloads(rulesBaseContentBlocker, rulesContentBlocker: nil, callback: self.applyDownloads)
                    } else {
                        self.saveDownloads(rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker, callback: self.applyDownloads)
                    }
                }
            } else {
                self.userDefaults.setObject("❌", forKey: "updateStatus")
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