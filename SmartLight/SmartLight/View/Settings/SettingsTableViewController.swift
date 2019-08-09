//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  SettingsTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func currentDate() -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        dateFormate.timeStyle = .medium
        let date = Date()
        let stringOfDate = dateFormate.string(from: date)
        return stringOfDate
    }
    
    // MARK: - tableView Datasource & delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Arrays.settingHeadTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Arrays.settingTitles[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        cell.textLabel?.text = Arrays.settingTitles[indexPath.section][indexPath.row]
        cell.accessoryType = indexPath.section == 0 ? .disclosureIndicator : .none
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = currentDate()
            } else if indexPath.row == 2 {
                cell.detailTextLabel?.text = "English"
            } else if indexPath.row == 3 {
                
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section > 0 {
            return
        }
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDatePicker) as! DatePickerViewController
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
            present(viewController, animated: false, completion: nil)
        case 3:
            let url = URL(string: "https://www.micmol.com/apphelps/")
            let safariVC = SFSafariViewController(url: url!)
            present(safariVC, animated: true)
        default:
            print(0)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Arrays.settingHeadTitles[section]
    }
}
