//
//  PlayViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 19.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class PlayViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let parameter = AppFlowController.shared.parameterForCurrentItem() {
            print(parameter)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
