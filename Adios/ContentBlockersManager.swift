//
//  ContentBlockersManager.swift
//  Adios
//
//  Created by Armand Grillet on 19/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation
import SafariServices

public class ContentBlockersManager {
    public class func updateContentBlockers() {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (error: NSError?) -> Void in
            SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (otherError: NSError?) -> Void in
                print(otherError)
            }
            print(error)
        }
    }
}