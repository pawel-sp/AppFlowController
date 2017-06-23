//
//  AppFlowControllerError.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright (c) 2017 Paweł Sporysz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

public enum AppFlowControllerError:Error, Equatable {
    
    case pathAlreadyRegistered(identifier:String)
    case internalError
    case unregisteredPathIdentifier(identifier:String)
    case missingConfigurationForAppFlowController
    case unregisteredViewControllerType(viewControllerType:UIViewController.Type)
    case missingVariant(identifier:String)
    case variantNotSupported(identifier:String)
    
    public var info:String {
        switch self {
            case .pathAlreadyRegistered(let identifier):
                return "\(identifier) is already registered, if you want to register the same UIViewController for presenting it in a different way you need to create separate AppFlowControllerItem case with the same UIViewController or use supportVariants property in AppFlowControllerItem"
            case .internalError:
                return "Internal error"
            case .unregisteredPathIdentifier(let identifier):
                return "Unregistered path for item \(identifier)"
            case .missingConfigurationForAppFlowController:
                return "You need to invoke prepare(forWindow:UIWindow) function first"
            case .unregisteredViewControllerType(let viewControllerType):
                return "Unregistered view controller type \(viewControllerType)"
            case .missingVariant(let identifier):
                return "\(identifier) supports variants and cannot be shown without it. Use variant parameter in show method"
            case .variantNotSupported(let identifier):
                return "\(identifier) doesn't support variants"
        }
    }
    
}

public func ==(lhs:AppFlowControllerError, rhs:AppFlowControllerError) -> Bool {
    switch (lhs, rhs) {
        case (.pathAlreadyRegistered(let id1), .pathAlreadyRegistered(let id2)):
            return id1 == id2
        case (.internalError, .internalError):
            return true
        case (.unregisteredPathIdentifier(let id1), .unregisteredPathIdentifier(let id2)):
            return id1 == id2
        case (.missingConfigurationForAppFlowController, .missingConfigurationForAppFlowController):
            return true
        case (.unregisteredViewControllerType(let viewControllerType1), .unregisteredViewControllerType(let viewControllerType2)):
            return viewControllerType1 == viewControllerType2
        case (.missingVariant(let id1), .missingVariant(let id2)):
            return id1 == id2
        case (.variantNotSupported(let id1), .variantNotSupported(let id2)):
            return id1 == id2
        default:
            return false
    }
}
