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
        }
    }
    
}
