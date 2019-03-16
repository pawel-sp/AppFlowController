//
//  InfoViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class InfoViewController: BaseViewController {

    @IBAction func backAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.forgotPasswordAlert)
    }
    
    @IBAction func backToHomeAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.home)
    }

}
