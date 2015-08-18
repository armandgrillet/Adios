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
            
            if userDefaults.boolForKey("IsEasyListChosen") {
                if let list = userDefaults.arrayForKey("EasyListBlock") as! [Rule]? {
                    for rule in list {
                        rules += rule.toString()
                    }
                }
                if let list = userDefaults.arrayForKey("EasyListBlockCookies") as! [Rule]? {
                    for rule in list {
                        rules += rule.toString()
                    }
                }
                if let list = userDefaults.arrayForKey("EasyListCSSDisplayNone") as! [Rule]? {
                    for rule in list {
                        rules += rule.toString()
                    }
                }
                if let list = userDefaults.arrayForKey("EasyListIgnorePreviousRules") as! [Rule]? {
                    for rule in list {
                        rules += rule.toString()
                    }
                }
            }
            
            // JIC
            if let list = userDefaults.arrayForKey("AdiosList") as! [Rule]? {
                for rule in list {
                    rules += rule.toString()
                }
            }
            
            // Removing the last coma
            if rules.characters.last! == "," {
                rules = rules.substringToIndex(rules.endIndex.predecessor())
            }
            
            if rules != "[" { // Not empty
                rules += "]" // Closing the table to have a good structure
                
                // Creation the JSON file
                let blockerListPath = NSTemporaryDirectory().stringByAppendingString("baseBlockerList.json")
                try! rules.writeToFile(blockerListPath, atomically: true, encoding: NSUTF8StringEncoding)
                
                // Loading the JSON file
                let attachment = NSItemProvider(contentsOfURL: NSURL.fileURLWithPath(blockerListPath))!
                
                let item = NSExtensionItem()
                item.attachments = [attachment]
                
                context.completeRequestReturningItems([item], completionHandler: { (Bool) -> Void in
                    try! NSFileManager().removeItemAtPath(blockerListPath) // Removing the list now that it's been used.
                })
            } else { // Blocking just one useless rule
                let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("baseBlockerList", withExtension: "json"))!
                
                let item = NSExtensionItem()
                item.attachments = [attachment]
                
                context.completeRequestReturningItems([item], completionHandler: nil);
            }
        }
    }
    
}