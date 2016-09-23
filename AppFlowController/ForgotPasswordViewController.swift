//
//  ForgotPasswordViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBeingPresented {
            let button = UIButton()
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("Dismiss", for: .normal)
            button.sizeToFit()
            button.frame = CGRect(x: view.bounds.size.width - button.bounds.size.width - 20, y: 20, width: button.bounds.size.width, height: button.bounds.size.height)
            button.addTarget(self, action: #selector(ForgotPasswordViewController.dismissAction(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.login)
    }

    @IBAction func backToHomeAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.home)
    }
    
    func dismissAction(_ sender: AnyObject) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItems.login)
    }

}
