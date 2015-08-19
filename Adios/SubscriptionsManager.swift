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
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let silentNotification = CKNotificationInfo()
        silentNotification.shouldSendContentAvailable = true
        silentNotification.desiredKeys = ["Version"]
        
        let subscription = CKSubscription(recordType: "Updates", predicate: predicate, options: .FiresOnRecordUpdate)
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
        print("We received a notification")
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        if notification.notificationType == .Query, let queryNotification = notification as? CKQueryNotification {
            let update = queryNotification.recordFields!["Version"]! as! Int
            downloadManager.getNewRecords(update)
        }
    }
}