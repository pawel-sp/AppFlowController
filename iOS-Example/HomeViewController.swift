//
//  HomeViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class HomeViewController: BaseViewController {

    @IBOutlet weak var skipSwitch: UISwitch!
    
    @IBAction func loginAction(_ sender: AnyObject) {
        if skipSwitch.isOn {
            try! AppFlowController.shared.show(
                page: AppPage.forgotPassword,
                skipPages: [AppPage.login]
            )
        } else {
            try! AppFlowController.shared.show(page: AppPage.login)
        }
    }

    @IBAction func registrationAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.registration)
    }

    @IBAction func itemsAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.items)
    }
    
    @IBAction func tabsAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.tabPage2)
    }
    
    @IBAction func containerAction(_ sender: Any) {
        try! AppFlowController.shared.show(page: AppPage.container)
    }
    
}
