//
//  Rule.swift
//  Adios
//
//  Created by Armand Grillet on 25/07/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class Rule {
    private let actionSelector: String
    private let actionType: String
    private let triggerFilter: String
    private let triggerFilterCaseSensitive: Bool
    private let triggerIfDomain: [String]
    private let triggerResourceType: [String]
    private let triggerUnlessDomain: [String]
    private let list: String
    private let triggerLoadType: [String]
    
    init(actionSelector: String, actionType: String, triggerFilter: String, triggerFilterCaseSensitive: Bool, triggerIfDomain: [String], triggerResourceType: [String], triggerUnlessDomain: [String], list: String, triggerLoadType: [String]) {
        self.actionSelector = actionSelector
        self.actionType = actionType
        self.triggerFilter = triggerFilter
        self.triggerFilterCaseSensitive = triggerFilterCaseSensitive
        self.triggerIfDomain = triggerIfDomain
        self.triggerResourceType = triggerResourceType
        self.triggerUnlessDomain = triggerUnlessDomain
        self.list = list
        self.triggerLoadType = triggerLoadType
    }
}