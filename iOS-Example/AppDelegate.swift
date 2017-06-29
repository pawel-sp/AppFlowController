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
        
        let flowController  = AppFlowController.shared
        let alpha           = AlphaTransition()
        let modal           = DefaultModalAppFlowControllerTransition.default
        let tab             = TabPageTransition()
        let out             = OutOfTabsTransition()
        
        flowController.prepare(for:window!, rootNavigationController:RootNavigationController())
        
        do {
            try flowController.register(path:
                AppPage.start =>
                    AppPage.home =>> [
                        AppPage.play,
                        alpha => AppPage.registration => AppPage.play,
                        AppPage.login =>> [
                            modal => AppPage.play,
                            AppPage.forgotPassword => AppPage.play,
                            modal => AppPage.forgotPasswordAlert =>> [
                                AppPage.play,
                                AppPage.info => AppPage.play
                            ]
                        ],
                        AppPage.items => AppPage.details => AppPage.play,
                        AppPage.tabs =>> [
                            out => AppPage.contact,
                            tab => AppPage.tabPage1 => AppPage.subTabPage1,
                            tab => AppPage.tabPage2 => AppPage.subTabPage2
                        ],
                        AppPage.custom => AppPage.play,
                        AppPage.container =>> [
                            ContainerTransition() => AppPage.segment1,
                            ContainerTransition(loadPage: true) => AppPage.segment2
                        ]
                ]
            )
        } catch let error {
            if let appFlowControllerError = error as? AppFlowControllerError {
                fatalError(appFlowControllerError.info)
            } else {
                fatalError(error.localizedDescription)
            }
        }
        
        try! flowController.show(page:AppPage.start)
        return true
    }

}

class RootNavigationController: UINavigationController {
    
    override var visibleViewController: UIViewController? {
        if let containerViewController = super.visibleViewController as? ContainerViewControllerInterface {
            return containerViewController.childViewControllers.first ?? super.visibleViewController
        } else {
            return super.visibleViewController
        }
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
    
    static let subTabPage1 = AppFlowControllerPage(
        name: "subTabPage1",
        storyboardName: "Main",
        viewControllerType: SubTabPage1ViewController.self
    )
    
    static let subTabPage2 = AppFlowControllerPage(
        name: "subTabPage2",
        storyboardName: "Main",
        viewControllerType: SubTabPage2ViewController.self
    )
    
    static let play = AppFlowControllerPage(
        name: "play",
        supportVariants: true,
        storyboardName: "Main",
        viewControllerType: PlayViewController.self
    )
    
    static let custom = AppFlowControllerPage(
        name: "custom",
        storyboardName: "Main",
        viewControllerType: CustomViewController.self
    )
    
    static let contact = AppFlowControllerPage(
        name: "contact",
        storyboardName: "Main",
        viewControllerType: ContactViewController.self
    )
    
    static let container = AppFlowControllerPage(
        name: "container",
        storyboardName: "Main",
        viewControllerType: ContainerViewController.self
    )
    
    static let segment1 = AppFlowControllerPage(
        name: "segment1",
        storyboardName: "Main",
        viewControllerType: Segment1ViewController.self
    )
    
    static let segment2 = AppFlowControllerPage(
        name: "segment2",
        storyboardName: "Main",
        viewControllerType: Segment2ViewController.self
    )
    
}

