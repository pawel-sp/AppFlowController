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
        let alpha = AlphaTransition()
        let modal = DefaultModalFlowTransition.default
        let tab = TabPageTransition()
        let out = OutOfTabsTransition()
        
        flowController.prepare(for: window!, rootNavigationController: RootNavigationController())
        
        do {
            try flowController.register(pathComponents:
                AppPathComponent.start =>
                    AppPathComponent.home =>> [
                        AppPathComponent.play,
                        alpha => AppPathComponent.registration => AppPathComponent.play,
                        AppPathComponent.login =>> [
                            modal => AppPathComponent.play,
                            AppPathComponent.forgotPassword => AppPathComponent.play,
                            modal => AppPathComponent.forgotPasswordAlert =>> [
                                AppPathComponent.play,
                                AppPathComponent.info => AppPathComponent.play
                            ]
                        ],
                        AppPathComponent.items => AppPathComponent.details => AppPathComponent.play,
                        AppPathComponent.tabs =>> [
                            out => AppPathComponent.contact,
                            tab => AppPathComponent.tabPage1 => AppPathComponent.subTabPage1,
                            tab => AppPathComponent.tabPage2 => AppPathComponent.subTabPage2
                        ],
                        AppPathComponent.custom => AppPathComponent.play,
                        AppPathComponent.container =>> [
                            ContainerTransition() => AppPathComponent.segment1,
                            ContainerTransition(loadPage: true) => AppPathComponent.segment2
                        ]
                ]
            )
        } catch let error {
            if let appFlowControllerError = error as? AFCError {
                fatalError(appFlowControllerError.info)
            } else {
                fatalError(error.localizedDescription)
            }
        }
        
        try! flowController.show(AppPathComponent.start)
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

class AppPathComponent {
    static let start = FlowPathComponent(
        name: "start",
        storyboardName: "Main",
        viewControllerType: StartViewController.self
    )
    
    static let home = FlowPathComponent(
        name: "home",
        storyboardName: "Main",
        viewControllerType: HomeViewController.self
    )
   
    static let login = FlowPathComponent(
        name: "sign_in",
        storyboardName: "Main",
        viewControllerType: LoginViewController.self
    )
    
    static let registration = FlowPathComponent(
        name: "sign_up",
        storyboardName: "Main",
        viewControllerType: RegistrationViewController.self
    )
    
    static let forgotPassword = FlowPathComponent(
        name: "forgot_password",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let forgotPasswordAlert = FlowPathComponent(
        name: "forgot_password_alert",
        storyboardName: "Main",
        viewControllerType: ForgotPasswordViewController.self
    )
    
    static let items = FlowPathComponent(
        name: "items",
        storyboardName: "Main",
        viewControllerType: ItemsTableViewController.self
    )
    
    static let details = FlowPathComponent(
        name: "details",
        storyboardName: "Main",
        viewControllerType: DetailsViewController.self
    )
    
    static let info = FlowPathComponent(
        name: "info",
        storyboardName: "Main",
        viewControllerType: InfoViewController.self
    )
    
    static let tabs = FlowPathComponent(
        name: "tabs",
        storyboardName: "Main",
        viewControllerType: TabBarViewController.self
    )
    
    static let tabPage1 = FlowPathComponent(
        name: "tabPage1",
        storyboardName: "Main",
        viewControllerType: TabPage1ViewController.self
    )
    
    static let tabPage2 = FlowPathComponent(
        name: "tabPage2",
        storyboardName: "Main",
        viewControllerType: TabPage2ViewController.self
    )
    
    static let subTabPage1 = FlowPathComponent(
        name: "subTabPage1",
        storyboardName: "Main",
        viewControllerType: SubTabPage1ViewController.self
    )
    
    static let subTabPage2 = FlowPathComponent(
        name: "subTabPage2",
        storyboardName: "Main",
        viewControllerType: SubTabPage2ViewController.self
    )
    
    static let play = FlowPathComponent(
        name: "play",
        supportVariants: true,
        storyboardName: "Main",
        viewControllerType: PlayViewController.self
    )
    
    static let custom = FlowPathComponent(
        name: "custom",
        storyboardName: "Main",
        viewControllerType: CustomViewController.self
    )
    
    static let contact = FlowPathComponent(
        name: "contact",
        storyboardName: "Main",
        viewControllerType: ContactViewController.self
    )
    
    static let container = FlowPathComponent(
        name: "container",
        storyboardName: "Main",
        viewControllerType: ContainerViewController.self
    )
    
    static let segment1 = FlowPathComponent(
        name: "segment1",
        storyboardName: "Main",
        viewControllerType: Segment1ViewController.self
    )
    
    static let segment2 = FlowPathComponent(
        name: "segment2",
        storyboardName: "Main",
        viewControllerType: Segment2ViewController.self
    )
}
