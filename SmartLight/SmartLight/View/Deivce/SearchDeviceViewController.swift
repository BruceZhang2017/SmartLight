//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  SearchDeviceViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/11.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class SearchDeviceViewController: UIViewController {
    
    var wifiName = ""

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let wifiManager = WIFIManager()
        wifiName = wifiManager.getSSID()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }

    private func pushToMenu() {
        let storyboard = UIStoryboard(name: .kSBNameDevice, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceList) as! DeviceListViewController
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension SearchDeviceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = wifiName
        }
        return cell
    }
    
}

extension SearchDeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = DeviceListModel.down()
        if model.groups.count == 0 {
            let device = DeviceModel() // 先添加一个设备
            device.name = "no name"
            model.groups.append(device)
            model.save()
            pushToMenu()
            var viewControllers = navigationController!.viewControllers
            viewControllers.remove(at: 1)
            navigationController?.viewControllers = viewControllers
        } else {
            self.performSegue(withIdentifier: .kSBSegueWIFIList, sender: self)
        }
    }
}
