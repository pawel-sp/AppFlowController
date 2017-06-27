//
//  ContainerViewController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 27.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

protocol ContainerViewControllerInterface {
    
    var containerView: UIView! { get }
    func addChildViewController(_ childController: UIViewController)
    var childViewControllers: [UIViewController] { get }
    
}

class ContainerViewController: BaseViewController, ContainerViewControllerInterface {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var segmentDictionary:[Int:AppFlowControllerPage] = [
        0 : AppPage.segment1,
        1 : AppPage.segment2
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentPage = AppFlowController.shared.currentPage(), let index = segmentDictionary.first(where: { $0.value.identifier == currentPage.identifier })?.key {
            segmentedControl.selectedSegmentIndex = index
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let first = containerView.subviews.first {
            first.frame = containerView.bounds
        }
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        try! AppFlowController.shared.show(page: segmentDictionary[sender.selectedSegmentIndex]!)
    }
    
}
