//
//  TabPageTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 29.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import AppFlowController

class TabPageTransition: DefaultTabBarAppFlowControllerTransition {

    override func configureViewController(from viewController: UIViewController) -> UIViewController {
        let conf = [
            AppPage.tabPage1 : "page1",
            AppPage.tabPage2 : "page2"
        ]
        let result = super.configureViewController(from: viewController)
        // By default title is nil because all view controllers inside the UITabBarController are in custom navigation controllers
        result.title = conf.first(where: { $0.key.viewControllerType == type(of: viewController) })?.value
        return result
    }
    
}

class OutOfTabsTransition: PushPopAppFlowControllerTransition {
    
    override func forwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            // That means navigation controller for UITabBarController instead of nested navigation controller.
            navigationController.navigationController?.pushViewController(viewController, animated: animated, completion:completionBlock)
        }
    }
    
}
