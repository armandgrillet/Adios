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
        backToBasics(context)
    }
    
    func backToBasics(context: NSExtensionContext) {
        NSLog("fail")
        let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("blockerList", withExtension: "json"))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
}
