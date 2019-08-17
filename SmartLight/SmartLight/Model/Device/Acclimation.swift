//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  Acclimation.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/17.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class Acclimation: NSObject, NSCoding {
    var enable = false
    var startTime = 0
    var endTime = 0
    var ramp = 0
    var intesity: [Int] = [0, 0, 0, 0, 0, 0, 0]
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(enable, forKey: "enable")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(ramp, forKey: "ramp")
        aCoder.encode(intesity, forKey: "intesity")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        enable = aDecoder.decodeObject(forKey: "enable") as? Bool ?? false
        startTime = aDecoder.decodeObject(forKey: "startTime") as? Int ?? 0
        endTime = aDecoder.decodeObject(forKey: "endTime") as? Int ?? 0
        ramp = aDecoder.decodeObject(forKey: "ramp") as? Int ?? 0
        intesity = aDecoder.decodeObject(forKey: "intesity") as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "Acclimation")
    }
    
    static func load() -> Acclimation {
        if let data = UserDefaults.standard.object(forKey: "Acclimation") as? Data {
            let model = NSKeyedUnarchiver.unarchiveObject(with: data) as! Acclimation
            return model
        }
        return Acclimation()
    }
}
