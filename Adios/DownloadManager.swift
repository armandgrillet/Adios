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

class DownloadManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios", optionalDirectory: "wormhole")
    
    func downloadRulesFromList(list: String, nextLists: [String]?) {
        wormhole.passMessageObject("Downloading \(list)", identifier: "updateStatus")
        let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
        let predicate = NSPredicate(format: "List == %@", listToMatch)
        let query = CKQuery(recordType: "Rulesets", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to complete
        queryOperation.recordFetchedBlock = { (ruleset: CKRecord) in
            ListsManager.addList(ruleset.recordID.recordName, listContent: ruleset["Rules"] as! [String])
        }
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
                print(error?.localizedFailureReason)
            } else {
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()))
                } else { // The last list has been processed
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    ContentBlockersManager.updateContentBlockers()
                    // We set the subscription if it hasn't been done before
                    let subscriptionsManager = SubscriptionsManager()
                    subscriptionsManager.subscribeToUpdates()
                }
            }
        }
        publicDB.addOperation(queryOperation)
    }
    
    func updateRules() {
        
    }
    
    func downloadFollowedLists() {
        downloadRulesFromList(ListsManager.getFollowedLists()[0], nextLists: Array(ListsManager.getFollowedLists().dropFirst()))
    }
}