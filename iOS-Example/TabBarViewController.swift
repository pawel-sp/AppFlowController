//
//  TabBarViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class TabBarViewController: BaseTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Contact", style: .plain, target: self, action: #selector(TabBarViewController.showContact))
    }
    
    func showContact() {
        try! AppFlowController.shared.show(page: AppPage.contact, skipDismissTransitions: true)
    }
    
}
