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
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    
    func subscribeToUpdates(callback: () -> Void) {
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
    
    func applyNotification(completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastNotification")
        NSUserDefaults.standardUserDefaults().synchronize()
        let lastUpdateWasForEasyList = NSUserDefaults.standardUserDefaults().boolForKey("lastUpdateWasForEasyList")
        var listsToUpdate = ListsManager.getFollowedLists()
        if listsToUpdate == ["EasyList"] { // Just EasyList
            downloadManager.downloadLists(["EasyList"], callback: completionHandler)
        } else if !listsToUpdate.contains("EasyList") { // No EasyList
            downloadManager.downloadLists(listsToUpdate, callback: completionHandler)
        } else { // We have EasyList and other lists
            if lastUpdateWasForEasyList == false {
                downloadManager.downloadLists(["EasyList"], callback: completionHandler)
            } else {
                listsToUpdate.removeAtIndex(listsToUpdate.indexOf("EasyList")!)
                downloadManager.downloadLists(listsToUpdate, callback: completionHandler)
            }
        }
    }
    
    func didReceiveNotification(userInfo: [NSObject : AnyObject], completionHandler: (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        if notification.notificationType == .Query {
            print("Notification received")
            if let lastNotification =  NSUserDefaults.standardUserDefaults().objectForKey("lastNotification") {
                let lastNotificationDate = lastNotification as! NSDate
                if NSCalendar.currentCalendar().isDate(lastNotificationDate, equalToDate: NSDate(), toUnitGranularity: .Hour) { // The last update has not been done just before
                    print("We update")
                    applyNotification(completionHandler)
                } else {
                    print("Same hour")
                    completionHandler(.NoData)
                }
            } else {
                applyNotification(completionHandler)
            }
        }
    }
}