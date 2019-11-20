//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  CurrentLightValueManager.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/11.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class CurrentLightValueManager: NSObject {
    
    public static let sharedInstance = CurrentLightValueManager()
    
    func calCurrent(deviceModel: DeviceModel, currentTime: Int, index: Int) -> CGFloat {
        var current: CGFloat = 0
        let state = deviceModel.deviceState
        let low = state & 0x0f
        let high = (state >> 4) & 0x0f
        if low == 0  {
            current = 0
        } else if low == 1 { // ACCL
            if let accl = deviceModel.acclimation {
                if currentTime > accl.startTime && currentTime < accl.endTime {
                    if currentTime < accl.startTime + accl.ramp * 60 {
                        current = CGFloat(accl.intesity[index] * (currentTime - accl.startTime) / (accl.ramp * 60))
                    } else if currentTime > accl.endTime - accl.ramp * 60 {
                        current = CGFloat(accl.intesity[index] * (accl.endTime - currentTime) / (accl.ramp * 60))
                    } else {
                        current = CGFloat(accl.intesity[index])
                    }
                }
            }
            
        } else if low == 2 { // 全开
            current = 100
        } else if low == 4 { // 自动模式
            if let pattern = deviceModel.pattern {
                for (key, item) in pattern.items.enumerated() {
                    if key == pattern.items.count - 1 && item.time <= currentTime {
                        current = CGFloat(item.intensity[index]) * CGFloat(1440 - currentTime) / CGFloat(1440 - item.time)
                        break
                    }
                    if item.time > currentTime {
                        if key > 0 {
                            let pre = pattern.items[key - 1]
                            current = CGFloat(item.intensity[index] - pre.intensity[index]) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.intensity[index])
                            break
                        } else {
                            current = CGFloat(item.intensity[index]) * CGFloat(currentTime) / CGFloat(item.time)
                            break
                        }
                    }
                }
            }
        } else if low == 8 { // 手动模式
            if let pattern = deviceModel.pattern {
                if let manual = pattern.manual {
                    current = CGFloat(manual.intensity[index])
                }
            }
        }
        
        if (high >> 2) & 0x01 == 1 { // 新月Lunar
            if index == 1 {
                if (deviceModel.lunnar?.startTime ?? 0) <= currentTime && (deviceModel.lunnar?.endTime ?? 0) >= currentTime {
                    current = CGFloat(deviceModel.lunnar?.intensity ?? 0)
                }
            }
        }
        if (high >> 1) & 0x01 == 1 { // Lighting 闪电
            if index == 1 {
                if (deviceModel.lightning?.startTime ?? 0) <= currentTime && (deviceModel.lightning?.endTime ?? 0) >= currentTime {
                    current = CGFloat(deviceModel.lightning?.intensity ?? 0)
                }
            }
        }
        
        if high & 0x01 == 1 { // cloud 多云
            if index == 1 {
                if (deviceModel.cloudy?.startTime ?? 0) <= currentTime && (deviceModel.cloudy?.endTime ?? 0) >= currentTime {
                    let start = deviceModel.cloudy?.startTime ?? 0
                    //let end = deviceModel.cloudy?.endTime ?? 0
                    let cycle = deviceModel.cloudy?.speed ?? 0
                    let value = (currentTime - start) % (cycle * 2)
                    let max = deviceModel.cloudy?.intensity ?? 0
                    if value > cycle {
                        current = CGFloat(max) * CGFloat(cycle * 2 - value) / CGFloat(cycle)
                    } else {
                        current = CGFloat(max) * CGFloat(value) / CGFloat(cycle)
                    }
                }
            }
        }
        
        if (high >> 3) & 0x01 == 1 { // 全关
            current = 0
        }
        //print("当前\(index)当前值为：\(current)")
        return current
    }
    
    func calMax(deviceModel: DeviceModel, index: Int) -> CGFloat {
        var current: CGFloat = 0
        let state = deviceModel.deviceState
        let low = state & 0x0f
        let high = (state >> 4) & 0x0f
        if low == 0  {
            current = 0
        } else if low == 1 { // ACCL
            if let accl = deviceModel.acclimation {
                current = CGFloat(accl.intesity[index])
            }
        } else if low == 2 { // 全开
            current = 100
        } else if low == 4 { // 自动模式
            if let pattern = deviceModel.pattern {
                current = CGFloat(pattern.items.max{$0.intensity[index] < $1.intensity[index]}?.intensity[index] ?? 0)
            }
        } else if low == 8 { // 手动模式
            if let pattern = deviceModel.pattern {
                if let manual = pattern.manual {
                    current = CGFloat(manual.intensity[index])
                }
            }
        }
        
        if (high >> 2) & 0x01 == 1 { // 新月Lunar
            if index == 1 {
                current = CGFloat(deviceModel.lunnar?.intensity ?? 0)
            }
        }
        if (high >> 1) & 0x01 == 1 { // Lighting 闪电
            if index == 1 {
                current = CGFloat(deviceModel.lightning?.intensity ?? 0)
            }
        }
        
        if high & 0x01 == 1 { // cloud 多云
            if index == 1 {
                current = CGFloat(deviceModel.cloudy?.intensity ?? 0)
            }
        }
        
        if (high >> 3) & 0x01 == 1 { // 全关
            current = 0
        }
        //print("当前\(index)最大值为：\(current)")
        return current
    }
    
    // 自动模式预览效果
    func calCurrentB(deviceModel: DeviceModel, currentTime: Int, index: Int) -> CGFloat {
        var current: CGFloat = 0
        if let pattern = deviceModel.pattern {
            for (key, item) in pattern.items.enumerated() {
                if key == pattern.items.count - 1 && item.time <= currentTime {
                    current = CGFloat(item.intensity[index]) * CGFloat(1440 - currentTime) / CGFloat(1440 - item.time)
                    break
                }
                if item.time > currentTime {
                    if key > 0 {
                        let pre = pattern.items[key - 1]
                        current = CGFloat(item.intensity[index] - pre.intensity[index]) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.intensity[index])
                        break
                    } else {
                        current = CGFloat(item.intensity[index]) * CGFloat(currentTime) / CGFloat(item.time)
                        break
                    }
                }
            }
        }
        print("当前\(index)当前值为：\(current)")
        return current
    }
}
