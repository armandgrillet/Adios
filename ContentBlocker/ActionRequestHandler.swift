//
//  ActionRequestHandler.swift
//  ContentBlocker
//
//  Created by Armand Grillet on 09/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        // Getting the rules dictionnary
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            var rules = "[" // We're starting the array
            // We check which lists the user is following and load them by action types.
            if let followedLists = userDefaults.arrayForKey("followedLists") as! [String]? {
                for followedList in followedLists {
                    if let list = userDefaults.arrayForKey("\(followedList)Block") as! [Rule]? {
                        for rule in list {
                            rules += rule.toString()
                        }
                    }
                }
                for followedList in followedLists {
                    if let list = userDefaults.arrayForKey("\(followedList)BlockCookies") as! [Rule]? {
                        for rule in list {
                            rules += rule.toString()
                        }
                    }
                }
                for followedList in followedLists {
                    if let list = userDefaults.arrayForKey("\(followedList)IgnorePreviousRules") as! [Rule]? {
                        for rule in list {
                            rules += rule.toString()
                        }
                    }
                }
            }
                
            // JIC
            if let list = userDefaults.arrayForKey("Adios") as! [Rule]? {
                for rule in list {
                    rules += rule.toString()
                }
            }
            
            // Whitelist managed by the user through Safari
            if let whitelist = userDefaults.arrayForKey("whitelist") as! [String]? {
                for domain in whitelist {
                    rules += IgnoringRule(domain: domain).toString()
                }
            }
            
            // Test
            rules += "{\"trigger\": {\"url-filter\": \"armand.gr\"}, \"action\": { \"type\": \"css-display-none\", \"selector\": \".testContentBlocker\"}}"
            
            // Removing the last coma
            if rules.characters.last! == "," {
                rules.substringToIndex(rules.endIndex.predecessor())
            }
            
            rules += "]" // Closing the table to have a good structure
            
            // Creation the JSON file
            let blockerListPath = NSTemporaryDirectory().stringByAppendingString("blockerList.json")
            try! rules.writeToFile(blockerListPath, atomically: true, encoding: NSUTF8StringEncoding)
            
            // Loading the JSON file
            let attachment = NSItemProvider(contentsOfURL: NSURL.fileURLWithPath(blockerListPath))!
            
            let item = NSExtensionItem()
            item.attachments = [attachment]
            
            context.completeRequestReturningItems([item], completionHandler: { (Bool) -> Void in
                try! NSFileManager().removeItemAtPath(blockerListPath) // Removing the list now that it's used.
            })
            
        }
    }
    
}
