//
//  ActionRequestHandler.swift
//  FirstContentBlocker
//
//  Created by Armand Grillet on 26/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        notSoBasic(context)
//        var rules = "["
//        
//        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
//        let sharedContainerPathLocation = groupUrl?.path
//        let fileManager = NSFileManager()
//        
//        let filePath = sharedContainerPathLocation! + "/AdiosList.json"
//        if let content = fileManager.contentsAtPath(filePath) {
//            let list = String(data: content, encoding: NSUTF8StringEncoding)
//            rules += list!
//        }
//        
//        // Removing the last coma
//        if rules.characters.last! == "," {
//            rules = rules.substringToIndex(rules.endIndex.predecessor())
//        }
//        
//        NSLog("%@", rules)
//        
//        if rules != "[" { // Not empty
//            rules += "]" // Closing the table to have a good structure
//            // Creation the JSON file
//            let data = rules.dataUsingEncoding(NSUTF8StringEncoding)
//            // Loading the JSON file
//            let attachment = NSItemProvider(item: data, typeIdentifier: kUTTypeJSON as String)
//            
//            let item = NSExtensionItem()
//            item.attachments = [attachment]
//            
//            context.completeRequestReturningItems([item], completionHandler: nil)
//        } else {
//            backToBasics(context)
//        }
    }
    
    func backToBasics(context: NSExtensionContext) {
        let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("blockerList", withExtension: "json"))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
    
    func notSoBasic(context: NSExtensionContext) {
        let groupUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.AG.Adios")
        let sharedContainerPathLocation = groupUrl?.path
        
        let filePath = sharedContainerPathLocation! + "/AdiosList.json"
        let fileUrl = NSURL(fileURLWithPath: filePath)
        
        let attachment = NSItemProvider(contentsOfURL: fileUrl)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
}