//
//  LoadingViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

private var defaultsContext = 0

class LoadingViewController: UIViewController {
    @IBOutlet weak var status: UILabel!
    let onboardManager = OnboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        status.text = onboardManager.getRealListsFromChoices().description
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "updateStatus", options: NSKeyValueObservingOptions(), context: &defaultsContext)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &defaultsContext {
            seeUpdate()
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func seeUpdate() {
        print(NSUserDefaults.standardUserDefaults().boolForKey("updateStatus"))
    }
    
    deinit {
        //Remove observer
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "updateStatus", context: &defaultsContext)
    }
}
