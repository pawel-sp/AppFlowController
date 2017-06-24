//
//  RegistrationViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class RegistrationViewController: BaseViewController {

    @IBAction func backAction(_ sender: AnyObject) {
        try! AppFlowController.shared.goBack()
    }

}
