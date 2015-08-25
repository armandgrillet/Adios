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
    let listsManager = ListsManager()
    
    func downloadRulesFromList(list: String, nextLists: [String]?, unachievedRules: [CKRecord], cursor: CKQueryCursor?) {
        if list != "AdiosList" {
            wormhole.passMessageObject("Downloading \(list)", identifier: "updateStatus")
        }
        
        print(list)
        
        var rules = unachievedRules
        
        let queue = NSOperationQueue()
        
        
        
        let queryOperation = CKQueryOperation()
        if cursor != nil {
            queryOperation.cursor = cursor
        } else {
            let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
            let predicate = NSPredicate(format: "List == %@", listToMatch)
            let query = CKQuery(recordType: "Rulesets", predicate: predicate)
            queryOperation.query = query
        }
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to complete
        queryOperation.database = publicDB
        
        
        queryOperation.recordFetchedBlock = { (ruleset: CKRecord) in
            let rulesetRules = ruleset["Rules"] as! String
            let newRules = rulesetRules.componentsSeparatedByString("CKPByADIOS") as [String]
            for rule in newRules {
                print(rule)
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
                print(error?.localizedFailureReason)
            } else {
                if cursor != nil { // The cursor is not nil thus we still have some records to download
                    print("Not done for \(list)")
                    self.downloadRulesFromList(list, nextLists: nextLists, unachievedRules: rules, cursor: cursor)
                } else { // List downloaded
                    self.listsManager.createList(list, records: rules)
                    if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                        self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()), unachievedRules: rules, cursor: nil)
                    } else { // Everything has been downloaded, we're setting the current update user default and run the content blockers manager
                        print("Everything done")
                        self.listsManager.applyLists()
                        let pr = NSPredicate(format: "recordID = %@", CKRecordID(recordName: "TheOneAndOnly"))
                        let queryGetUpdate = CKQuery(recordType: "Updates", predicate: pr)
                        self.publicDB.performQuery(queryGetUpdate, inZoneWithID: nil) { results, error in
                            if error != nil {
                                print(error?.localizedFailureReason)
                            } else { // We downloaded all the lists we want, we set the current update and call it a day.
                                if let theOneAndOnlyUpdate = results?.first {
                                    let currentUpdate = theOneAndOnlyUpdate["Version"]! as! Int
                                    NSUserDefaults.standardUserDefaults().setInteger(currentUpdate, forKey: "currentUpdate")
                                    print("Liste updated and currentUpdate now \(currentUpdate)")
                                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    // We set the subscription if it hasn't been done before
                                    let subscriptionsManager = SubscriptionsManager()
                                    subscriptionsManager.subscribeToUpdates()
                                }
                            }
                        }
                    }
                }
            }
        }
        queue.addOperation(queryOperation)
    }
    
    func updateRules() {
        
    }
    
    func downloadFollowedLists() {
        downloadRulesFromList(listsManager.getFollowedLists()[0], nextLists: Array(listsManager.getFollowedLists().dropFirst()), unachievedRules: [], cursor: nil)
    }
}