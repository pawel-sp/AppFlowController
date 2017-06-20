//
//  MockNavigationController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 20.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit

class MockNavigationController: UINavigationController {
    
    var pushViewControllerParams:(UIViewController, Bool)?
    var popViewControllerParams:(Bool)?
    var setViewControllersParams:([UIViewController], Bool)?
    
    var visibleViewControllerResult:UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerParams = (viewController, animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerParams = (animated)
        return nil
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setViewControllersParams = (viewControllers, animated)
    }
    
    override var visibleViewController: UIViewController? {
        return visibleViewControllerResult ?? super.visibleViewController
    }
    
}
