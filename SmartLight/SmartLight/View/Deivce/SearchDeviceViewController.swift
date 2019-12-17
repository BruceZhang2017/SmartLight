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
import Toaster

class SearchDeviceViewController: BaseViewController {
    
    var results: [ESPTouchResult] = []
    var wifiList: [String : String] = [:]
    var controller: ESPController!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //results = [ESPTouchResult(isSuc: true, andBssid: "000000000000", andInetAddrData: Data(repeating: 0x00, count: 3))]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let ssid = WIFIManager().getSSID()
        let wifiList = UserDefaults.standard.object(forKey: .kWIFIPWD) as? [String : String] ?? [:]
        print("wifiList: \(wifiList)")
        let password = wifiList[ssid] ?? ""
        if password.count == 0 {
            showWifiAlert(ssid: ssid) // 显示输入密码的弹框
        } else {
            initializeSmartConfig()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearSmartConfig()
    }

    private func pushToMenu() {
        let storyboard = UIStoryboard(name: .kSBNameDevice, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceList) as! DeviceListViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// 初始化SmartConfig
    private func initializeSmartConfig() {
        if controller == nil {
            controller = ESPController(delegate: self)
        }
        controller?.tapConfirmForResults()
    }
    
    private func clearSmartConfig() {
        if controller == nil {
            return
        }
        controller?.tapConfirmForResults()
    }
    
    private func showWifiAlert(ssid: String) {
        let alert = UIAlertController(title: "txt_enterpassword".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert, weak self] (action) in
            guard let pwd = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), pwd.count > 0 else {
                return
            }
            self?.saveWIFI(ssid: ssid, pwd: pwd)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func saveWIFI(ssid: String, pwd: String) {
        wifiList[ssid] = pwd
        UserDefaults.standard.set(wifiList, forKey: .kWIFIPWD)
        UserDefaults.standard.synchronize()
        initializeSmartConfig()
    }

}

extension SearchDeviceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            if let bssid = results[indexPath.row].bssid, bssid.count > 4 {
                nameLabel.text = "Light_\(bssid[bssid.count - 4, bssid.count])"
            }
        }
        if let ipLabel = cell.viewWithTag(2) as? UILabel {
            ipLabel.text = results[indexPath.row].ip() ?? ""
        }
        return cell
    }
    
}

extension SearchDeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = DeviceManager.sharedInstance.deviceListModel
        if model.groups.count == 0 {
            guard let bssid = results[indexPath.row].bssid, bssid.count > 4 else {
                return
            }
            let device = DeviceModel() // 先添加一个设备
            device.name = "\(bssid)"
            device.ip = results[indexPath.row].ip()
            device.deviceState = 0x00
            device.deviceType = 3
            
            model.groups.append(device)
            DeviceManager.sharedInstance.save()
            pushToMenu()
            var viewControllers = navigationController!.viewControllers
            viewControllers.remove(at: 1)
            navigationController?.viewControllers = viewControllers
        } else {
            //self.performSegue(withIdentifier: .kSBSegueWIFIList, sender: self)
            var isAdd = false
            for device in model.groups {
                if device.ip == results[indexPath.row].ip() {
                    isAdd = true
                    break
                }
            }
            if !isAdd {
                guard let bssid = results[indexPath.row].bssid, bssid.count > 4 else {
                    return
                }
                let device = DeviceModel() // 先添加一个设备
                device.name = "\(bssid)"
                device.ip = results[indexPath.row].ip()
                device.deviceState = 0x00
                device.deviceType = 3
                model.groups.append(device)
                DeviceManager.sharedInstance.save()
            }
            pushToMenu()
            var viewControllers = navigationController!.viewControllers
            viewControllers.remove(at: 1)
            navigationController?.viewControllers = viewControllers
        }
    }
}

extension SearchDeviceViewController: ESPControllerDelegate {
    func scanWIFI(_ result: [ESPTouchResult]!) {
        if result == nil {
            results.removeAll()
            Toast(text: "Smartconfig失败，请退出重试").show()
            navigationController?.popViewController(animated: true)
        } else {
            results = result!
        }
        tableView.reloadData()
    }
}
