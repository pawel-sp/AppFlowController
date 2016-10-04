//
//  AppDelegate.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let flowController  = AppFlowController.sharedController
        let alphaTransition = AlphaTransition()
        
        flowController.prepare(forWindow:window!)
        flowController.register(path: AppPage.home)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login)
        flowController.register(path: AppPage.home => AppPage.registration)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login => AppPage.forgotPassword)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login => DefaultModalFlowControllerTransition => AppPage.forgotPasswordAlert)
        flowController.register(path: AppPage.home => AppPage.items)
        flowController.register(path: AppPage.home => AppPage.items => AppPage.details)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login => DefaultModalFlowControllerTransition => AppPage.forgotPasswordAlert => AppPage.info)
        
        flowController.register(path: AppPage.home => AppPage.tabs)
        flowController.register(path: AppPage.home => AppPage.tabs => DefaultTabBarControllerPageTransition => AppPage.tabPage1)
        flowController.register(path: AppPage.home => AppPage.tabs => DefaultTabBarControllerPageTransition => AppPage.tabPage2)
        
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
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoViewController") },
        viewControllerType: InfoViewController.self
    )
    
    static let tabs = AppPage(
        name: "tabs",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") },
        viewControllerType: TabBarViewController.self
    )
    
    static let tabPage1 = AppPage(
        name: "tabPage1",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabPage1ViewController") },
        viewControllerType: TabPage1ViewController.self
    )
    
    static let tabPage2 = AppPage(
        name: "tabPage2",
        viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabPage2ViewController") },
        viewControllerType: TabPage2ViewController.self
    )
    
}

