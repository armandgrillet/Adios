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
import MMWormhole
import SwiftyJSON

class DownloadManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios", optionalDirectory: "wormhole")
    
    func applyDownloads(rulesBaseContentBlocker: String, rulesContentBlocker: String) {
        ListsManager.applyLists(rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker) { () -> Void in
            self.wormhole.passMessageObject("Applying the rules...", identifier: "updateStatus")
            ContentBlockers.reload({self.wormhole.passMessageObject("✅", identifier: "updateStatus")}, badCompletion: {self.wormhole.passMessageObject("❌", identifier: "updateStatus")})
            //let subscriptionsManager = SubscriptionsManager()
            // subscriptionsManager.subscribeToUpdates()
        }
    }
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        if list != "AdiosList" {
            wormhole.passMessageObject("Working on \(list)...", identifier: "updateStatus")
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
                self.wormhole.passMessageObject("Error with \(list)...", identifier: "updateStatus")
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
            downloadRulesFromList(followedLists[0], nextLists: Array(followedLists.dropFirst()), rulesBaseContentBlocker: "[", rulesContentBlocker: "[")
        }
        
    }
}