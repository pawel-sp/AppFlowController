//
//  TabPage1ViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class TabPage1ViewController: BaseViewController {

    @IBAction func subPageAction(_ sender: Any) {
        try! AppFlowController.shared.show(AppPathComponent.subTabPage1)
    }

}
