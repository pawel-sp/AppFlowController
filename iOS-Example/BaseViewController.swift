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
        let skip = [
            StartViewController.self,
            PlayViewController.self,
            ContactViewController.self,
            ContainerViewController.self,
            Segment1ViewController.self,
            Segment2ViewController.self
        ]
        
        if !skip.contains(where: { self.isKind(of: $0) }) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(BaseViewController.showPlayPage))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let path = AppFlowController.shared.currentPathDescription {
            print(path)
        }
    }
    
    func showPlayPage() {
        if let current = AppFlowController.shared.currentPathComponent {
            try! AppFlowController.shared.show(
                AppPathComponent.play,
                variant: current,
                parameters: [
                    TransitionParameter(
                        pathComponent: AppPathComponent.play,
                        variant: AppPathComponent.home,
                        value: "from_home"
                    )
                ]
            )
        }
    }
    
    deinit {
        print("\(type(of:self)) deallocated")
    }

}
