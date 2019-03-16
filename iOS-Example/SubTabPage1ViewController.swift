//
//  SubTabPage1ViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 28.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class SubTabPage1ViewController: BaseViewController {

    @IBAction func backAction(_ sender: Any) {
        AppFlowController.shared.goBack()
    }
    
    @IBAction func subTabPage2Action(_ sender: Any) {
        try! AppFlowController.shared.show(AppPathComponent.subTabPage2)
    }

}
