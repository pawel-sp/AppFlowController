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
        try! AppFlowController.shared.goBack()
    }

    @IBAction func backToHomeAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.home)
    }

    @IBAction func popToHomeAction(_ sender: Any) {
        try! AppFlowController.shared.pop(to: AppPage.home)
    }
    
    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.info)
    }
}
