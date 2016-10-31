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

    @IBAction func loginAction(_ sender: AnyObject) {
        AppFlowController.shared.show(item: AppPage.login)
    }

    @IBAction func registrationAction(_ sender: AnyObject) {
        AppFlowController.shared.show(item: AppPage.registration)
    }

    @IBAction func itemsAction(_ sender: AnyObject) {
        AppFlowController.shared.show(item: AppPage.items)
    }
    
    @IBAction func tabsAction(_ sender: AnyObject) {
        AppFlowController.shared.show(item: AppPage.tabPage2)
    }
    
}
