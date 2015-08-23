//
//  OnboardController.swift
//  Adios
//
//  Created by Armand Grillet on 22/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class OnboardManager {
    var mainList: String? {
        get {
            if let list = NSUserDefaults.standardUserDefaults().stringForKey("mainList") {
                return list
            } else {
                return getLogicCountry()
            }
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "mainList")
            } else {
                NSUserDefaults.standardUserDefaults().setValue(getLogicCountry(), forKey: "mainList")
            }
        }
    }
    var secondList: String? {
        get {
            if let list = NSUserDefaults.standardUserDefaults().stringForKey("secondList") {
                if list == mainList {
                    return "No"
                } else {
                    return list
                }
            } else {
                return "No"
            }
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "secondList")
            } else {
                NSUserDefaults.standardUserDefaults().setValue("No", forKey: "secondList")
            }
            
        }
    }
    var blockAdblockWarnings: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("blockAdblockWarnings")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "blockAdblockWarnings")
        }
    }
    var social: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("social")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "social")
        }
    }
    var privacy: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("privacy")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "privacy")
        }
    }
    
    private let lists = ["Arabic region 🇪🇬", "Bulgaria 🇧🇬", "China 🇨🇳", "Czech and Slovak Rep. 🇸🇰", "Denmark 🇩🇰", "France 🇫🇷", "Estonia 🇪🇪", "Germany 🇩🇪", "Greece 🇬🇷", "Hungary 🇭🇺", "Iceland 🇮🇸", "Indonesia 🇮🇩", "Italy 🇮🇹", "Israel 🇮🇱", "Japan 🇯🇵", "Latvia 🇱🇻", "Netherlands 🇳🇱", "Poland 🇵🇱", "Romania 🇷🇴", "Russia 🇷🇺", "United Kingdom 🇬🇧", "U.S.A 🇺🇸"]
    
    func getLogicCountry() -> String {
        switch NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String {
        case "EG", "SA":
            return "Arabic region 🇪🇬"
        case "BG":
            return "Bulgaria 🇧🇬"
        case "CN":
            return "China 🇨🇳"
        case "CZ", "SK":
            return "Czech and Slovak Rep. 🇸🇰"
        case "DK":
            return "Denmark 🇩🇰"
        case "FR":
            return "France 🇫🇷"
        case "EE":
            return "Estonia 🇪🇪"
        case "DE":
            return "Germany 🇩🇪"
        case "GR":
            return "Greece 🇬🇷"
        case "HU":
            return "Hungary 🇭🇺"
        case "IS":
            return "Iceland 🇮🇸"
        case "ID":
            return "Indonesia 🇮🇩"
        case "IT":
            return "Italy 🇮🇹"
        case "IL":
            return "Israel 🇮🇱"
        case "JP":
            return "Japan 🇯🇵"
        case "LV":
            return "Latvia 🇱🇻"
        case "NL":
            return "Netherlands 🇳🇱"
        case "PL":
            return "Poland 🇵🇱"
        case "RO":
            return "Poland 🇵🇱"
        case "RU":
            return "Russia 🇷🇺"
        case "GB":
            return "United Kingdom 🇬🇧"
        default:
            return "U.S.A 🇺🇸"
        }
    }
    
    func getMainLists() -> [String] {
        return lists
    }
    
    func getMainListPosition() -> Int {
        return lists.indexOf(mainList!)!
    }
    
    func getSecondLists() -> [String] {
        var secondLists = lists
        secondLists.removeAtIndex(secondLists.indexOf(mainList!)!)
        secondLists.insert("No", atIndex: 0)
        return secondLists
    }
    
    func getSecondListPosition() -> Int {
        return getSecondLists().indexOf(secondList!)!
    }
    
    func reset() {
        mainList = nil
        secondList = nil
        blockAdblockWarnings = true
        social = true
        privacy = true
    }
}