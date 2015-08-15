//
//  ActionRequestHandler.swift
//  Action
//
//  Created by Armand Grillet on 27/07/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit
import MobileCoreServices
import SafariServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    
    var extensionContext: NSExtensionContext?
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        // Do not call super in an Action extension with no user interface
        self.extensionContext = context
        
        var found = false
        
        // Find the item containing the results from the JavaScript preprocessing.
        outer:
            for item: AnyObject in context.inputItems {
                let extItem = item as! NSExtensionItem
                if let attachments = extItem.attachments {
                    for itemProvider: AnyObject in attachments {
                        if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                            itemProvider.loadItemForTypeIdentifier(String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                                let dictionary = item as! [String: AnyObject]
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.itemLoadCompletedWithPreprocessingResults(dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [NSObject: AnyObject])
                                }
                                found = true
                            })
                            if found {
                                break outer
                            }
                        }
                    }
                }
        }
    }
    
    func itemLoadCompletedWithPreprocessingResults(javaScriptPreprocessingResults: [NSObject: AnyObject]) {
        if let url = javaScriptPreprocessingResults["url"] as! String? {
            if url != "" {
                if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios") {
                    if let ignoredList = userDefaults.arrayForKey("whitelist") as! [String]? {
                        if ignoredList.isEmpty { // The ignored list is empty.
                            userDefaults.setObject([url], forKey: "whitelist")
                            userDefaults.synchronize()
                            self.doneWithResults(["alert": "\(url) has been added to the whitelist"])
                        } else { // The ignored list exists
                            var mutableIgnoredList = ignoredList as [String]
                            // Let's check if the url is already here
                            if ignoredList.contains(url) {
                                if let indexOfUrl = ignoredList.indexOf(url) {
                                    mutableIgnoredList.removeAtIndex(indexOfUrl)
                                    userDefaults.setObject(mutableIgnoredList, forKey: "whitelist")
                                    userDefaults.synchronize()
                                    self.doneWithResults(["alert": "\(url) removed from the whitelist"])
                                }
                            } else { // User is adding the url
                                mutableIgnoredList.append(url)
                                userDefaults.setObject(mutableIgnoredList, forKey: "whitelist")
                                userDefaults.synchronize()
                                self.doneWithResults(["alert": "\(url) added in the whitelist"])
                            }
                        }
                    } else { // The ignored list doesn't exist yet.
                        userDefaults.setObject([url], forKey: "whitelist")
                        userDefaults.synchronize()
                        self.doneWithResults(["alert": "\(url) added and whitelist created"])
                    }
                }
            } else {
              self.doneWithResults(["alert": "The URL is not correct"])
            }
        } else {
            self.doneWithResults(["alert": "No URL"])
        }
    }
    
    func doneWithResults(resultsForJavaScriptFinalizeArg: [NSObject: AnyObject]?) {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.ContentBlocker") { (error: NSError?) -> Void in
            if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
                // Construct an NSExtensionItem of the appropriate type to return our
                // results dictionary in.
                
                // These will be used as the arguments to the JavaScript finalize()
                // method.
                
                let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
                
                let resultsProvider = NSItemProvider(item: resultsDictionary, typeIdentifier: String(kUTTypePropertyList))
                
                let resultsItem = NSExtensionItem()
                resultsItem.attachments = [resultsProvider]
                
                // Signal that we're complete, returning our results.
                self.extensionContext!.completeRequestReturningItems([resultsItem], completionHandler: nil)
            } else {
                // We still need to signal that we're done even if we have nothing to
                // pass back.
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }
            
            // Don't hold on to this after we finished with it.
            self.extensionContext = nil
        }
    }
    
}
