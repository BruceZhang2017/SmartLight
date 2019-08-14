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
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(superModel, forKey: "superModel")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(child, forKey: "child")
        aCoder.encode(group, forKey: "group")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        superModel = aDecoder.decodeObject(forKey: "superModel") as? DeviceModel
        name = aDecoder.decodeObject(forKey: "name") as? String
        child = aDecoder.decodeObject(forKey: "child") as? Int ?? 0
        group = aDecoder.decodeObject(forKey: "group") as? Bool ?? false 
    }
}
