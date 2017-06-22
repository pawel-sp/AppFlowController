//
//  BaseViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if !isKind(of: PlayViewController.self) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(BaseViewController.showPlayPage))
        }
    }
    
    func showPlayPage() {
        var parameters:[AppFlowControllerPage:String]?
        if isKind(of: HomeViewController.self) {
            parameters = [AppPage.play : "from_home"]
        }
        if let current = AppFlowController.shared.currentItem() {
            AppFlowController.shared.show(
                item: AppPage.play,
                variant: current,
                parameters: parameters
            )
        }
        
    }
    
    deinit {
        print("\(type(of:self)) deallocated")
    }

}
