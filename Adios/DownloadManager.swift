//
//  DownloadManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit

class DownloadManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let listsManager = ListsManager()
    
    func downloadRulesFromList(list: String, nextLists: [String]?) {
        if list != "AdiosList" {
            NSUserDefaults.standardUserDefaults().setObject("Downloading \(list)", forKey: "updateStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        var rules: [CKRecord] = []
        
        let queue = NSOperationQueue()
        
        let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
        let predicate = NSPredicate(format: "List == %@", listToMatch)
        let query = CKQuery(recordType: "Rules", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to complete
        queryOperation.recordFetchedBlock = { (rule: CKRecord) in
            rules.append(rule)
        }
        queryOperation.database = publicDB
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
               print(error)
            } else {
                if cursor != nil { // The cursor is not nil thus we still have some records to download
                    let newOperation = queryOperation
                    newOperation.cursor = cursor!
                    queue.addOperation(newOperation)
                } else { // List downloaded
                    self.listsManager.createList(list, records: rules)
                    if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                       self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()))
                    } else { // Everything has been downloaded, we're setting the current update user default and run the content blockers manager
                        self.listsManager.applyLists()
                        let pr = NSPredicate(format: "recordID = %@", CKRecordID(recordName: "TheOneAndOnly"))
                        let queryGetUpdate = CKQuery(recordType: "Updates", predicate: pr)
                        self.publicDB.performQuery(queryGetUpdate, inZoneWithID: nil) { results, error in
                            if error != nil {
                                print(error)
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
    
    func getNewRecordsManually() {
        NSUserDefaults.standardUserDefaults().setObject("Checking if an update is available", forKey: "updateStatus")
        NSUserDefaults.standardUserDefaults().synchronize()
        let pr = NSPredicate(format: "recordID = %@", CKRecordID(recordName: "TheOneAndOnly"))
        let queryGetUpdate = CKQuery(recordType: "Updates", predicate: pr)
        self.publicDB.performQuery(queryGetUpdate, inZoneWithID: nil) { results, error in
            if error != nil {
                print(error)
            } else if let theOneAndOnlyUpdate = results?.first { // We downloaded all the lists we want, we set the current update and call it a day.
                let cloudUpdate = theOneAndOnlyUpdate["Version"]! as! Int
                self.getNewRecords(cloudUpdate)
            }
        }
    }
    
    func getNewRecords(update: Int) {
        var currentUpdate = NSUserDefaults.standardUserDefaults().integerForKey("currentUpdate")
        if currentUpdate < 0 {
            currentUpdate = 0
        }
        
        print("Current update: \(currentUpdate) and last update: \(update)")
        
        if update > currentUpdate {
            NSUserDefaults.standardUserDefaults().setObject("Updating your lists", forKey: "updateStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
            let queue = NSOperationQueue()
            let followedLists = listsManager.getFollowedLists()
            var referenceToFollowedLists: [CKReference] = []
            for list in followedLists {
                referenceToFollowedLists.append(CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf))
            }
            
            var recordsCreated: [CKRecord] = []
            var recordsDeleted: [CKRecord] = []
            
            // Get all the records that have been created after the last update
            let createdRulesPredicate = NSPredicate(format: "(Update > \(currentUpdate)) AND (List IN %@)", referenceToFollowedLists)
            let queryCreatedRules = CKQuery(recordType: "Rules", predicate: createdRulesPredicate)
            let queryCreatedRulesOperation = CKQueryOperation(query: queryCreatedRules)
            queryCreatedRulesOperation.qualityOfService = .Utility // The user is waiting for the task to complete
            queryCreatedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                recordsCreated.append(rule)
            }
            queryCreatedRulesOperation.database = publicDB
            queryCreatedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                if error != nil {
                    print(error)
                } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                    let newCreationOperation = queryCreatedRulesOperation
                    newCreationOperation.cursor = cursor!
                    queue.addOperation(newCreationOperation)
                }
            }
            
            let deletedRulesPredicate = NSPredicate(format: "(CreationUpdate <= \(currentUpdate)) AND (Update > \(currentUpdate)) AND (List IN %@)", referenceToFollowedLists)
            let queryDeletedRules = CKQuery(recordType: "DeletedRules", predicate: deletedRulesPredicate)
            let queryDeletedRulesOperation = CKQueryOperation(query: queryDeletedRules)
            queryDeletedRulesOperation.addDependency(queryCreatedRulesOperation)
            queryDeletedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                recordsDeleted.append(rule)
            }
            queryDeletedRulesOperation.database = publicDB
            queryDeletedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                if error != nil {
                    print(error)
                } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                    let newDeletionOperation = queryDeletedRulesOperation
                    newDeletionOperation.cursor = cursor!
                    queue.addOperation(newDeletionOperation)
                } else {
                    // We've updated the list, now we can call the content blocker to update it.
                    NSUserDefaults.standardUserDefaults().setInteger(update, forKey: "currentUpdate")
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdateTimestamp")
                    NSUserDefaults.standardUserDefaults().setObject("✅", forKey: "updateStatus")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.listsManager.updateRulesWithRecords(recordsCreated, recordsDeleted: recordsDeleted)
                }
            }
            queue.addOperations([queryCreatedRulesOperation, queryDeletedRulesOperation], waitUntilFinished: true)
        } else {
            NSUserDefaults.standardUserDefaults().setObject("✅", forKey: "updateStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func downloadFollowedLists() {
        downloadRulesFromList(listsManager.getFollowedLists()[0], nextLists: Array(listsManager.getFollowedLists().dropFirst()))
    }
}