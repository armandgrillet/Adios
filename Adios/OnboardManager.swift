//
//  OnboardController.swift
//  Adios
//
//  Created by Armand Grillet on 22/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import Foundation

class OnboardManager {
    var mainCountry: String? {
        get {
            if let country = NSUserDefaults.standardUserDefaults().stringForKey("mainCountry") {
                return country
            } else {
                return getCountryFromLocalizedCountry(getLogicLocalizedCountry())
            }
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(getCountryFromLocalizedCountry(newValue!), forKey: "mainCountry")
            } else {
                NSUserDefaults.standardUserDefaults().setValue(getCountryFromLocalizedCountry(getLogicLocalizedCountry()), forKey: "mainCountry")
            }
        }
    }
    var secondCountry: String? {
        get {
            if let country = NSUserDefaults.standardUserDefaults().stringForKey("secondCountry") {
                if country == "No" {
                    return NSLocalizedString("No", comment: "Just the word 'no'")
                } else if country == mainCountry {
                    return NSLocalizedString("No", comment: "Just the word 'no'")
                } else {
                    return country
                }
            } else {
                return NSLocalizedString("No", comment: "Just the word 'no'")
            }
        }
        set {
            if newValue != nil && newValue != "No" && newValue != NSLocalizedString("No", comment: "Just the word 'no'") {
                NSUserDefaults.standardUserDefaults().setValue(getCountryFromLocalizedCountry(newValue!), forKey: "secondCountry")
            } else {
                NSUserDefaults.standardUserDefaults().setValue("No", forKey: "secondCountry")
            }
        }
    }
    var blockAdblockWarnings: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("tempBlockAdblockWarnings")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "tempBlockAdblockWarnings")
        }
    }
    var antisocial: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("tempAntisocial")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "tempAntisocial")
        }
    }
    var privacy: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("tempPrivacy")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "tempPrivacy")
        }
    }
    
    func getCountries() -> [String] {
        let countries = [localized("Arabic region"), localized("Bulgaria"), localized("China"), localized("Czech and Slovak Rep."), localized("Denmark"), localized("France"), localized("Estonia"), localized("Germany"), localized("Greece"), localized("Hungary"), localized("Iceland"), localized("Indonesia"), localized("Italy"), localized("Israel"), localized("Japan"), localized("Latvia"), localized("Netherlands"), localized("Poland"), localized("Romania"), localized("Russia"), localized("United Kingdom"), localized("U.S.A")].sort()
        return countries
    }
    
    func localized(country: String) -> String {
        return NSLocalizedString(country, comment: "Country")
    }
    
    func getLogicLocalizedCountry() -> String {
        switch NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String {
        case "EG", "SA":
            return localized("Arabic region")
        case "BG":
            return localized("Bulgaria")
        case "CN":
            return localized("China")
        case "CZ", "SK":
            return localized("Czech and Slovak Rep.")
        case "DK":
            return localized("Denmark")
        case "FR":
            return localized("France")
        case "EE":
            return localized("Estonia")
        case "DE":
            return localized("Germany")
        case "GR":
            return localized("Greece")
        case "HU":
            return localized("Hungary")
        case "IS":
            return localized("Iceland")
        case "ID":
            return localized("Indonesia")
        case "IT":
            return localized("Italy")
        case "IL":
            return localized("Israel")
        case "JP":
            return localized("Japan")
        case "LV":
            return localized("Latvia")
        case "NL":
            return localized("Netherlands")
        case "PL":
            return localized("Poland")
        case "RO":
            return localized("Romania")
        case "RU":
            return localized("Russia")
        case "GB":
            return localized("United Kingdom")
        default:
            return localized("U.S.A")
        }
    }
    
    func getCountryFromLocalizedCountry(localizedCountry: String) -> String? {
        switch localizedCountry {
        case localized("Arabic region"):
            return "Arabic region"
        case localized("Bulgaria"):
            return "Bulgaria"
        case localized("China"):
            return "China"
        case localized("Czech and Slovak Rep."):
            return "Czech and Slovak Rep."
        case localized("Denmark"):
            return "Denmark"
        case localized("France"):
            return "France"
        case localized("Estonia"):
            return "Estonia"
        case localized("Germany"):
            return "Germany"
        case localized("Greece"):
            return "Greece"
        case localized("Hungary"):
            return "Hungary"
        case localized("Iceland"):
            return "Iceland"
        case localized("Indonesia"):
            return "Indonesia"
        case localized("Italy"):
            return "Italy"
        case localized("Israel"):
            return "Israel"
        case localized("Japan"):
            return "Japan"
        case localized("Latvia"):
            return "Latvia"
        case localized("Netherlands"):
            return "Netherlands"
        case localized("Poland"):
            return "Poland"
        case localized("Romania"):
            return "Romania"
        case localized("Russia"):
            return "Russia"
        case localized("United Kingdom"):
            return "United Kingdom"
        case localized("U.S.A"):
            return "U.S.A"
        default:
            return nil
        }
    }
    
    func getUserCountryPosition() -> Int {
        return getCountries().indexOf(localized(mainCountry!))!
    }
    
    func getSecondaryCountries() -> [String] {
        var secondLists = getCountries()
        secondLists.removeAtIndex(secondLists.indexOf(localized(mainCountry!))!)
        secondLists.insert(NSLocalizedString("No", comment: "Just the word 'no'"), atIndex: 0)
        return secondLists
    }
    
    func getSecondListPosition() -> Int {
        return getSecondaryCountries().indexOf(localized(secondCountry!))!
    }
    
    func getRealListsFromChoices() -> [String] {
        var realLists: [String] = []
        
        if let realMainList = ListsManager.getRealListFromCountry(mainCountry!) {
            realLists.append(realMainList)
        }
        
        if let realSecondList = ListsManager.getRealListFromCountry(secondCountry!) {
            if realSecondList != realLists.first {
                realLists.append(realSecondList)
            }
        }
        
        if blockAdblockWarnings {
            realLists.append("AdblockWarningRemoval")
        }
        if antisocial {
            realLists.append("EasyList_SocialMedia")
        }
        if privacy {
            realLists.append("EasyPrivacy")
        }
        
        return realLists
    }
    
    func reset() {
        mainCountry = nil
        secondCountry = nil
        blockAdblockWarnings = true
        antisocial = true
        privacy = true
    }
}