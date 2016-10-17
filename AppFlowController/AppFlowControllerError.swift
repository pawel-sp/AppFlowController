//
//  AppFlowControllerError.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

enum AppFlowControllerError:Error {
    
    case pathNameAlreadyRegistered(name:String)
    case internalError
    case unregisteredPathName(name:String)
    case missingConfigurationForAppFlowController
    case unregisteredViewControllerType(viewControllerType:UIViewController.Type)
    case cannotUseTransferItemWithoutVisiblePage
    
    var errorInfo:String {
        switch self {
            case .pathNameAlreadyRegistered(let name):
                return "\(name) is already registered, if you want to register the same UIViewController for presenting it in a different way you need to create separate AppFlowControllerItem case with the same UIViewController"
            case .internalError:
                return "Internal error"
            case .unregisteredPathName(let name):
                return "Unregistered path for item \(name)"
            case .missingConfigurationForAppFlowController:
                return "You need to invoke prepare(forWindow:UIWindow) function first"
            case .unregisteredViewControllerType(let viewControllerType):
                return "Unregistered view controller type \(viewControllerType)"
            case .cannotUseTransferItemWithoutVisiblePage:
                return "Using transfer item is possibly only when there is a visible page"
        }
    }
    
}
