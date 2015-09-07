//
//  InformationViewController.swift
//  Adios
//
//  Created by Armand Grillet on 16/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var informationWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let localfilePath = NSBundle.mainBundle().URLForResource(getlocaleWebpage(), withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        informationWebView.loadRequest(myRequest);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getlocaleWebpage() -> String {
        switch NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String {
        case "ES":
            return "spanish"
        case "FR":
            return "french"
        case "NL":
            return "dutch"
        default:
            return "english"
        }
    }
}