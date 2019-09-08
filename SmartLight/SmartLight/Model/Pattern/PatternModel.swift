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
    var items: [PatternItemModel] = []
    var manual: PatternItemModel?
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(items, forKey: "items")
        aCoder.encode(manual, forKey: "manual")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        items = aDecoder.decodeObject(forKey: "items") as? [PatternItemModel] ?? []
        manual = aDecoder.decodeObject(forKey: "manual") as? PatternItemModel
    }
}

class PatternItemModel: NSObject, NSCoding {
    var time: Int = 0
    var uv: Int = 0
    var db: Int = 0
    var b: Int = 0
    var g: Int = 0
    var dr: Int = 0
    var cw: Int = 0
    var all: Int = 0
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(uv, forKey: "uv")
        aCoder.encode(db, forKey: "db")
        aCoder.encode(b, forKey: "b")
        aCoder.encode(g, forKey: "g")
        aCoder.encode(dr, forKey: "dr")
        aCoder.encode(cw, forKey: "cw")
        aCoder.encode(all, forKey: "all")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        time = aDecoder.decodeInteger(forKey: "time")
        uv = aDecoder.decodeInteger(forKey: "uv")
        db = aDecoder.decodeInteger(forKey: "db")
        b = aDecoder.decodeInteger(forKey: "b")
        g = aDecoder.decodeInteger(forKey: "g")
        dr = aDecoder.decodeInteger(forKey: "dr")
        cw = aDecoder.decodeInteger(forKey: "cw")
        all = aDecoder.decodeInteger(forKey: "all")
    }
}
