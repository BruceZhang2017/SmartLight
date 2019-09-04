//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsSettingTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/8.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class EffectsSettingTableViewController: UITableViewController {
    
    let colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6, Color.yellow]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.cirBG
        tableView.register(UINib(nibName: .kEffectsSettingTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellIdentifier)
        tableView.register(UINib(nibName: .kEffectsSettingBTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellBIdentifier)
        tableView.register(UINib(nibName: .kEffectsSettingCTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellCIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
