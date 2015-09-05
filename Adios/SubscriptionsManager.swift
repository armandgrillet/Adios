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
    let downloadManager = DownloadManager()
    
    func subscribeToUpdates(callback: () -> Void) {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let silentNotification = CKNotificationInfo()
        silentNotification.shouldSendContentAvailable = true
        
        let subscription = CKSubscription(recordType: "Update", predicate: predicate, options: .FiresOnRecordUpdate)
        subscription.notificationInfo = silentNotification
        
        publicDB.saveSubscription(subscription, completionHandler: ({returnRecord, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            callback()
        }))
    }
    
    func didReceiveNotification(userInfo: [NSObject : AnyObject], completionHandler: (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        if notification.notificationType == .Query {
            print("On a recu une update")
            let lastUpdateWasForEasyList = NSUserDefaults.standardUserDefaults().boolForKey("lastUpdateWasForEasyList")
            var listsToUpdate = ListsManager.getFollowedLists()
            if lastUpdateWasForEasyList == false && listsToUpdate.contains("EasyList") {
                print("On update EasyList")
                downloadManager.downloadLists(["EasyList"], callback: completionHandler)
            } else {
                if let indexOfEasyList = listsToUpdate.indexOf("EasyList") {
                    listsToUpdate.removeAtIndex(indexOfEasyList)
                }
                print("On update les autres listes")
                downloadManager.downloadLists(listsToUpdate, callback: completionHandler)
            }
        }
    }
}