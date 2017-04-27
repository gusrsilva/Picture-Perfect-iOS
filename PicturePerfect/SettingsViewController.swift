//
//  SettingsViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/26/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var autoSavePhotosSwitch: UISwitch!
    @IBOutlet weak var sensitivitySlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        // TODO: Load settings
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: Save settings
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func userDidPressDone(_ sender: UIBarButtonItem) {
    
    }
}
