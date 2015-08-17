//
//  Rule.swift
//  Adios
//
//  Created by Armand Grillet on 11/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class Rule {
    var triggerUrl: String = ""
    var triggerUrlFilterIsCaseSensitive: Bool?
    var triggerResourceType: [String]?
    var triggerLoadType: [String]?
    var triggerIfDomain: [String]?
    var triggerUnlessDomain: [String]?
    
    var actionType: String = ""
    var actionSelector: String?
    
    func toString() -> String {
        var stringRule = "{ \"trigger\": { \"url-filter\": \"\(triggerUrl)\""
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
}