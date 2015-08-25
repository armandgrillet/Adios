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
            if let test = userDefaults.stringForKey("EasyList_France") {
                userDefaults.setObject("lo", forKey: "debugRules")
                userDefaults.synchronize()
            }
//            
//            
//            
//            if let followedLists = userDefaults.arrayForKey("followedLists") as! [String]? {
//                userDefaults.setObject("if", forKey: "debugRules")
//                userDefaults.synchronize()
//                if followedLists.contains("EasyList") {
//                    userDefaults.synchronize()
//                    if let list = userDefaults.stringForKey("EasyList") as String! {
//                        rules += list
//                    }
//                }
//            } else {
//                userDefaults.setObject("else", forKey: "debugRules")
//                userDefaults.synchronize()
//            }
//            
//            // JIC
//            if let list = userDefaults.stringForKey("AdiosList") as String! {
//                rules += list
//            }
            
            
            
            
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
                let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("blockerList", withExtension: "json"))!
                
                let item = NSExtensionItem()
                item.attachments = [attachment]
                
                context.completeRequestReturningItems([item], completionHandler: nil);
            }
        }
    }
    
}
