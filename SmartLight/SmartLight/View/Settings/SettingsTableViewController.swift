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
    
    var currentDate: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncDatetime()
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private
    
    private func setLeftNavigationItem() {
        let leftItem = UIBarButtonItem(image: UIImage.top_menu, style: .plain, target: self, action: #selector(pushToMenu))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setRightNavigationItem() {
        let rightItem = UIBarButtonItem(image: UIImage.top_qrcode, style: .plain, target: self, action: #selector(pushToQRCode))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setTitleView() {
        navigationItem.titleView = UIImageView(image: UIImage.top_logo)
    }
    
    func syncDatetime() {
        let dateTime = UserDefaults.standard.object(forKey: "datetime") as? TimeInterval ?? 0
        if dateTime > 0 {
            currentDate = Date(timeIntervalSince1970: dateTime)
        } else {
            currentDate = Date()
        }
    }
    
    func saveDatetime() {
        UserDefaults.standard.set(currentDate, forKey: "datetime")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Action
    
    @objc private func pushToMenu() {
        let storyboard = UIStoryboard(name: .kSBNameDevice, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceList) as! DeviceListViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func pushToQRCode() {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")
        let vc = LBXScanViewController()
        vc.scanStyle = style
        vc.scanResultDelegate = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func currentDate(date: Date) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        dateFormate.timeStyle = .medium
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
        cell.accessoryType = indexPath.section == 0 || indexPath.row > 0 ? .disclosureIndicator : .none
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = currentDate(date: currentDate)
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
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: "OTA", sender: self)
            }
            return
        }
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDatePicker) as! DatePickerViewController
            viewController.delegate = self
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
            navigationController?.tabBarController?.present(viewController, animated: false, completion: nil)
        case 2:
            let viewController = LangaugeTableViewController()
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
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

extension SettingsTableViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}

extension SettingsTableViewController: DatePickerViewControllerDelegate {
    func datePickerView(value: Date) {
        currentDate = value
        tableView.reloadData()
        saveDatetime()
    }
}
