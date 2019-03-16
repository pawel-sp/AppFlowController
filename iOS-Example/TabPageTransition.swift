//
//  TabPageTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 29.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import AppFlowController

class TabPageTransition: DefaultTabBarFlowTransition {
    override func configureViewController(from viewController: UIViewController) -> UIViewController {
        let conf = [
            AppPathComponent.tabPage1 : "page1",
            AppPathComponent.tabPage2 : "page2"
        ]
        let result = super.configureViewController(from: viewController)
        // By default title is nil because all view controllers inside the UITabBarController are in custom navigation controllers
        result.title = conf.first(where: { $0.key.viewControllerType == type(of: viewController) })?.value
        return result
    }
}

class OutOfTabsTransition: PushPopFlowTransition {
    override func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            // That means navigation controller for UITabBarController instead of nested navigation controller.
            navigationController.navigationController?.pushViewController(viewController, animated: animated, completion: completion)
        }
    }
}
