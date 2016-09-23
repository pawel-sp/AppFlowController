//
//  AppDelegate.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let flowController = AppFlowController.sharedController
        flowController.prepare(forWindow:window!)
        flowController.register(path: TestAppFlowControllerItems.home)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.login)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.registration)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.login => TestAppFlowControllerItems.forgotPassword)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.login => TestAppFlowControllerItems.forgotPasswordAlert)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.items)
        flowController.register(path: TestAppFlowControllerItems.home => TestAppFlowControllerItems.items => TestAppFlowControllerItems.details)
        flowController.show(item:TestAppFlowControllerItems.details, withParameter: "red")
        
        return true
    }

}

enum TestAppFlowControllerItems: String, AppFlowControllerItem {
    
    case home                = "home"
    case login               = "sign_in"
    case registration        = "sign_up"
    case forgotPassword      = "forgot_password"
    case forgotPasswordAlert = "forgot_password_alert"
    case items               = "items"
    case details             = "details"
    
    var name: String {
        return self.rawValue
    }
    
    var viewController: UIViewController {
        switch self {
            case .home:                return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            case .login:               return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            case .registration:        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationViewController")
            case .forgotPassword:      return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
            case .forgotPasswordAlert: return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
            case .items:               return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemsTableViewController")
            case .details:             return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController")
        }
    }
    
    var viewControllerType: UIViewController.Type {
        switch self {
            case .home:                return HomeViewController.self
            case .login:               return LoginViewController.self
            case .registration:        return RegistrationViewController.self
            case .forgotPassword:      return ForgotPasswordViewController.self
            case .forgotPasswordAlert: return ForgotPasswordViewController.self
            case .items:               return ItemsTableViewController.self
            case .details:             return DetailsViewController.self
        }
    }
    
    var isModal:Bool {
        switch self {
            case .forgotPasswordAlert: return true
            default:                   return false
        }
    }

}
