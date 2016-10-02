//
//  BaseTableViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 02.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    deinit {
        print("\(type(of:self)) deallocated")
    }

}
