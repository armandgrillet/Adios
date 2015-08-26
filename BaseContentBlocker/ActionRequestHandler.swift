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
        var rules = "["
        if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
            if let easyList = userDefaults.arrayForKey("EasyList") {
                for rule in easyList {
                    rules += rule as! String
                }
            }
            if let adiosList = userDefaults.arrayForKey("AdiosList") {
                for rule in adiosList {
                    rules += rule as! String
                }
            }
            // Removing the last coma
            if rules.characters.last! == "," {
                rules = rules.substringToIndex(rules.endIndex.predecessor())
            }
            
            if rules != "[" { // Not empty
                rules += "]" // Closing the table to have a good structure
                // Creation the JSON file
                NSLog("%@", rules)
                let data = rules.dataUsingEncoding(NSUTF8StringEncoding)
                // Loading the JSON file
                let attachment = NSItemProvider(item: data, typeIdentifier: kUTTypeJSON as String)
                
                let item = NSExtensionItem()
                item.attachments = [attachment]
                
                context.completeRequestReturningItems([item], completionHandler: nil)
            } else {
                backToBasics(context)
            }
        } else {
            backToBasics(context)
        }
    }
    
    func backToBasics(context: NSExtensionContext) {
        NSLog("fail")
        let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("blockerList", withExtension: "json"))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
}