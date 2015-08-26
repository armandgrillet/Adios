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
    
    func downloadRulesFromList(list: String, nextLists: [String]?) {
        if list != "AdiosList" {
            wormhole.passMessageObject("Downloading \(list)", identifier: "updateStatus")
        }
        
        let queue = NSOperationQueue()
        let predicate = NSPredicate(format: "Name == %@", list)
        let query = CKQuery(recordType: "ListFiles", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.qualityOfService = .UserInitiated // The user is waiting for the task to complete
        queryOperation.database = publicDB
        
        var rules = [String]()
        queryOperation.recordFetchedBlock = { (downloadedList: CKRecord) in
            if let rulesFile = downloadedList["File"] as? CKAsset {
                self.wormhole.passMessageObject("Processing \(list)", identifier: "updateStatus")
                if let content = NSFileManager.defaultManager().contentsAtPath(rulesFile.fileURL.path!) {
                    let json = JSON(data: content)
                    for jsonRule in json.array! {
                        let rule = Rule(jsonRule: jsonRule)
                        rules.append(rule.toString())
                    }
                    print("\(list): \(rules.count)")
                    if list == "AdiosList" {
                        print(rules.description)
                    }
                    if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                        print("On la set tranquillement")
                        userDefaults.setObject(rules, forKey: list)
                    }
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor : CKQueryCursor?, error : NSError?) in
            if error != nil {
                print(error?.localizedFailureReason)
            } else {
                if nextLists != nil && nextLists!.count > 0 { // Other lists need to be downloaded
                    print("On a d'autres listes")
                    self.downloadRulesFromList(nextLists![0], nextLists: Array(nextLists!.dropFirst()))
                } else { // Everything has been downloaded, we're setting the current update user default and run the content blockers manager
                    print("Everything done")
                    ContentBlockers.reload({self.wormhole.passMessageObject("✅", identifier: "updateStatus")}, badCompletion: {self.wormhole.passMessageObject("❌", identifier: "updateStatus")})
                    //let subscriptionsManager = SubscriptionsManager()
                    // subscriptionsManager.subscribeToUpdates()
                }
            }
        }
        queue.addOperation(queryOperation)
    }
    
    func updateRules() {
        
    }
    
    func downloadFollowedLists() {
        if let followedLists = NSUserDefaults(suiteName: "group.AG.Adios")!.arrayForKey("followedLists") as! [String]? {
            downloadRulesFromList(followedLists[0], nextLists: Array(followedLists.dropFirst()))
        } else {
            print("problem")
        }
        
    }
}