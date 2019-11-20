//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  PatternModel.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/14.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class PatternModel: NSObject,NSCoding {
    var name = ""
    var isManual = false
    var items: [PatternItemModel] = []
    var manual: PatternItemModel?
    var deviceType = 3 // 3和6
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(items, forKey: "items")
        aCoder.encode(manual, forKey: "manual")
        aCoder.encode(isManual, forKey: "isManual")
        aCoder.encode(deviceType, forKey: "deviceType")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        items = aDecoder.decodeObject(forKey: "items") as? [PatternItemModel] ?? []
        manual = aDecoder.decodeObject(forKey: "manual") as? PatternItemModel
        isManual = aDecoder.decodeBool(forKey: "isManual")
        deviceType = aDecoder.decodeInteger(forKey: "deviceType")
    }
}

class PatternItemModel: NSObject, NSCoding {
    var time: Int = 0
    var intensity: [Int] = [0, 0, 0, 0, 0, 0, 0] // // UV DB B G DR CW ALL 或者 CH1 CH2 CH3 ALL
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(intensity, forKey: "intensity")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        time = aDecoder.decodeInteger(forKey: "time")
        intensity = aDecoder.decodeObject(forKey: "intensity") as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]
    }
}
