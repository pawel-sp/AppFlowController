//
//  ForgotPasswordViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class ForgotPasswordViewController: BaseViewController {
    @IBAction func backAction(_ sender: AnyObject) {
        AppFlowController.shared.goBack()
    }

    @IBAction func backToHomeAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.home)
    }

    @IBAction func popToHomeAction(_ sender: Any) {
        try! AppFlowController.shared.pop(to: AppPathComponent.home)
    }
    
    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(AppPathComponent.info)
    }
}
