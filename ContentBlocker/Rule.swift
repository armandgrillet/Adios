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
        if triggerUrlFilterIsCaseSensitive != nil {
            stringRule += ",\"url-filter-is-case-sensitive\": \"\(triggerUrlFilterIsCaseSensitive)\""
        }
        if triggerResourceType != nil {
            stringRule += ",\"resource-type\": \(triggerResourceType)"
        }
        if triggerLoadType != nil {
            stringRule += ",\"load-type\": \(triggerLoadType)"
        }
        if triggerIfDomain != nil {
            stringRule += ",\"if-domain\": \(triggerIfDomain)"
        } else if triggerUnlessDomain != nil {
            stringRule += ",\"unless-domain\": \(triggerUnlessDomain)"
        }
        
        stringRule += "}, { \"action\": {\"type\": \"\(actionType)\""
            
        if actionSelector != nil {
           stringRule += ",\"selector\": \(actionSelector)"
        }
        
        return stringRule + "}},"
    }
}