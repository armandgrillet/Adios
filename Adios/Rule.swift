//
//  Rule.swift
//  Adios
//
//  Created by Armand Grillet on 18/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class Rule {
    var triggerUrlFilter: String = ""
    var triggerUrlFilterIsCaseSensitive: Bool?
    var triggerResourceType: [String]?
    var triggerLoadType: [String]?
    var triggerIfDomain: [String]?
    var triggerUnlessDomain: [String]?
    
    var actionType: String = ""
    var actionSelector: String?
    
    func toString() -> String {
        var stringRule = "{ \"trigger\": { \"url-filter\": \"\(triggerUrlFilter)\""
        if let displayedTriggerUrlFilterIsCaseSensitive = triggerUrlFilterIsCaseSensitive {
            stringRule += ",\"url-filter-is-case-sensitive\": \"\(displayedTriggerUrlFilterIsCaseSensitive)\""
        }
        if let displayedTriggerResourceType = triggerResourceType {
            stringRule += ",\"resource-type\": \(displayedTriggerResourceType)"
        }
        if let displayedTriggerLoadType = triggerLoadType {
            stringRule += ",\"load-type\": \(displayedTriggerLoadType)"
        }
        if let displayedTriggerIfDomain = triggerIfDomain {
            stringRule += ",\"if-domain\": \(displayedTriggerIfDomain)"
        } else if let displayedTriggerUnlessDomain = triggerUnlessDomain {
            stringRule += ",\"unless-domain\": \(displayedTriggerUnlessDomain)"
        }
        
        stringRule += "}, \"action\": {\"type\": \"\(actionType)\""
        
        if let displayedActionSelector = actionSelector {
            stringRule += ",\"selector\": \"\(displayedActionSelector)\""
        }
        
        return stringRule + "}},"
    }
    
    init(triggerUrlFilterWithOneBackslash: String, actionType: String) {
        // We need to replace the simple backslashes with two backslashes
        self.triggerUrlFilter = triggerUrlFilterWithOneBackslash.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        // If CloudKit solves the bug I need to be prepared so it's handled here:
        self.triggerUrlFilter = triggerUrlFilterWithOneBackslash.stringByReplacingOccurrencesOfString("\\\\\\\\", withString: "\\\\")
        self.actionType = actionType
    }
}
