//
//  StubNavigationController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 21.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit

class StubNavigationController: UINavigationController {

    var topViewControllerResult:UIViewController?
    
    override var topViewController: UIViewController? {
        return topViewControllerResult
    }

}
