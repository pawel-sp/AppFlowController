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
        flowController.register(path: TestAppFlowControllerItem.home)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.login)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.registration)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.login => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.forgotPassword)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.login => DefaultModalFlowControllerTransition => TestAppFlowControllerItem.forgotPasswordAlert)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.items)
        flowController.register(path: TestAppFlowControllerItem.home => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.items => DefaultPushPopAppFlowControllerTransition => TestAppFlowControllerItem.details)
        flowController.show(item:TestAppFlowControllerItem.home)
        
        return true
    }

}

class TestAppFlowControllerItem:AppFlowControllerItem {
    
    // MARK: - Properties
    
    var name:String
    var viewController: UIViewController
    var viewControllerType: UIViewController.Type
    var forwardTransition: AppFlowControllerForwardTransition?
    var backwardTransition: AppFlowControllerBackwardTransition?
    
    static let home                = TestAppFlowControllerItem(name: "home", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") }, viewControllerType: HomeViewController.self)
    static let login               = TestAppFlowControllerItem(name: "sign_in", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") }, viewControllerType: LoginViewController.self)
    static let registration        = TestAppFlowControllerItem(name: "sign_up", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationViewController") }, viewControllerType: RegistrationViewController.self)
    static let forgotPassword      = TestAppFlowControllerItem(name: "forgot_password", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") }, viewControllerType: ForgotPasswordViewController.self)
    static let forgotPasswordAlert = TestAppFlowControllerItem(name: "forgot_password_alert", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController")
 }, viewControllerType: ForgotPasswordViewController.self)
    static let items               = TestAppFlowControllerItem(name: "items", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemsTableViewController") }, viewControllerType: ItemsTableViewController.self)
    static let details             = TestAppFlowControllerItem(name: "details", viewControllerBlock: { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") }, viewControllerType: DetailsViewController.self)
    
    // MARK: - Init
    
    init(
        name:String,
        viewControllerBlock:()->(UIViewController),
        viewControllerType:UIViewController.Type
        ) {
        self.name               = name
        self.viewController     = viewControllerBlock()
        self.viewControllerType = viewControllerType
    }
    
}

