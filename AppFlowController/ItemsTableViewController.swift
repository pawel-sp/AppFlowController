//
//  ItemsTableViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController {

    let data = Color.colors
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        cell.backgroundColor      = data[indexPath.row].uicolor
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text      = String(describing: data[indexPath.row].uicolor)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppFlowController.sharedController.show(item: TestAppFlowControllerItem.details)
    }
    
}
