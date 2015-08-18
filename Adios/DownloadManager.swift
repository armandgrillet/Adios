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
        let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
        let predicate = NSPredicate(format: "List == %@", listToMatch)
        let query = CKQuery(recordType: "Rules", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to compelte
        queryOperation.recordFetchedBlock = { (rule: CKRecord) in
            print(rule)
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
                    if nextLists != nil { // Other lists need to be downloaded
                       self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()))
                    } else { // All the list have been downloaded.
                        
                    }
                }
            }
        }
        
        publicDB.addOperation(queryOperation)
    }
    
    func updatesRulesForList(list: String, update: Int64) {
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            let currentUpdateAsNSNumber = userDefaults.objectForKey("\(list)Update") as! NSNumber?
            if let currentUpdate = currentUpdateAsNSNumber?.longLongValue {
                let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
                
                // Get all the records that have been created after the last update
                let predicate = NSPredicate(format: "(Update > \(currentUpdate)) AND (List == %@)", listToMatch)
                
                let queryCreatedRules = CKQuery(recordType: "Rules", predicate: predicate)
                let queryCreatedRulesOperation = CKQueryOperation(query: queryCreatedRules)
                queryCreatedRulesOperation.qualityOfService = .Utility // The user is waiting for the task to compelte
                queryCreatedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                    self.listsManager.addRuleToList(list, ruleAsRecord: rule)
                }
                queryCreatedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                    if error != nil {
                        print(error)
                    } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                        let newOperation = queryCreatedRulesOperation
                        newOperation.cursor = cursor!
                        self.publicDB.addOperation(newOperation)
                    }
                }
                
                let queryDeletedRules = CKQuery(recordType: "DeletedRules", predicate: predicate)
                let queryDeletedRulesOperation = CKQueryOperation(query: queryDeletedRules)
                queryDeletedRulesOperation.qualityOfService = .Utility // The user is waiting for the task to compelte
                queryDeletedRulesOperation.recordFetchedBlock = { (rule: CKRecord) in
                    self.listsManager.deleteRuleFromList(list, ruleAsRecord: rule)
                }
                queryCreatedRulesOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
                    if error != nil {
                        print(error)
                    } else if cursor != nil { // The cursor is not nil thus we still have some records to download
                        let newOperation = queryDeletedRulesOperation
                        newOperation.cursor = cursor!
                        self.publicDB.addOperation(newOperation)
                    }
                }
                
                queryDeletedRulesOperation.addDependency(queryCreatedRulesOperation) // We don't wanna remove rules that haven't been added yet.
                
                let queue = NSOperationQueue()
                queue.addOperations([queryCreatedRulesOperation, queryDeletedRulesOperation], waitUntilFinished: true)
                userDefaults.setObject(NSNumber(longLong: update), forKey: "\(list)Update")
                userDefaults.synchronize()
            }
            
        }
    }
    
    func downloadLists(lists: [String]) {
        downloadRulesFromList(lists[0], nextLists: Array(lists.dropFirst()))
    }
}