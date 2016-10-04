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
        flowController.register(path: AppPage.home => AppPage.registration)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login => AppPage.forgotPassword)
        flowController.register(path: AppPage.home => AppPage.items => AppPage.details)
        flowController.register(path: AppPage.home => alphaTransition => AppPage.login => DefaultModalFlowControllerTransition => AppPage.forgotPasswordAlert => AppPage.info)
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
        storyboardName: "Main",
        viewControllerType: HomeViewController.self
    )
   
    static let login = AppPage(
        name: "sign_in",
        storyboardName: "Main",
        viewControllerType: LoginViewController.self
    )
    
    static let registration = AppPage(
        name: "sign_up",
        storyboardName: "Main",
        viewControllerType: RegistrationViewController.self
    )
    
    static let forgotPassword = AppPage(
        name: "forgot_password",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let forgotPasswordAlert = AppPage(
        name: "forgot_password_alert",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let items = AppPage(
        name: "items",
        storyboardName: "Main",
        viewControllerType: ItemsTableViewController.self
    )
    
    static let details = AppPage(
        name: "details",
        storyboardName: "Main",
        viewControllerType: DetailsViewController.self
    )
    
    static let info = AppPage(
        name: "info",
        storyboardName: "Main",
        viewControllerType: InfoViewController.self
    )
    
    static let tabs = AppPage(
        name: "tabs",
        storyboardName: "Main",
        viewControllerType: TabBarViewController.self
    )
    
    static let tabPage1 = AppPage(
        name: "tabPage1",
        storyboardName: "Main",
        viewControllerType: TabPage1ViewController.self
    )
    
    static let tabPage2 = AppPage(
        name: "tabPage2",
        storyboardName: "Main",
        viewControllerType: TabPage2ViewController.self
    )
    
}

