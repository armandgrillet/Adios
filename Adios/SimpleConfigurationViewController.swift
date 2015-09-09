//
//  SimpleConfigurationViewController.swift
//  Adios
//
//  Created by Armand Grillet on 17/08/2015.
//  Copyright © 2015 Armand Grillet. All rights reserved.
//

import UIKit

class SimpleConfigurationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var countryPickerView: UIPickerView!
    let onboardManager = OnboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
        countryPickerView.selectRow(onboardManager.getUserCountryPosition(), inComponent: 0, animated: false)
        
        // Standard configuration.
        onboardManager.secondCountry = NSLocalizedString("U.S.A", comment: "Country")
        onboardManager.antisocial = false
        onboardManager.blockAdblockWarnings = true
        onboardManager.privacy = true
    }
    
    @IBAction func setAntisocial(sender: UISwitch) {
        onboardManager.antisocial = sender.on
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return onboardManager.getCountries().count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return onboardManager.getCountries()[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onboardManager.mainCountry = onboardManager.getCountries()[row]
    }
}
