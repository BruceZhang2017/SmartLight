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
}
