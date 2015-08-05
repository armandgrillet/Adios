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
        
        if !found {
            // self.doneWithResults(nil)
        }
    }
    
    func itemLoadCompletedWithPreprocessingResults(javaScriptPreprocessingResults: [NSObject: AnyObject]) {
        // Here, do something, potentially asynchronously, with the preprocessing
        // results.
        
        // In this very simple example, the JavaScript will have passed us the
        // current background color style, if there is one. We will construct a
        // dictionary to send back with a desired new background color style.
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("AG.Adios.List") { (error: NSError?) -> Void in
            print(error)
            let url: AnyObject? = javaScriptPreprocessingResults["url"]
            if url == nil ||  url! as! String == "" {
                    // No specific url.
            } else if let userDefaults = NSUserDefaults(suiteName: "group.AG.Adios.List") {
                if let ignoredList = userDefaults.arrayForKey("ignore") as! [String]? {
                    if ignoredList.isEmpty { // The ignored list is empty.
                        userDefaults.setObject([url!], forKey: "ignore")
                        userDefaults.synchronize()
                        self.doneWithResults(["alert": "Rule added to the empty array"])
                    } else { // The ignored list exists
                        var mutableIgnoredList = ignoredList as [String]
                        // Let's check if the url is already here
                        if ignoredList.contains(url! as! String) {
                            if let indexOfUrl = ignoredList.indexOf(url! as! String) {
                                mutableIgnoredList.removeAtIndex(indexOfUrl)
                                userDefaults.setObject(mutableIgnoredList, forKey: "ignore")
                                userDefaults.synchronize()
                                self.doneWithResults(["alert": "Rule removed"])
                            }
                        } else { // User is adding the url
                            mutableIgnoredList.append(url! as! String)
                            userDefaults.setObject(mutableIgnoredList, forKey: "ignore")
                            userDefaults.synchronize()
                            self.doneWithResults(["alert": "Rule added"])
                        }
                    }
                } else { // The ignored list doesn't exist yet.
                    userDefaults.setObject([url!], forKey: "ignore")
                    userDefaults.synchronize()
                    self.doneWithResults(["alert": "Rule added and array created"])
                }
            } else { // Something went wrong
                self.doneWithResults(["alert": "Something wrong happened"])
            }
        }
    }
    
    func doneWithResults(resultsForJavaScriptFinalizeArg: [NSObject: AnyObject]?) {
        
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
