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
    
    static func down() -> PatternListModel {
        if let data = UserDefaults.standard.object(forKey: "patterns") as? Data {
            guard let model = NSKeyedUnarchiver.unarchiveObject(with: data) as? PatternListModel else {
                return PatternListModel()
            }
            return model
        }
        var model = PatternListModel()
        model.patterns = preLoadData()
        return model
    }
    
    static func preLoadData() -> [PatternModel] {
        var array : [PatternModel] = []
        var model = PatternModel()
        model.name = "SPS"
        var items: [PatternItemModel] = []
        var item = PatternItemModel()
        item.time = 480
        item.intensity = [0, 0, 0, 0, 0, 0, 0]
        items.append(item)
        var itemB = PatternItemModel()
        itemB.time = 540
        itemB.intensity = [1, 1, 1, 0, 0, 0, 0]
        items.append(itemB)
        var itemC = PatternItemModel()
        itemC.time = 720
        itemC.intensity = [100, 75, 50, 0, 0, 0, 0]
        items.append(itemC)
        var itemD = PatternItemModel()
        itemD.time = 1020
        itemD.intensity = [75, 100, 50, 0, 0, 0, 0]
        items.append(itemD)
        var itemE = PatternItemModel()
        itemE.time = 1200
        itemE.intensity = [1, 1, 1, 0, 0, 0, 0]
        items.append(itemE)
        var itemF = PatternItemModel()
        itemF.time = 1260
        itemF.intensity = [0, 0, 0, 0, 0, 0, 0]
        items.append(itemF)
        array.append(model)
        
        var model2 = PatternModel()
        model2.name = "LPS"
        var items2: [PatternItemModel] = []
        var item2 = PatternItemModel()
        item2.time = 480
        item2.intensity = [0, 0, 0, 0, 0, 0, 0]
        items2.append(item2)
        var item2B = PatternItemModel()
        item2B.time = 540
        item2B.intensity = [1, 1, 1, 0, 0, 0, 0]
        items2.append(item2B)
        var item2C = PatternItemModel()
        item2C.time = 720
        item2C.intensity = [100, 50, 30, 0, 0, 0, 0]
        items2.append(item2C)
        var item2D = PatternItemModel()
        item2D.time = 1020
        item2D.intensity = [50, 100, 30, 0, 0, 0, 0]
        items2.append(item2D)
        var item2E = PatternItemModel()
        item2E.time = 1200
        item2E.intensity = [1, 1, 1, 0, 0, 0, 0]
        items2.append(item2E)
        var item2F = PatternItemModel()
        item2F.time = 1260
        item2F.intensity = [0, 0, 0, 0, 0, 0, 0]
        items2.append(item2F)
        array.append(model2)
        
        var model3 = PatternModel()
        model3.name = "FOT"
        var items3: [PatternItemModel] = []
        var item3 = PatternItemModel()
        item3.time = 480
        item3.intensity = [0, 0, 0, 0, 0, 0, 0]
        items3.append(item3)
        var item3B = PatternItemModel()
        item3B.time = 540
        item3B.intensity = [1, 1, 1, 0, 0, 0, 0]
        items3.append(item3B)
        var item3C = PatternItemModel()
        item3C.time = 720
        item3C.intensity = [50, 50, 30, 0, 0, 0, 0]
        items3.append(item3C)
        var item3D = PatternItemModel()
        item3D.time = 1020
        item3D.intensity = [50, 50, 30, 0, 0, 0, 0]
        items3.append(item3D)
        var item3E = PatternItemModel()
        item3E.time = 1200
        item3E.intensity = [1, 1, 1, 0, 0, 0, 0]
        items3.append(item3E)
        var item3F = PatternItemModel()
        item3F.time = 1260
        item3F.intensity = [0, 0, 0, 0, 0, 0, 0]
        items3.append(item3F)
        array.append(model3)
        
        var model4 = PatternModel()
        model4.name = "Reef Tank"
        var items4: [PatternItemModel] = []
        var item4 = PatternItemModel()
        item4.time = 480
        item4.intensity = [0, 0, 0, 0, 0, 0, 0]
        items4.append(item4)
        var item4B = PatternItemModel()
        item4B.time = 540
        item4B.intensity = [1, 1, 1, 0, 0, 0, 0]
        items4.append(item4B)
        var item4C = PatternItemModel()
        item4C.time = 720
        item4C.intensity = [75, 75, 50, 0, 0, 0, 0]
        items4.append(item4C)
        var item4D = PatternItemModel()
        item4D.time = 1020
        item4D.intensity = [75, 75, 50, 0, 0, 0, 0]
        items4.append(item4D)
        var item4E = PatternItemModel()
        item4E.time = 1200
        item4E.intensity = [1, 1, 1, 0, 0, 0, 0]
        items4.append(item4E)
        var item4F = PatternItemModel()
        item4F.time = 1260
        item4F.intensity = [0, 0, 0, 0, 0, 0, 0]
        items4.append(item4F)
        array.append(model4)
        
        var model5 = PatternModel()
        model5.name = "Planted"
        var items5: [PatternItemModel] = []
        var item5 = PatternItemModel()
        item5.time = 480
        item5.intensity = [0, 0, 0, 0, 0, 0, 0]
        items5.append(item5)
        var item5B = PatternItemModel()
        item5B.time = 540
        item5B.intensity = [1, 1, 1, 0, 0, 0, 0]
        items5.append(item5B)
        var item5C = PatternItemModel()
        item5C.time = 720
        item5C.intensity = [50, 75, 30, 0, 0, 0, 0]
        items5.append(item5C)
        var item5D = PatternItemModel()
        item5D.time = 1020
        item5D.intensity = [75, 50, 30, 0, 0, 0, 0]
        items5.append(item5D)
        var item5E = PatternItemModel()
        item5E.time = 1200
        item5E.intensity = [1, 1, 1, 0, 0, 0, 0]
        items5.append(item5E)
        var item5F = PatternItemModel()
        item5F.time = 1260
        item5F.intensity = [0, 0, 0, 0, 0, 0, 0]
        items5.append(item5F)
        array.append(model5)
        return array
    }
}
