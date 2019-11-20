//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DeviceModel.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/11.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class DeviceModel: NSObject, NSCoding {
    
    var superModel: DeviceModel?
    var name: String?
    var child = 0
    var group: Bool = false
    var pattern: PatternModel?
    var acclimation: Acclimation?
    var lunnar: Lunnar?
    var lightning: Lightning?
    var cloudy: Cloudy?
    var fan: Fan?
    var ip: String?
    var deviceType = 3 // 3和6
    var deviceState = 0 // 使用位来存储
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(superModel, forKey: "superModel")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(child, forKey: "child")
        aCoder.encode(group, forKey: "group")
        aCoder.encode(pattern, forKey: "pattern")
        aCoder.encode(acclimation, forKey: "acclimation")
        aCoder.encode(lunnar, forKey: "lunnar")
        aCoder.encode(lightning, forKey: "lightning")
        aCoder.encode(cloudy, forKey: "cloudy")
        aCoder.encode(fan, forKey: "fan")
        aCoder.encode(ip, forKey: "ip")
        aCoder.encode(deviceType, forKey: "deviceType")
        aCoder.encode(deviceState, forKey: "deviceState")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        superModel = aDecoder.decodeObject(forKey: "superModel") as? DeviceModel
        name = aDecoder.decodeObject(forKey: "name") as? String
        child = aDecoder.decodeInteger(forKey: "child")
        group = aDecoder.decodeBool(forKey: "group")
        pattern = aDecoder.decodeObject(forKey: "pattern") as? PatternModel
        acclimation = aDecoder.decodeObject(forKey: "acclimation") as? Acclimation
        lunnar = aDecoder.decodeObject(forKey: "lunnar") as? Lunnar
        lightning = aDecoder.decodeObject(forKey: "lightning") as? Lightning
        cloudy = aDecoder.decodeObject(forKey: "cloudy") as? Cloudy
        fan = aDecoder.decodeObject(forKey: "fan") as? Fan
        ip = aDecoder.decodeObject(forKey: "ip") as? String
        deviceType = aDecoder.decodeInteger(forKey: "deviceType")
        deviceState = aDecoder.decodeInteger(forKey: "deviceState")
    }
}
