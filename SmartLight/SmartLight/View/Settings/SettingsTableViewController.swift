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
import Localize_Swift

class SettingsTableViewController: UITableViewController {
    
    var currentDate: Date!
    var scan: LBXScanViewController!
    var titles: [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        syncDatetime()
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "txt_settings".localized()
        self.navigationController?.navigationBar.barTintColor = Color.main
        self.navigationController?.navigationBar.tintColor = UIColor.white
        titles = Arrays.settingTitles
        tableView.reloadData()
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
        title = "back".localized()
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
        scan = LBXScanViewController()
        scan.scanStyle = style
        scan.scanResultDelegate = self
        scan.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scan, animated: true)
    }
    
    private func currentDate(date: Date) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringOfDate = dateFormate.string(from: date)
        return stringOfDate
    }
    
    private func showWifiAlert() {
        let ssid = WIFIManager().getSSID()
        var wifiList = UserDefaults.standard.object(forKey: .kWIFIPWD) as? [String : String] ?? [:]
        let password = wifiList[ssid] ?? ""
        let alert = UIAlertController(title: password.count > 0 ? "Update Password" : "Password", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert] (action) in
            guard let pwd = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), pwd.count > 0 else {
                return
            }
            wifiList[ssid] = pwd
            UserDefaults.standard.set(wifiList, forKey: .kWIFIPWD)
            UserDefaults.standard.synchronize()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func getCurrentLanguage() -> String {
        let currentLanguage = Localize.currentLanguage()
        if currentLanguage.contains("zh") {
            return "简体中文"
        }
        return "English"
    }
    
    // MARK: - tableView Datasource & delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        cell.textLabel?.text = titles[indexPath.section][indexPath.row].localized()
        cell.accessoryType = indexPath.section == 0 || indexPath.row > 0 ? .disclosureIndicator : .none
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = currentDate(date: currentDate)
            } else if indexPath.row == 1 {
                cell.detailTextLabel?.text = WIFIManager().getSSID()
            } else if indexPath.row == 2 {
                cell.detailTextLabel?.text = getCurrentLanguage()
            } else if indexPath.row == 3 {
                
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = firmwareVersion
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
        case 1:
            showWifiAlert()
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
        return Arrays.settingHeadTitles[section].localized()
    }
}

extension SettingsTableViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let result = scanResult.strScanned {
            let array = QRCodeHelper().checkQR(content: result)
            if array.count > 0 {
                let alert = UIAlertController(title: "txt_preset_overwrite".localized(), message: "txt_preset_overwrite_hint".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: {[weak self] (action) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
                    let models = DeviceManager.sharedInstance.deviceListModel.groups
                    let current = DeviceManager.sharedInstance.currentIndex
                    if current < models.count {
                        models[current].pattern?.items = array
                    }
                    DeviceManager.sharedInstance.deviceListModel.groups = models
                    DeviceManager.sharedInstance.save()
                    NotificationCenter.default.post(name: Notification.Name("ControlViewController"), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                }))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        let alert = UIAlertController(title: "Unaval", message: "No data found.Continue to scan?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: {[weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
            self?.scan?.startScan()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsTableViewController: DatePickerViewControllerDelegate {
    func datePickerView(value: Date) {
        currentDate = value
        tableView.reloadData()
        saveDatetime()
    }
}
