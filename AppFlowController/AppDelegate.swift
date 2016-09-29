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
        flowController.register(path: AppPage.home)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.login)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.registration)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.login => DefaultPushPopAppFlowControllerTransition => AppPage.forgotPassword)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.login => DefaultModalFlowControllerTransition => AppPage.forgotPasswordAlert)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.items)
        flowController.register(path: AppPage.home => DefaultPushPopAppFlowControllerTransition => AppPage.items => DefaultPushPopAppFlowControllerTransition => AppPage.details)
        flowController.show(item:AppPage.home)
        
        return true
    }

}

class AppPage:AppFlowControllerPage {
    
    // MARK: - Pages

    static let home = AppPage(
        name: "home",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") },
        viewControllerType: HomeViewController.self
    )
    
    static let login = AppPage(
        name: "sign_in",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") },
        viewControllerType: LoginViewController.self
    )
    
    static let registration = AppPage(
        name: "sign_up",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationViewController") },
        viewControllerType: RegistrationViewController.self
    )
    
    static let forgotPassword = AppPage(
        name: "forgot_password",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") },
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let forgotPasswordAlert = AppPage(
        name: "forgot_password_alert",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") },
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let items = AppPage(
        name: "items",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemsTableViewController") },
        viewControllerType: ItemsTableViewController.self
    )
    
    static let details = AppPage(
        name: "details",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") },
        viewControllerType: DetailsViewController.self
    )
    
    static let info = AppPage(
        name: "info",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") },
        viewControllerType: InfoViewController.self
    )
    
}

