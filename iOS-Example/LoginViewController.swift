//
//  LoginViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class LoginViewController: BaseViewController {

    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.forgotPassword)
    }

    @IBAction func registrationAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.registration, animated: false)
    }
    
    @IBAction func forgotPasswordAlertAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.forgotPasswordAlert)
    }
}
