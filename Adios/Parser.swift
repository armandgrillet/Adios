//
//  Parser.swift
//  Parser
//
//  Created by Armand Grillet on 30/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

public class Parser {
    public class func isAllowed(rule: String) -> Bool {
        if rule.stringByReplacingOccurrencesOfString("\r", withString: "").characters.count > 0
            && rule.canBeConvertedToEncoding(NSASCIIStringEncoding)
            && rule.characters.first != "!" {
                if let indexOfDollar = rule.characters.indexOf("$") {
                    let options = rule.substringFromIndex(indexOfDollar.successor()).componentsSeparatedByString(",")
                    let allowedResourceTypes = [ // No 'object' because iOS devices don't manage Java or Flash.
                        "document", "script", "image", "stylesheet", "xmlhttprequest", "subdocument",
                        "~document", "~script", "~image", "~stylesheet", "~xmlhttprequest", "~object", "~object-subrequest", "~subdocument"
                    ]
                    var availableResourceTypesInRule = false
                    for allowedResourceType in allowedResourceTypes {
                        if options.indexOf(allowedResourceType) != nil {
                            availableResourceTypesInRule = true
                        }
                    }
                    if !availableResourceTypesInRule && (options.indexOf("object") != nil || options.indexOf("object-subrequest") != nil) {
                        return false // There is only unavailable resource types in the rule
                    }
                }
                return true
        }
        return false
    }
    
    public class func parseRules(rules: [String]) -> [String] {
        var parsedRules = [String]();
        for rule in rules {
            parsedRules += parseRule(rule)
        }
        return parsedRules;
    }
    
    public class func parseRule(var rule: String) -> [String] {
        if isAllowed(rule) {
            var parsedRule = Rule()
            if !rule.containsString("##") && !rule.containsString("#@#") {
                parsedRule = addTriggerToRule(parsedRule, rule: rule)
                if Regex(pattern: "^[ -~]+$").test(parsedRule.triggerUrlFilter) {
                    parsedRule = addActionToRule(parsedRule, rule: rule)
                }
                return [parsedRule.toString()]
            } else { // This is element hiding
                if rule.containsString("#@#") { // Exception parsedRule syntax, we transform the parsedRule for a standard syntax
                    let indexOfHashtag = rule.rangeOfString("#@#")!.startIndex
                    let domains = rule.substringToIndex(indexOfHashtag).componentsSeparatedByString(",")
                    var newDomains = [String]()
                    for domain in domains {
                        if domain.characters.first == "~" {
                            newDomains.append(domain.stringByReplacingOccurrencesOfString("~", withString: ""))
                        } else {
                            newDomains.append("~" + domain)
                        }
                    }
                    rule = newDomains.joinWithSeparator(",") + "##" + rule.substringFromIndex(indexOfHashtag.successor().successor().successor())
                }
                
                // Trigger
                parsedRule.triggerUrlFilter = ".*"
                let indexOfHashtag = rule.rangeOfString("##")!.startIndex
                var hasIfDomain = false
                var hasUnlessDomain = false
                
                if rule.substringToIndex(indexOfHashtag).containsString("~") {
                    hasUnlessDomain = true
                    var ifDomains = [String]()
                    var unlessDomains = [String]()
                    
                    for domain in rule.substringToIndex(indexOfHashtag).componentsSeparatedByString(",") {
                        if domain.characters.first == "~" {
                            unlessDomains.append(domain.stringByReplacingOccurrencesOfString("~", withString: ""))
                        } else {
                            hasIfDomain = true
                            ifDomains.append(domain)
                        }
                    }
                    
                    if ifDomains.count > 0 {
                        parsedRule.triggerIfDomain = ifDomains
                    }
                    
                    if unlessDomains.count > 0 {
                        parsedRule.triggerUnlessDomain = unlessDomains
                    }
                } else {
                    if rule.substringToIndex(indexOfHashtag).componentsSeparatedByString(",") != [""] {
                        parsedRule.triggerIfDomain = rule.substringToIndex(indexOfHashtag).componentsSeparatedByString(",")
                    }
                }
                
                // Action
                parsedRule.actionType = "css-display-none"
                parsedRule.actionSelector = escapeSelector(rule.substringFromIndex(indexOfHashtag.successor().successor()))
                
                if hasIfDomain && hasUnlessDomain {
                    if parsedRule.triggerIfDomain!.count == 1 { // Only one if, we can manage that.
                        parsedRule.triggerUrlFilter = "^(?:[^:/?#]+:)?(?://(?:[^/?#]*\\\\.)?)?" + escapeSpecialCharacters(parsedRule.triggerIfDomain!.first!) + "[^a-z\\\\-A-Z0-9._.%]"
                        parsedRule.triggerIfDomain = nil
                        parsedRule.triggerUnlessDomain = parsedRule.triggerUnlessDomain!.map({ "*" + $0 })
                        return [parsedRule.toString()]
                    } else {
                        let indexOfHashtag = rule.rangeOfString("##")!.startIndex
                        let domains = rule.substringFromIndex(indexOfHashtag.successor().successor())
                        var regularDomains = [String]()
                        var parsedRules = [String]()
                        for ifDomain in parsedRule.triggerIfDomain! {
                            var ifUnlessDomains = [String]()
                            for unlessDomain in parsedRule.triggerUnlessDomain! {
                                if unlessDomain.rangeOfString(ifDomain) != nil {
                                    ifUnlessDomains.append(unlessDomain)
                                }
                            }
                            
                            if ifUnlessDomains.count > 0 {
                                let newRule = ifDomain + ",~" + ifUnlessDomains.joinWithSeparator(",~") + "##" + domains
                                parsedRules += parseRule(newRule)
                            } else {
                                regularDomains.append(ifDomain)
                            }
                        }
                        
                        let lastRule = regularDomains.joinWithSeparator(",") + "##" + domains
                        parsedRules += parseRule(lastRule)
                        return parsedRules
                    }
                } else {
                    if parsedRule.triggerIfDomain != nil {
                        parsedRule.triggerIfDomain = parsedRule.triggerIfDomain!.map({ "*" + $0 })
                    } else if parsedRule.triggerUnlessDomain != nil {
                        parsedRule.triggerUnlessDomain = parsedRule.triggerUnlessDomain!.map({ "*" + $0 })
                    }
                    return [parsedRule.toString()]
                }
            }
        } else {
            return []
        }
    }
    
