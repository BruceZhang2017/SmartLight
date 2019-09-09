//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DeviceListModel.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/11.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class DeviceListModel: NSObject, NSCoding {
    var groups: [DeviceModel] = []
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(groups, forKey: "group")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        groups = aDecoder.decodeObject(forKey: "group") as? [DeviceModel] ?? []
    }
}
