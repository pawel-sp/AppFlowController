//
//  ForgotPasswordViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    @IBAction func backAction(_ sender: AnyObject) {
        AppFlowController.sharedController.goBack()
    }

    @IBAction func backToHomeAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: AppPage.home)
    }

    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: AppPage.info)
    }
}
