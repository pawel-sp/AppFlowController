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
        
        let flowController = AppFlowController.shared
        let alpha          = AlphaTransition()
        let modal          = ModalAppFlowControllerTransition()
        let tab            = TabBarAppFlowControllerTransition.default
        
        flowController.prepare(forWindow:window!)
        
        flowController.register(path:
            AppPage.start =>
            AppPage.home =>> [
                alpha => AppPage.registration,
                AppPage.login =>> [
                    AppPage.forgotPassword,
                    modal => AppPage.forgotPasswordAlert => AppPage.info
                ],
                AppPage.items => AppPage.details,
                AppPage.tabs =>> [
                    tab => AppPage.tabPage1,
                    tab => AppPage.tabPage2
                ]
            ]
        )
        
        // old way for registering paths - it's still working anyway!
//        flowController.register(path: AppPage.home => alpha => AppPage.registration)
//        flowController.register(path: AppPage.home => AppPage.login => AppPage.forgotPassword)
//        flowController.register(path: AppPage.home => AppPage.items => AppPage.details)
//        flowController.register(path: AppPage.home => AppPage.login => modal => AppPage.forgotPasswordAlert => AppPage.info)
//        flowController.register(path: AppPage.home => AppPage.tabs => tab => AppPage.tabPage1)
//        flowController.register(path: AppPage.home => AppPage.tabs => tab => AppPage.tabPage2)
        
        flowController.show(item:AppPage.start)
        return true
    }

}

class AppPage {
    
    // MARK: - Pages

    static let start = AppFlowControllerPage(
        name: "start",
        storyboardName: "Main",
        viewControllerType: StartViewController.self
    )
    
    static let home = AppFlowControllerPage(
        name: "home",
        storyboardName: "Main",
        viewControllerType: HomeViewController.self
    )
   
    static let login = AppFlowControllerPage(
        name: "sign_in",
        storyboardName: "Main",
        viewControllerType: LoginViewController.self
    )
    
    static let registration = AppFlowControllerPage(
        name: "sign_up",
        storyboardName: "Main",
        viewControllerType: RegistrationViewController.self
    )
    
    static let forgotPassword = AppFlowControllerPage(
        name: "forgot_password",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let forgotPasswordAlert = AppFlowControllerPage(
        name: "forgot_password_alert",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let items = AppFlowControllerPage(
        name: "items",
        storyboardName: "Main",
        viewControllerType: ItemsTableViewController.self
    )
    
    static let details = AppFlowControllerPage(
        name: "details",
        storyboardName: "Main",
        viewControllerType: DetailsViewController.self
    )
    
    static let info = AppFlowControllerPage(
        name: "info",
        storyboardName: "Main",
        viewControllerType: InfoViewController.self
    )
    
    static let tabs = AppFlowControllerPage(
        name: "tabs",
        storyboardName: "Main",
        viewControllerType: TabBarViewController.self
    )
    
    static let tabPage1 = AppFlowControllerPage(
        name: "tabPage1",
        storyboardName: "Main",
        viewControllerType: TabPage1ViewController.self
    )
    
    static let tabPage2 = AppFlowControllerPage(
        name: "tabPage2",
        storyboardName: "Main",
        viewControllerType: TabPage2ViewController.self
    )
    
}