    class func escapeSelector(selector: String) -> String {
        var escapedString = selector
        escapedString = escapedString.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        return escapedString
    }
    
    class func escapeSpecialCharacters(stringWithSpecialCharacters: String) -> String { // Removing special Regex characters except ^, | and *
        var escapedString = stringWithSpecialCharacters
        escapedString = escapedString.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("^", withString: "\\^")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("$", withString: "\\$")
        escapedString = escapedString.stringByReplacingOccurrencesOfString(".", withString: "\\\\.")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("|", withString: "\\|")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("?", withString: "\\\\?")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("*", withString: "\\*")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("+", withString: "\\\\+")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("(", withString: "\\\\(")
        escapedString = escapedString.stringByReplacingOccurrencesOfString(")", withString: "\\\\)")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("[", withString: "\\\\[")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("]", withString: "\\\\]")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("}", withString: "\\\\}")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        return escapedString
    }
    
    class func addTriggerToRule(parsedRule: Rule, rule: String) -> Rule {
        ////////////////////////////
        // Getting the URL filter //
        ////////////////////////////
        
        var urlFilter = rule
        
        // Removing additional info
        if let indexOfDollar = urlFilter.characters.indexOf("$") {
            urlFilter = urlFilter.substringToIndex(indexOfDollar)
        }
        
        // Removing exception characters
        if urlFilter.characters.count > 1 {
            let startString = urlFilter.substringToIndex(urlFilter.startIndex.successor().successor())
            if startString == "@@" {
                urlFilter = urlFilter.substringFromIndex(urlFilter.startIndex.successor().successor())
            }
        }
        
        urlFilter = escapeSpecialCharacters(urlFilter)
        
        // Separator character ^ matches anything but a letter, a digit, or one of the following: _ - . %.
        // The end of the address is also accepted as separator.
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("^", withString: "[^a-z\\\\-A-Z0-9._.%]")
        // * symbol means anything
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("*", withString: ".*")
        
        // | in the end means the end of the address
        if urlFilter.substringFromIndex(urlFilter.endIndex.predecessor()) == "|" {
            urlFilter = urlFilter.substringToIndex(urlFilter.endIndex.predecessor()) + "$"
        }
        
