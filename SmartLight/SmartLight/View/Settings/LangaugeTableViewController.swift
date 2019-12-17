//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  LangaugeTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/9/4.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import Localize_Swift

class LangaugeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.cirBG
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String.kCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.kCellIdentifier, for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "English"
        } else {
            cell.textLabel?.text = "简体中文"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            Localize.setCurrentLanguage("en")
        } else {
            Localize.setCurrentLanguage("zh")
        }
        navigationController?.popViewController(animated: true)
    }

}
