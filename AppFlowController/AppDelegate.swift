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
        flowController.register(pathArray:  TestAppFlowControllerItems.home => TestAppFlowControllerItems.login)
        flowController.register(pathArray:  TestAppFlowControllerItems.home => TestAppFlowControllerItems.registration)
        flowController.register(pathArray:  TestAppFlowControllerItems.home => TestAppFlowControllerItems.login => TestAppFlowControllerItems.forgotPassword)
        flowController.show(item:TestAppFlowControllerItems.home)
        
        return true
    }

}

enum TestAppFlowControllerItems: String, AppFlowControllerItem {
    
    case home           = "home"
    case login          = "sign_in"
    case registration   = "sign_up"
    case forgotPassword = "forgot_password"
    
    var name: String {
        return self.rawValue
    }
    
    var viewController: UIViewController {
        switch self {
            case .home:           return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            case .login:          return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            case .registration:   return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationViewController")
            case .forgotPassword: return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
        }
    }
    
}
