//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DeviceManager.swift
//  SmartLight
//
//  Created by ANKER on 2019/9/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class DeviceManager: NSObject {
    static let sharedInstance = DeviceManager()
    var currentIndex = 0 // 当前设备编号
    var connectStatus: [String : Int] = [:]
    var deviceListModel: DeviceListModel = DeviceListModel()
    private var bDirectConnection = false
    
    override init() {
        super.init()
        deviceListModel = down()
        for device in deviceListModel.groups {
            setDeviceDefaultValue(device: device)
        }
        if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" && deviceListModel.groups.count == 0 {
            let device = DeviceModel() // 先添加一个设备
            device.name = "SmartLEDLight"
            device.macAddress = ""
            device.ip = "192.168.4.1"
            device.deviceState = 0x00
            device.deviceType = 3
            setDeviceDefaultValue(device: device)
            deviceListModel.groups.append(device)
            bDirectConnection = true
        }
    }
    
    func clearDirectConnection() {
        if !bDirectConnection {
            return
        }
        if deviceListModel.groups.count > 1 {
            return
        }
        if deviceListModel.groups[0].name != "SmartLEDLight" {
            return
        }
        if deviceListModel.groups[0].ip != "192.168.4.1" {
            return
        }
        deviceListModel.groups.removeAll()
        bDirectConnection = false
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        guard let tab = delegate.window?.rootViewController as? UITabBarController else {
            return
        }
        tab.selectedIndex = 0
        guard let controllers = tab.viewControllers, controllers.count > 0 else {
            return
        }
        for controller in controllers {
            if let nav = controller as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        }
    }
    
    func save() {
        if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" { // 如果是直连，不要保存
            return
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: deviceListModel)
        UserDefaults.standard.set(data, forKey: "devices")
        UserDefaults.standard.synchronize()
    }
    
    func down() -> DeviceListModel {
        if let data = UserDefaults.standard.object(forKey: "devices") as? Data {
            if let model = NSKeyedUnarchiver.unarchiveObject(with: data) as? DeviceListModel {
                return model
            }
        }
        return DeviceListModel()
    }
    
    private func setDeviceDefaultValue(device: DeviceModel) {
        if device.acclimation == nil {
            let model = Acclimation()
            model.startTime = 8 * 60 + 30
            model.endTime = 17 * 60 + 30
            model.ramp = 2
            model.intesity = [30, 60, 15, 0, 0, 0, 0]
            device.acclimation = model
        }
        
        if device.lunnar == nil {
            let lunnar = Lunnar()
            lunnar.startTime = 21 * 60
            lunnar.endTime = 6 * 60
            lunnar.intensity = 1
            device.lunnar = lunnar
        }
        
        if device.lightning == nil {
            let lighting = Lightning()
            lighting.startTime = 15 * 60
            lighting.endTime = 17 * 60
            lighting.interval = 2
            lighting.frequency = 4
            lighting.intensity = 50
            device.lightning = lighting
        }
        
        if device.cloudy == nil {
            let cloudy = Cloudy()
            cloudy.startTime = 12 * 60 + 30
            cloudy.endTime = 15 * 60
            cloudy.intensity = 60
            cloudy.speed = 10
            device.cloudy = cloudy
        }
        
        if device.fan == nil {
            let fan = Fan()
            fan.enable = 2
            fan.startTime = 10 * 60
            fan.endTime = 16 * 60
            fan.intensity = 60
            device.fan = fan
        }
    }
}
