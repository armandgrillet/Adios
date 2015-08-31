//
//  Parser.swift
//  Parser
//
//  Created by Armand Grillet on 30/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

public class Parser {
    public class func isReadableRule(line: String) -> Bool {
        if line.characters.count > 0
            && line.canBeConvertedToEncoding(NSASCIIStringEncoding)
            && line.characters.first != "!" {
                if let indexOfDollar = line.characters.indexOf("$") {
                    let options = line.substringFromIndex(indexOfDollar.successor()).componentsSeparatedByString(",")
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
    
    public class func getRulesFromLine(var line: String) -> [String] {
        var rule = Rule()
        if !line.containsString("##") && !line.containsString("#@#") {
            rule = addTriggerToRule(rule, line: line)
            if Regex(pattern: "^[ -~]+$").test(rule.triggerUrlFilter) {
                rule = addActionToRule(rule, line: line)
            }
            return [rule.toString()]
        } else { // This is element hiding
            if line.containsString("#@#") { // Exception rule syntax, we transform the rule for a standard syntax
                let indexOfHashtag = line.startIndex.advancedBy(indexOf(line, substring: "#@#")!)
                let domains = line.substringToIndex(indexOfHashtag).componentsSeparatedByString(",")
                var newDomains = [String]()
                for domain in domains {
                    if domain.characters.first == "~" {
                        newDomains.append(domain.stringByReplacingOccurrencesOfString("~", withString: ""))
                    } else {
                        newDomains.append("~" + domain)
                    }
                }
                line = newDomains.joinWithSeparator(",") + "##" + line.substringFromIndex(indexOfHashtag.successor().successor().successor())
            }
            rule = addElementHidingTriggerToRule(rule, line: line)
            rule = addElementHidingActionToRule(rule, line: line)
            
            if rule.triggerIfDomain != nil && rule.triggerUnlessDomain != nil {
                if rule.triggerIfDomain!.count == 1 { // Only one if, we can manage that.
                    rule.triggerUrlFilter = "^(?:[^:/?#]+:)?(?://(?:[^/?#]*\\.)?)?" + escapeSpecialCharacters(rule.triggerIfDomain!.first!) + "[^a-z\\-A-Z0-9._.%]"
                    rule.triggerIfDomain = nil
                    rule.triggerUnlessDomain = rule.triggerUnlessDomain!.map({ "*" + $0 })
                    return [rule.toString()]
                } else {
                    let indexOfHashtag = line.startIndex.advancedBy(indexOf(line, substring: "##")!)
                    let domains = line.substringFromIndex(indexOfHashtag.successor().successor())
                    var regularDomains = [String]()
                    var rules = [String]()
                    for ifDomain in rule.triggerIfDomain! {
                        var ifUnlessDomains = [String]()
                        for unlessDomain in rule.triggerUnlessDomain! {
                            if indexOf(unlessDomain, substring: ifDomain) != nil {
                                ifUnlessDomains.append(unlessDomain)
                            }
                        }
                        
                        if ifUnlessDomains.count > 0 {
                            
                            let newLine = ifDomain + ",~" + ifUnlessDomains.joinWithSeparator(",~") + "##" + domains
                            rules.append(getRulesFromLine(newLine).first!)
                        } else {
                            regularDomains.append(ifDomain)
                        }
                    }
                    
                    let lastLine = regularDomains.joinWithSeparator(",") + "##" + domains
                    rules.append(getRulesFromLine(lastLine).first!)
                    return rules
                }
            } else {
                if rule.triggerIfDomain != nil {
                    rule.triggerIfDomain = rule.triggerIfDomain!.map({ "*" + $0 })
                } else if rule.triggerUnlessDomain != nil {
                    rule.triggerUnlessDomain = rule.triggerUnlessDomain!.map({ "*" + $0 })
                }
                return [rule.toString()]
            }
        }
    }
    
    class func escapeSpecialCharacters(stringWithSpecialCharacters: String) -> String { // Removing special Regex characters except ^, | and *
        var escapedString = stringWithSpecialCharacters
        escapedString = escapedString.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("^", withString: "\\^")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("$", withString: "\\$")
        escapedString = escapedString.stringByReplacingOccurrencesOfString(".", withString: "\\.")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("|", withString: "\\|")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("?", withString: "\\?")
        //escapedString = escapedString.stringByReplacingOccurrencesOfString("*", withString: "\\*")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("+", withString: "\\+")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("(", withString: "\\(")
        escapedString = escapedString.stringByReplacingOccurrencesOfString(")", withString: "\\)")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("[", withString: "\\[")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("]", withString: "\\]")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("}", withString: "\\}")
        return escapedString
    }
    
    class func indexOf(source: String, substring: String) -> Int? {
        let maxIndex = source.characters.count - substring.characters.count
        if maxIndex > 0 {
            for index in 0...maxIndex {
                let rangeSubstring = source.startIndex.advancedBy(index)..<source.startIndex.advancedBy(index + substring.characters.count)
                if source.substringWithRange(rangeSubstring) == substring {
                    return index
                }
            }
        }
        return nil
    }
    
    class func addElementHidingTriggerToRule(rule: Rule, line: String) -> Rule {
        let indexOfHashtag = line.startIndex.advancedBy(indexOf(line, substring: "##")!)
        let domains = line.substringToIndex(indexOfHashtag).componentsSeparatedByString(",")
        
        ////////////////////////////
        // Getting the URL filter //
        ////////////////////////////
        
        rule.triggerUrlFilter = ".*"
        
        ////////////////////////////////
        // Getting the rule's domains //
        ////////////////////////////////
        
        var ifDomains = [String]()
        var unlessDomains = [String]()
        
        for domain in domains {
            if domain.characters.first == "~" {
                unlessDomains.append(domain.stringByReplacingOccurrencesOfString("~", withString: ""))
            } else {
                ifDomains.append(domain)
            }
        }
        
        if ifDomains.count > 0 {
            rule.triggerIfDomain = ifDomains
        }
        
        if unlessDomains.count > 0 {
            rule.triggerUnlessDomain = unlessDomains
        }
        
        return rule
    }
    
    class func addElementHidingActionToRule(rule: Rule, line: String) -> Rule {
        rule.actionType = "css-display-none"
        
        let indexOfHashtag = line.startIndex.advancedBy(indexOf(line, substring: "##")!)
        rule.actionSelector = line.substringFromIndex(indexOfHashtag.successor().successor())
        
        return rule
    }
    
    class func addTriggerToRule(rule: Rule, line: String) -> Rule {
        ////////////////////////////
        // Getting the URL filter //
        ////////////////////////////
        
        var urlFilter = line
        
        // Removing additional info
        if let indexOfDollar = urlFilter.characters.indexOf("$") {
            urlFilter = urlFilter.substringToIndex(indexOfDollar)
        }
        
        // Removing exception characters
        let rangeExceptionCharacters = urlFilter.startIndex..<urlFilter.startIndex.successor().successor()
        if urlFilter.substringWithRange(rangeExceptionCharacters) == "@@" {
            urlFilter.removeRange(rangeExceptionCharacters)
        }
        
        urlFilter = escapeSpecialCharacters(urlFilter)
        
        // Separator character ^ matches anything but a letter, a digit, or one of the following: _ - . %.
        // The end of the address is also accepted as separator.
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("^", withString: "[^a-z\\-A-Z0-9._.%]")
        
        // * symbol means anything
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("*", withString: ".*")
        
        // | in the end means the end of the address
        if urlFilter.substringFromIndex(urlFilter.endIndex.predecessor()) == "|" {
            urlFilter = urlFilter.substringToIndex(urlFilter.endIndex.predecessor()) + "$"
        }
        
        // || in the beginning means beginning of the domain name
        let rangeDomainName = urlFilter.startIndex..<urlFilter.startIndex.successor().successor()
        if urlFilter.substringWithRange(rangeDomainName) == "||" {
            if urlFilter.characters.count > 2 {
                urlFilter.removeRange(rangeDomainName)
                urlFilter = "^(?:[^:]+:)(?://(?:[^/?#]*\\.)?)" + urlFilter
            }
        } else if urlFilter.characters.first == "|" {
            urlFilter.removeAtIndex(urlFilter.startIndex)
            urlFilter = "^" + urlFilter
        }
        
        // other | symbols should be escaped, we have '|$' in our regexp - do not touch it
        urlFilter = urlFilter.stringByReplacingOccurrencesOfString("|", withString: "\\|")
        
        rule.triggerUrlFilter = urlFilter
        
        /////////////////////////
        // Getting the options //
        /////////////////////////
        
        if let indexOfDollar = line.characters.indexOf("$") { // There is options
            let options = line.substringFromIndex(indexOfDollar.successor()).componentsSeparatedByString(",")
            
            // Case sensitivity
            if options.indexOf("match-case") != nil {
                rule.triggerUrlFilterIsCaseSensitive = true
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
                    rule.triggerResourceType = resourceTypes
                    allowedResourceTypes.removeAll() // End of the loop
                }
            }
            
            // Load type
            if options.indexOf("third-party") != nil {
                rule.triggerLoadType = ["third-party"]
            } else if options.indexOf("~third-party") != nil {
                rule.triggerLoadType = ["first-party"]
            }
            
            // Domains
            for option in options {
                if option.containsString("domain=") {
                    if option.substringToIndex(option.startIndex.advancedBy("domain=".characters.count)) == "domain=" {
                        let domains = option.substringFromIndex(option.startIndex.advancedBy("domain=".characters.count))
                        if domains.characters.first == "~" {
                            rule.triggerUnlessDomain = domains.stringByReplacingOccurrencesOfString("~", withString: "").componentsSeparatedByString("|").map({ "*" + $0 })
                        } else {
                            rule.triggerIfDomain = domains.componentsSeparatedByString("|").map({ "*" + $0 })
                        }
                    }
                }
            }
        }
        
        return rule
    }
    
    class func addActionToRule(rule: Rule, line:String) -> Rule {
        let rangeExceptionCharacters = line.startIndex..<line.startIndex.successor().successor()
        if line.substringWithRange(rangeExceptionCharacters) == "@@" {
            rule.actionType = "ignore-previous-rules"
        } else {
            rule.actionType = "block"
        }
        return rule
    }
}