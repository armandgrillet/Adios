//
//  DownloadManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Alamofire
import CloudKit
import Foundation

class DownloadManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func applyDownloads(rulesBaseContentBlocker: String, rulesContentBlocker: String) {
        ListsManager.applyLists(rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker) { () -> Void in
            self.userDefaults.setObject("Applying the rules...", forKey: "updateStatus")
            self.userDefaults.synchronize()
            
            ContentBlockers.reload({
                self.userDefaults.setObject("✅", forKey: "updateStatus")
                self.userDefaults.synchronize()
            }, badCompletion: {
                self.userDefaults.setObject("❌", forKey: "updateStatus")
                self.userDefaults.synchronize()
            })
            //let subscriptionsManager = SubscriptionsManager()
            // subscriptionsManager.subscribeToUpdates()
        }
    }
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        if list != "AdiosList" {
            userDefaults.setObject("Working on \(list)...", forKey: "updateStatus")
            userDefaults.synchronize()
        }
        
        Alamofire
        .request(.GET, ListsManager.getUrlOfList(list)!)
        .responseString { _, _, result in
            if result.isSuccess {
                var rules = ""
                var downloadedList = result.value!.componentsSeparatedByString("\n")
                downloadedList.removeFirst() // Remove the [AdBlock] stuff.
                for index in 0..<downloadedList.count {
                    let line = downloadedList[index]
                    if Parser.isReadableRule(line) {
                        for rule in Parser.getRulesFromLine(line) {
                            rules += rule
                        }
                    }
                }
                print("\(list) done")
                
                if list == "AdiosList" || list == "EasyList" {
                    rulesBaseContentBlocker += rules
                } else {
                    rulesContentBlocker += rules
                }
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), rulesBaseContentBlocker: rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                } else {
                    self.applyDownloads(rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                }
            } else {
                print("Fail with \(list)")
                self.userDefaults.setObject("Error with \(list)...", forKey: "updateStatus")
                self.userDefaults.synchronize()
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), rulesBaseContentBlocker: rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                } else {
                    self.applyDownloads(rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                }
            }
        }
    }
    
    func updateRules() {
        
    }
    
    func downloadFollowedLists() {
        let followedLists = ListsManager.getFollowedLists()
        if followedLists.count > 0 {
            downloadRulesFromList(followedLists[0], nextLists: Array(followedLists.dropFirst()), rulesBaseContentBlocker: "", rulesContentBlocker: "")
        }
        
    }
}