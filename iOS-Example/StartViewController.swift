//
//  StartViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 18.04.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class StartViewController: BaseViewController {
    
    @IBAction func start(_ sender: Any) {
        try! AppFlowController.shared.show(AppPathComponent.home)
    }

}
