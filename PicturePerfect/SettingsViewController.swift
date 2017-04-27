//
//  SettingsViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/26/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let userDefaults = UserDefaults.standard


    @IBOutlet weak var autoSavePhotosSwitch: UISwitch!
    @IBOutlet weak var sensitivitySlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        // Load settings
        let autoSave:Bool = userDefaults.bool(forKey: AUTO_SAVE_KEY)
        let sensitivity: Float = userDefaults.float(forKey: SENSITIVITY_KEY)

        autoSavePhotosSwitch.setOn(autoSave, animated: false)
        sensitivitySlider.setValue(sensitivity, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save settings
        let autoSave: Bool = autoSavePhotosSwitch.isOn
        let sensitivity: Float = sensitivitySlider.value
        
        userDefaults.set(autoSave, forKey: AUTO_SAVE_KEY)
        userDefaults.set(sensitivity, forKey: SENSITIVITY_KEY)
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func userDidPressDone(_ sender: UIBarButtonItem) {
    
    }
}
