//
//  BaseViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    deinit {
        print("\(type(of:self)) deallocated")
    }

}
