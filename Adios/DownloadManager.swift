//
//  DownloadManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit
import MMWormhole
import SwiftyJSON

class DownloadManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios", optionalDirectory: "wormhole")
    
    func downloadRulesFromList(list: String, nextLists: [String]?, var rulesBaseContentBlocker: String, var rulesContentBlocker: String) {
        if list != "AdiosList" {
            wormhole.passMessageObject("Downloading \(list)...", identifier: "updateStatus")
        }
        
        let predicate = NSPredicate(format: "Name == %@", list)
        let query = CKQuery(recordType: "ListFiles", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to complete
        queryOperation.database = publicDB

        queryOperation.recordFetchedBlock = { (downloadedList: CKRecord) in
            if let rulesFile = downloadedList["File"] as? CKAsset {
                if list != "AdiosList" {
                    self.wormhole.passMessageObject("Processing \(list)...", identifier: "updateStatus")
                }
                if let content = NSFileManager.defaultManager().contentsAtPath(rulesFile.fileURL.path!) {
                    var rules = ""
                    let json = JSON(data: content)
                    for jsonRule in json.array! {
                        let rule = Rule(jsonRule: jsonRule)
                        rules += rule.toString()
                    }
                    if list == "AdiosList" || list == "EasyList" {
                        rulesBaseContentBlocker += rules
                    } else {
                        rulesContentBlocker += rules
                    }
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
                print(error)
            } else {
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), rulesBaseContentBlocker: rulesBaseContentBlocker, rulesContentBlocker: rulesContentBlocker)
                } else { // Everything has been downloaded, we're setting the current update user default and run the content blockers manager
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        
                        let fileManager = NSFileManager()
                        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
                        let sharedContainerPathLocation = groupUrl?.path
                        
                        var baseList = ""
                        if rulesBaseContentBlocker.characters.last! == "," {
                            baseList = rulesBaseContentBlocker.substringToIndex(rulesBaseContentBlocker.endIndex.predecessor()) + "]"
                        }
                        let bastListPath = sharedContainerPathLocation! + "/baseList.json"
                        if !fileManager.fileExistsAtPath(bastListPath) {
                            fileManager.createFileAtPath(bastListPath, contents: baseList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
                        } else {
                            try! baseList.writeToFile(bastListPath, atomically: true, encoding: NSUTF8StringEncoding)
                        }
                        
                        var secondList = ""
                        if rulesContentBlocker.characters.last! == "," {
                            secondList = rulesContentBlocker.substringToIndex(rulesContentBlocker.endIndex.predecessor()) + "]"
                        }
                        let secondListPath = sharedContainerPathLocation! + "/secondList.json"
                        if !fileManager.fileExistsAtPath(secondListPath) {
                            fileManager.createFileAtPath(secondListPath, contents: secondList.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
                        } else {
                            try! secondList.writeToFile(secondListPath, atomically: true, encoding: NSUTF8StringEncoding)
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            print("Everything done")
                            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.wormhole.passMessageObject("Applying the rules...", identifier: "updateStatus")
                            ContentBlockers.reload({self.wormhole.passMessageObject("✅", identifier: "updateStatus")}, badCompletion: {self.wormhole.passMessageObject("❌", identifier: "updateStatus")})
                            //let subscriptionsManager = SubscriptionsManager()
                            // subscriptionsManager.subscribeToUpdates()
                        }
                    }
                }
            }
        }
        publicDB.addOperation(queryOperation)
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