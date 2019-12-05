//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  QRCodeHelper.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/20.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class QRCodeHelper: NSObject {
    func checkQR(content: String) -> [PatternItemModel] {
        if !content.hasPrefix("{") {
            return []
        }
        if !content.hasSuffix("}") {
            return []
        }
        var result : [[Int]] = []
        var str = content
        var read = true
        while read {
            if let range = str.range(of: "}"), let ran = str.range(of: "{") {
                read = true
                let subString = String(str[ran.upperBound..<range.lowerBound])
                let res = subString.split(separator: ",").map{Int($0) ?? 0}
                if res.count == 7 {
                    result.append(res)
                } else {
                    return []
                }
                if range.upperBound == str.endIndex {
                    read = false
                    break
                }
                str = String(str[range.upperBound...])
            } else {
                read = false
            }
        }
        
        if result.count > 0 {
            var array : [PatternItemModel] = []
            for item in result {
                let model = PatternItemModel()
                model.time = item[0]
                model.intensity = Array(item[1..<item.count])
                array.append(model)
            }
            return array
        }
        
        return []
    }
}
