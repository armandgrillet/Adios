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
    
    func downloadRulesFromList(list: String) {
        let listToMatch = CKReference(recordID: CKRecordID(recordName: list), action: .DeleteSelf)
        let predicate = NSPredicate(format: "List == %@", listToMatch)
        let query = CKQuery(recordType: "Rules", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (rules, error) -> Void in
            if error != nil {
                print(error)
            } else {
                for rule in rules! {
                    print(rule)
                }
            }
        }
    }
}