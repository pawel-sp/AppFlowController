//
//  TestTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import AppFlowController

class TestTransition: FlowTransition {
    func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> FlowTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            navigationController.viewControllers.append(viewController)
            completion()
        }
    }
    
    func performBackwardTransition(animated: Bool, completion: @escaping ()->()) -> FlowTransition.BackwardTransitionAction {
        return { viewcontroller in
            let navigationController = viewcontroller.navigationController
            if let index = navigationController?.viewControllers.index(of: viewcontroller) {
                navigationController?.viewControllers.remove(at: index)
            }
        }
    }
}
