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
    var presentViewControllerParams:(UIViewController, Bool)?
    var visibleViewControllerResult:UIViewController?
    
    var didDismissAllPresentedViewControllers:Bool?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerParams = (viewController, animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerParams = (animated)
        return nil
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentViewControllerParams = (viewControllerToPresent, flag)
        completion?()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setViewControllersParams = (viewControllers, animated)
    }
    
    override var visibleViewController: UIViewController? {
        return visibleViewControllerResult ?? super.visibleViewController
    }
    
    override func dismissAllPresentedViewControllers(completionBlock: (() -> ())?) {
        didDismissAllPresentedViewControllers = true
        completionBlock?()
    }
    
}
