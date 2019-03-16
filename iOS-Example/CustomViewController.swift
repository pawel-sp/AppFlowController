//
//  CustomViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class CustomViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        try! AppFlowController.shared.updateCurrentPath(with: self, for: AppPathComponent.custom.name)
    }
    
    @IBAction func loginAction(_ sender:Any) {
        try! AppFlowController.shared.show(AppPathComponent.login)
    }
    
}
