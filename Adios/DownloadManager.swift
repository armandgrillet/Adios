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
    var status = "Downloading..."
    let listsManager = ListsManager()
    
    func downloadRulesFromList(list: String, nextLists: [String]?) {
        var rules: [CKRecord] = []
        
        let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
        let predicate = NSPredicate(format: "List == %@", listToMatch)
        let query = CKQuery(recordType: "Rules", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to compelte
        queryOperation.recordFetchedBlock = { (rule: CKRecord) in
            rules.append(rule)
        }
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
               print(error)
            } else {
                if cursor != nil { // The cursor is not nil thus we still have some records to download
                    let newOperation = queryOperation
                    newOperation.cursor = cursor!
                    self.publicDB.addOperation(newOperation)
                } else { // List downloaded
                    self.listsManager.createList(list, records: rules)
                    if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                       self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()))
                    }
                }
            }
        }
        
        publicDB.addOperation(queryOperation)
    }
    
    func getNewRecords(update: Int) {
        var recordsCreated: [CKRecord] = []
        var recordsDeleted: [CKRecord] = []
        
            // Get all the records that have been created after the last update
            let predicate = NSPredicate(format: "Update > %@", update)
            let queryCreatedRules = CKQuery(recordType: "Rules", predicate: predicate)
            let queryCreatedRulesOperation = CKQueryOperation(query: queryCreatedRules)
            queryCreatedRulesOperation.qualityOfService = .Utility // The user is waiting for the task to compelte
            queryCreatedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                recordsCreated.append(rule)
            }
            queryCreatedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                if error != nil {
                    print(error)
                } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                    let newOperation = queryCreatedRulesOperation
                    newOperation.cursor = cursor!
                    self.publicDB.addOperation(newOperation)
                } else { // We have added the rules, now we remove the old ones.
                    let queryDeletedRules = CKQuery(recordType: "DeletedRules", predicate: predicate)
                    let queryDeletedRulesOperation = CKQueryOperation(query: queryDeletedRules)
                    queryDeletedRulesOperation.qualityOfService = .Utility // The user is waiting for the task to compelte
                    queryDeletedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                        recordsDeleted.append(rule)
                    }
                    queryDeletedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                        if error != nil {
                            print(error)
                        } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                            let newOperation = queryDeletedRulesOperation
                            newOperation.cursor = cursor!
                            self.publicDB.addOperation(newOperation)
                        } else {
                            // We've updated the list, now we can call the content blocker to update it.
                            print("done")
                            //            userDefaults.setInteger(update, forKey: "\(list)Update")
                            //            userDefaults.synchronize()
                            self.listsManager.updateRulesWithRecords(recordsCreated, recordsDeleted: recordsDeleted)
                        }
                    }
                    self.publicDB.addOperation(queryDeletedRulesOperation)
                }
            }
        
            publicDB.addOperation(queryCreatedRulesOperation)
    }
    
    func downloadLists(lists: [String]) {
        downloadRulesFromList(lists[0], nextLists: Array(lists.dropFirst()))
    }
}