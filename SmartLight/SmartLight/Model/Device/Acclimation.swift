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
    var startTime: Int = 0
    var endTime: Int = 0
    var ramp: Int = 0
    var intesity: [Int] = [0, 0, 0, 0, 0, 0, 0] // UV DB B G DR CW ALL 或者 CH1 CH2 CH3 ALL
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(ramp, forKey: "ramp")
        aCoder.encode(intesity, forKey: "intesity")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        startTime = aDecoder.decodeInteger(forKey: "startTime")
        endTime = aDecoder.decodeInteger(forKey: "endTime")
        ramp = aDecoder.decodeInteger(forKey: "ramp")
        intesity = aDecoder.decodeObject(forKey: "intesity") as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]
    }

}
