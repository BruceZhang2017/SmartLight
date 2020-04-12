//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  CheckDeviceState.swift
//  SmartLight
//
//  Created by ANKER on 2020/4/12.
//  Copyright © 2020 PDP-ACC. All rights reserved.
//
	

import UIKit

class CheckDeviceState: NSObject {
    func checkCurrentDeviceStateIsAllOnOrAllOff() -> Bool {
        let current = DeviceManager.sharedInstance.currentIndex
        if current >= DeviceManager.sharedInstance.deviceListModel.groups.count {
            return false
        }
        let device = DeviceManager.sharedInstance.deviceListModel.groups[current]
        let allOff = (device.deviceState >> 7) & 0x0f
        let allOn = device.deviceState & 0x02
        if allOff > 0 || allOn > 0 {
            return true
        }
        return false
    }
}
