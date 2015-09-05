//
//  ContentBlockers.swift
//  Adios
//
//  Created by Armand Grillet on 25/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import SafariServices

public class ContentBlockers {
    public class func reload(callback: ((Bool) -> Void)) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.BaseContentBlocker") { (error: NSError?) -> Void in
            if error == nil {
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                    if error == nil {
                        callback(true)
                    } else {
                        print(otherError)
                        callback(false)
                    }
                }
            } else {
                print(error)
                callback(false)
            }
        }
    }
    
    public class func reloadOneContentBlocker(name: String, callback: (UIBackgroundFetchResult) -> Void) {
        print("Reloading \(name)")
        SFContentBlockerManager.reloadContentBlockerWithIdentifier(name) { (error: NSError?) -> Void in
            if error == nil {
                print("Success")
                callback(.NewData)
            } else {
                print(error)
            }
        }
    }
}