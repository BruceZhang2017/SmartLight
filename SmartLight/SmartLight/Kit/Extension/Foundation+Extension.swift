//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  Foundation+Extension.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/4.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import Foundation

extension String {
    static let kWIFIPWD = "wifiPWD" // 保存wifi密码
}

extension String {
    func timeStrToInt() -> Int {
        let array = self.split(separator: ":")
        if array.count == 2 {
            return (Int(String(array[0])) ?? 0) * 60 + (Int(String(array[1])) ?? 0)
        }
        return 0
    }
    
    subscript(start: Int, end: Int) -> String {
        let s = index(startIndex, offsetBy: start)
        let e = index(startIndex, offsetBy: end)
        return String(self[s..<e])
    }
    
    func macStrToMacAddress() -> String {
        let count = self.count
        if count % 2 != 0 {
            return ""
        }
        var mac = ""
        for i in 0..<count / 2 {
            let start = index(startIndex, offsetBy: i * 2)
            let end = index(startIndex, offsetBy: (i + 1) * 2)
            mac.append(String(uppercased()[start..<end]))
            if i != count / 2 - 1 {
                mac.append(":")
            }
        }
        return mac
    }
}

extension Int {
    func timeIntToStr() -> String {
        var h = self / 60
        let m = self % 60
        if Kit().getDeviceTimeSystemIs12() {
            if h > 12 {
                return "\(String(format: "%02i", h - 12)):\(String(format: "%02i", m)) " + "pm".localized()
            } else {
                if h == 0 {
                    h = 12
                }
                return "\(String(format: "%02i", h)):\(String(format: "%02i", m)) " + "am".localized()
            }
        } else {
            return "\(String(format: "%02i", h)):\(String(format: "%02i", m))"
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx ", $0) }.joined()
    }
}

extension Date {
    static func is12Or24hour() -> Bool {
        let formatStringForHours = DateFormatter.dateFormat(
            fromTemplate: "j",
            options: 0,
            locale: Locale.current)
        return formatStringForHours?.contains("a") ?? false
    }
}
