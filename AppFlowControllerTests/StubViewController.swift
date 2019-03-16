//
//  StubViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 20.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit

class StubViewController: UIViewController {
    var presentedViewControllerResult: UIViewController?
    
    override var presentedViewController: UIViewController? {
        return presentedViewControllerResult ?? super.presentedViewController
    }
}
