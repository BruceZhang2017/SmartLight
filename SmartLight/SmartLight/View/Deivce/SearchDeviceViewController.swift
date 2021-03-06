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
    @IBOutlet weak var topLabel: UILabel!
    var controller: ESPController!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topLabel.text = "txt_deviceslist_top".localized()
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
            let pwd = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
    
    private func setDeviceDefaultValue(device: DeviceModel) {
        let model = Acclimation()
        model.startTime = 8 * 60 + 30
        model.endTime = 17 * 60 + 30
        model.ramp = 2
        model.intesity = [30, 60, 15, 0, 0, 0, 0]
        device.acclimation = model
        
        let lunnar = Lunnar()
        lunnar.startTime = 21 * 60
        lunnar.endTime = 6 * 60
        lunnar.intensity = 1
        device.lunnar = lunnar
        
        let lighting = Lightning()
        lighting.startTime = 15 * 60
        lighting.endTime = 17 * 60
        lighting.interval = 2
        lighting.frequency = 4
        lighting.intensity = 50
        device.lightning = lighting
        
        let cloudy = Cloudy()
        cloudy.startTime = 12 * 60 + 30
        cloudy.endTime = 15 * 60
        cloudy.intensity = 60
        cloudy.speed = 10
        device.cloudy = cloudy
        
        let fan = Fan()
        fan.enable = 2
        fan.startTime = 10 * 60
        fan.endTime = 16 * 60
        fan.intensity = 60
        device.fan = fan
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
                nameLabel.text = "\(bssid)"
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
            device.macAddress = bssid.macStrToMacAddress()
            device.ip = results[indexPath.row].ip()
            device.deviceState = 0x00
            device.deviceType = 3
            setDeviceDefaultValue(device: device)
            model.groups.append(device)
            DeviceManager.sharedInstance.save()
            pushToMenu()
            var viewControllers = navigationController!.viewControllers
            viewControllers.remove(at: 1)
            navigationController?.viewControllers = viewControllers
        } else {
            guard let bssid = results[indexPath.row].bssid, bssid.count > 4 else {
                return
            }
            let mac = bssid.macStrToMacAddress()
            var isAdd = false
            for (key, device) in model.groups.enumerated() {
                if device.group == true {
                
                } else {
                    if device.macAddress == mac {
                        isAdd = true
                        device.ip = results[indexPath.row].ip()
                        model.groups[key] = device
                        DeviceManager.sharedInstance.save()
                        break
                    }
                }
            }
            if !isAdd {
                let device = DeviceModel() // 先添加一个设备
                device.name = "\(bssid)"
                device.macAddress = bssid.macStrToMacAddress()
                device.ip = results[indexPath.row].ip()
                device.deviceState = 0x00
                device.deviceType = 3
                model.groups.append(device)
                setDeviceDefaultValue(device: device)
                DeviceManager.sharedInstance.save()
            }
            var viewControllers = navigationController!.viewControllers
            for viewController in viewControllers {
                if viewController is DeviceListViewController {
                    navigationController?.popToViewController(viewController, animated: true)
                    return
                }
            }
            pushToMenu()
            viewControllers = navigationController!.viewControllers
            viewControllers.remove(at: 1)
            navigationController?.viewControllers = viewControllers
        }
    }
}

extension SearchDeviceViewController: ESPControllerDelegate {
    func callbackForBadScan() {
        DispatchQueue.main.async {
            [weak self] in
            Toast(text: "请开启WIFI").show()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func scanWIFI(_ result: [ESPTouchResult]!) {
        if result == nil {
            results.removeAll()
            //Toast(text: "Smartconfig失败，请退出重试").show()
            //navigationController?.popViewController(animated: true)
            controller?.tapConfirmForResults()
            controller?.tapConfirmForResults()
        } else {
            results = result!
        }
        tableView.reloadData()
    }
}
