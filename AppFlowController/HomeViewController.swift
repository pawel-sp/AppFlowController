//
//  HomeViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    @IBAction func loginAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.login)
    }

    @IBAction func registrationAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.registration)
    }

}
