//
//  TabPage2ViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class TabPage2ViewController: BaseViewController {

    @IBAction func backToHomeAction(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.home)
    }

    @IBAction func goToPage1Action(_ sender: AnyObject) {
        try! AppFlowController.shared.show(page: AppPage.tabPage1)
    }
}
