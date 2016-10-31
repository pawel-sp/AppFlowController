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
        AppFlowController.shared.show(item: AppPage.home)
    }

    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        AppFlowController.shared.show(item: AppPage.info)
    }
}
