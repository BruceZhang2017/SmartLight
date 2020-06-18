//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DeviceOTAManager.swift
//  SmartLight
//
//  Created by ANKER on 2020/4/12.
//  Copyright © 2020 PDP-ACC. All rights reserved.
//
	

import UIKit

class DeviceOTAManager: NSObject {
    static let sharedInstance = DeviceOTAManager()
    var deviceOTAList: [String: Bool] = [:]
    
    func saveOTAState(ip: String) {
        UserDefaults.standard.set(true, forKey: ip)
        UserDefaults.standard.synchronize()
    }
    
    func clearOTAState() {
        for (ip, _) in deviceOTAList {
            UserDefaults.standard.set(false, forKey: ip)
        }
        deviceOTAList = [:]
    }
    
    func getOTAState(ip: String) -> Bool {
        return UserDefaults.standard.bool(forKey: ip)
    }
}
