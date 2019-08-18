//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  Cloudy.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/18.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class Cloudy: NSObject, NSCoding {
    var enable = false
    var startTime = 0
    var endTime = 0
    var speed = 0
    var intensity = 0
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(enable, forKey: "enable")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(speed, forKey: "speed")
        aCoder.encode(intensity, forKey: "intensity")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        enable = aDecoder.decodeBool(forKey: "enable")
        startTime = aDecoder.decodeInteger(forKey: "startTime")
        endTime = aDecoder.decodeInteger(forKey: "endTime")
        speed = aDecoder.decodeInteger(forKey: "speed")
        intensity = aDecoder.decodeInteger(forKey: "intensity")
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "Cloudy")
        UserDefaults.standard.synchronize()
    }
    
    static func load() -> Cloudy {
        if let data = UserDefaults.standard.object(forKey: "Cloudy") as? Data {
            let model = NSKeyedUnarchiver.unarchiveObject(with: data) as! Cloudy
            return model
        }
        return Cloudy()
    }
}



