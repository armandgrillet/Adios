//
//  SubscriptionsManager.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class SubscriptionsManager {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let downloadManager = DownloadManager()
    
    func subscribeToUpdates() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let silentNotification = CKNotificationInfo()
        silentNotification.shouldSendContentAvailable = true
        
        let subscription = CKSubscription(recordType: "Update", predicate: predicate, options: .FiresOnRecordUpdate)
        subscription.notificationInfo = silentNotification
        
        self.saveSubscription(subscription)
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
    
    func didReceiveNotification(userInfo: [NSObject : AnyObject], completionHandler: (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        if notification.notificationType == .Query {
            downloadManager.downloadLists(ListsManager.getFollowedLists(), callback: completionHandler)
        }
    }
}