        // || in the beginning means beginning of the domain name
        if urlFilter.characters.count > 1 {
            let checkBars = urlFilter.substringToIndex(urlFilter.startIndex.successor().successor())
            if checkBars == "||" {
                urlFilter = urlFilter.substringToIndex(urlFilter.startIndex.successor().successor())
                urlFilter = "^(?:[^:]+:)(?://(?:[^/?#]*\\\\.)?)" + urlFilter

            } else if urlFilter.characters.first == "|" {
                urlFilter.removeAtIndex(urlFilter.startIndex)
                urlFilter = "^" + urlFilter
            }
        }
        
        // other | symbols should be escaped, we have '|$' in our regexp - do not touch it
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("|", withString: "\\\\|")
        
        parsedRule.triggerUrlFilter = urlFilter
        
        /////////////////////////
        // Getting the options //
        /////////////////////////
        
        if let indexOfDollar = rule.characters.indexOf("$") { // There is options
            let options = rule.substringFromIndex(indexOfDollar.successor()).componentsSeparatedByString(",")
            
            // Case sensitivity
            if options.indexOf("match-case") != nil {
                parsedRule.triggerUrlFilterIsCaseSensitive = true
            }
            
            // Resource types
            var allowedResourceTypes = [ // No 'object' because iOS devices don't manage Java or Flash.
                "document", "script", "image", "stylesheet", "xmlhttprequest", "subdocument",
                "~document", "~script", "~image", "~stylesheet", "~xmlhttprequest", "~object", "~object-subrequest", "~subdocument"
            ]
            for allowedResourceType in allowedResourceTypes {
                var resourceTypes = [String]()
                if options.indexOf(allowedResourceType) != nil {
                    if allowedResourceType.characters.first == "~" { // If the first allowed resource has a tidle, all the other will also have a tidle.
                        resourceTypes = ["document", "script", "image", "style-sheet", "raw", "popup"]
                        for option in options {
                            switch option {
                            case "~document", "~script", "~image":
                                let realOption = option.substringFromIndex(option.startIndex.successor())
                                resourceTypes.removeAtIndex(resourceTypes.indexOf(realOption)!) // Remove the value from the array.
                            case "~stylesheet":
                                resourceTypes.removeAtIndex(resourceTypes.indexOf("style-sheet")!)
                            case "subdocument":
                                resourceTypes.removeAtIndex(resourceTypes.indexOf("popup")!)
                            case "xmlhttprequest":
                                resourceTypes.removeAtIndex(resourceTypes.indexOf("raw")!)
                            default: break
                            }
                        }
                    } else {
                        for option in options {
                            switch option {
                            case "document", "script", "image":
                                resourceTypes.append(option)
                            case "stylesheet":
                                resourceTypes.append("style-sheet")
                            case "subdocument":
                                resourceTypes.append("popup") // http://trac.webkit.org/browser/trunk/Source/WebCore/page/DOMWindow.cpp#L2149
                            case "xmlhttprequest":
                                resourceTypes.append("raw")
                                // TODO : Add other cases
                            default: break
                            }
                        }
                    }
                    parsedRule.triggerResourceType = resourceTypes
                    allowedResourceTypes.removeAll() // End of the loop
                }
            }
            
            // Load type
            if options.indexOf("third-party") != nil {
                parsedRule.triggerLoadType = ["third-party"]
            } else if options.indexOf("~third-party") != nil {
                parsedRule.triggerLoadType = ["first-party"]
            }
            
            // Domains
            for option in options {
                if option.containsString("domain=") {
                    if option.substringToIndex(option.startIndex.advancedBy("domain=".characters.count)) == "domain=" {
                        let domains = option.substringFromIndex(option.startIndex.advancedBy("domain=".characters.count))
                        if domains.characters.first == "~" {
                            parsedRule.triggerUnlessDomain = domains.stringByReplacingOccurrencesOfString("~", withString: "").componentsSeparatedByString("|").map({ "*" + $0 })
                        } else {
                            parsedRule.triggerIfDomain = domains.componentsSeparatedByString("|").map({ "*" + $0 })
                        }
                    }
                }
            }
        }
        
        return parsedRule
    }
    
    class func addActionToRule(parsedRule: Rule, rule: String) -> Rule {
        if rule.characters.count > 1 {
            let startString = rule.substringToIndex(rule.startIndex.successor().successor())
            if startString == "@@" {
                parsedRule.actionType = "ignore-previous-rules"
            } else {
                parsedRule.actionType = "block"
            }
        } else {
            parsedRule.actionType = "block"
        }
        return parsedRule
    }
}