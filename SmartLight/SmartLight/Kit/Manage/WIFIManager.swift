//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  WIFIManager.swift
//  SmartLight
//
//  Created by ANKER on 2019/9/4.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class WIFIManager: NSObject {
    func getSSID() -> String {
        var wifiName : String = ""
        let wifiInterfaces = CNCopySupportedInterfaces()
        if wifiInterfaces == nil {
            return "no name"
        }
        
        let interfaceArr = CFBridgingRetain(wifiInterfaces!) as! Array<String>
        if interfaceArr.count > 0 {
            let interfaceName = interfaceArr[0] as CFString
            let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
            
            if (ussafeInterfaceData != nil) {
                let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                wifiName = interfaceData["SSID"]! as! String
            }
        }
        return wifiName
    }
}
