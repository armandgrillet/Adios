//
//  SubscriptionsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit

class SubscriptionsManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let downloadManager = DownloadManager()
    
    func addSubscription(list: String) {
        let predicate = NSPredicate(format: "recordName == \(list)")
        
        let silentNotification = CKNotificationInfo()
        silentNotification.shouldSendContentAvailable = true
        silentNotification.desiredKeys = ["Update"]
        
        let subscription = CKSubscription(recordType: "Rules", predicate: predicate, options: .FiresOnRecordUpdate)
        subscription.notificationInfo = silentNotification

        saveSubscription(subscription)
    }
    
    func saveSubscription(subscription: CKSubscription) {
        publicDB.saveSubscription(subscription, completionHandler: ({returnRecord, error in
            if error != nil {
                print("Subscription failed \(error!.localizedDescription)")
            } else {
                print("Subscription added")
            }
        }))
    }
    
    func didReceiveNotification(userInfo: [NSObject : AnyObject]) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        if notification.notificationType == .Query, let queryNotification = notification as? CKQueryNotification {
            let list = queryNotification.recordID!.recordName
            let update = queryNotification.recordFields!["Update"] as! Int64
            downloadManager.updatesRulesForList(list, update: update)
        }
    }
}