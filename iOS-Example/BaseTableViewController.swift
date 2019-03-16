//
//  BaseTableViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 02.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class BaseTableViewController: UITableViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let path = AppFlowController.shared.currentPathDescription {
            print(path)
        }
    }
    
    deinit {
        print("\(type(of:self)) deallocated")
    }

}
