//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  PatternListModel.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/14.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class PatternListModel: NSObject, NSCoding {
    var patterns: [PatternModel] = []
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(patterns, forKey: "patterns")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        patterns = aDecoder.decodeObject(forKey: "patterns") as? [PatternModel] ?? []
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "patterns")
        UserDefaults.standard.synchronize()
    }
    
    static func load() -> PatternListModel {
        if let data = UserDefaults.standard.object(forKey: "patterns") as? Data {
            guard let model = NSKeyedUnarchiver.unarchiveObject(with: data) as? PatternListModel else {
                return PatternListModel()
            }
            return model
        }
        return PatternListModel()
    }
}
