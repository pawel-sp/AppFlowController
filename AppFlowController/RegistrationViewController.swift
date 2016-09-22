//
//  RegistrationViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class RegistrationViewController: BaseViewController {

    @IBAction func forgotPasswordAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.registration)
    }

}
