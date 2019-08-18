//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  Kit.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/18.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class Kit: NSObject {
    // 判断手机系统时间是12进制还是24进制
    func getDeviceTimeSystemIs12() -> Bool {
        let dateFormatter = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)
        return dateFormatter?.contains("a") ?? false
    }
}
