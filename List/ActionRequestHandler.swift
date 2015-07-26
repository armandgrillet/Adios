//
//  ActionRequestHandler.swift
//  List
//
//  Created by Armand Grillet on 27/06/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MobileCoreServices
import MMWormhole

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        let wormhole = MMWormhole(applicationGroupIdentifier: "group.AG.Adios.List", optionalDirectory: "wormhole")
        wormhole.passMessageObject("titleString", identifier: "messageIdentifier")
        
        // Standard case, it works.
        let attachment = NSItemProvider(contentsOfURL: NSBundle.mainBundle().URLForResource("blockerList", withExtension: "json"))!
    
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
    
}
