//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TCPSocketManager.swift
//  SmartLight
//
//  Created by ANKER on 2019/9/7.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class TCPSocketManager: NSObject {
    
    static let sharedInstance = TCPSocketManager()
    var socket: GCDAsyncSocket!
    var shakeValue = 0
    var ip: String = "" // ip地址
    var heartTimer: Timer!
    var connectTimer: Timer!
    
    override init() {
        super.init()
    }
    
    @objc func connect(_ ip: String = "192.168.4.1") {
        if socket == nil {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        self.ip = ip
        do {
            log.info("建立Socket连接的IP: \(ip)")
            try socket.connect(toHost: ip, onPort: 8089)
        } catch {
            log.info("Socket 建立失败")
            perform(#selector(connect(_:)), with: ip, afterDelay: 1)
        }
        
    }
    
    func disconnect() {
        socket.disconnect()
        socket = nil
    }
    
    func send(value: String) {
        log.info("发送的值为：\(value)")
        guard let data = (value + "\r\n").data(using: String.Encoding.utf8) else {
            return
        }
        socket.write(data, withTimeout: -1, tag: 0)
    }
    
    /// 握手
    func shake(value: Int) {
        send(value: "[HS,\(value)]")
    }
    
    /// 获取版本号
    func getVersion() {
        send(value: "[VER]")
    }
    
    /// 同步当前时间
    func syncCurrentTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = dateFormatter.string(from: Date())
        dateString = dateString.replacingOccurrences(of: "-", with: "")
        dateString = dateString.replacingOccurrences(of: ":", with: "")
        let array = dateString.components(separatedBy: " ")
        send(value: "[TU,\(array[0]),\(array[1])]")
    }
    
    ///1/2/3/4,1表示自动模式，2表示手动模式，3表示全亮模式，4表示ACLM模式。
    func lightSchedual(model: Int, device: DeviceModel, allOn: Bool = true) {
        let value = createlightSchedual(model: model, device: device, allOn: allOn)
        send(value: value)
    }
    
    /// 灯光预设 [LS，模式，数据参数]
    /// - Parameter pattern: 数据
    /// - Parameter model
    private func createlightSchedual(model: Int, device: DeviceModel, allOn: Bool = true) -> String {
        var value = "[LS,\(model),"
        let uv = device.pattern?.manual?.intensity[0] ?? 0
        let db = device.pattern?.manual?.intensity[1] ?? 0
        let b = device.pattern?.manual?.intensity[2] ?? 0
        let g = device.pattern?.manual?.intensity[3] ?? 0
        let dr = device.pattern?.manual?.intensity[4] ?? 0
        let cw = device.pattern?.manual?.intensity[5] ?? 0
        if model == 2 {
            value += "{0,\(uv),\(db),\(b),\(g),\(dr),\(cw)}]"
        } else if model == 1 {
            guard let items = device.pattern?.items else {
                return ""
            }
            for (index, item) in items.enumerated() {
                let uv = item.intensity[0]
                let db = item.intensity[1]
                let b = item.intensity[2]
                let g = item.intensity[3]
                let dr = item.intensity[4]
                let cw = item.intensity[5]
                value += "{\(item.time),\(uv),\(db),\(b),\(g),\(dr),\(cw)}"
                if index != items.count - 1 {
                    value += ","
                } else {
                    value += "]"
                }
            }
        } else if model == 4 {
            // ACLM:开始时间，结束时间，Ramp 时长(小时)，各通道强度，分别是 UV、DB、B、G、 DR、CW
            // 如:0830,0930,1,50,60,40,70,30,20,10
            value += "{\(device.acclimation?.startTime ?? 0),\(device.acclimation?.endTime ?? 0),\(device.acclimation?.ramp ?? 0),\(device.acclimation?.intesity[0] ?? 0),\(device.acclimation?.intesity[1] ?? 0),\(device.acclimation?.intesity[2] ?? 0),\(device.acclimation?.intesity[3] ?? 0),\(device.acclimation?.intesity[4] ?? 0),\(device.acclimation?.intesity[5] ?? 0)}]"
        } else {
            if allOn {
                value += "{0,100,100,100,100,100,100}]"
            } else {
                value += "{0,0,0,0,0,0,0}]"
            }
        }
        return value
    }
    
    func createQRCode(pattern: PatternModel) -> String {
        var value = ""
        let items = pattern.items
        for (index, item) in items.enumerated() {
            let uv = item.intensity[0]
            let db = item.intensity[1]
            let b = item.intensity[2]
            let g = item.intensity[3]
            let dr = item.intensity[4]
            let cw = item.intensity[5]
            value += "{\(item.time),\(uv),\(db),\(b),\(g),\(dr),\(cw)}"
            if index != items.count - 1 {
                value += ","
            } else {
                value += ""
            }
        }
        return value
    }
    
    /// 启动心跳
    func startHeartTimer() {
        heartTimer?.invalidate()
        heartTimer = nil
        heartTimer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(sendHeart), userInfo: nil, repeats: true)
        heartTimer?.fire()
        RunLoop.current.add(heartTimer!, forMode: .common)
    }
    
    @objc func sendHeart() {
        send(value: "[HB]")
    }
    
    func reportProfile() {
        send(value: "[RP]")
    }
    
    // [LE,LUNNAR/LIGHTING/CLOUDY,1/2,配置参数]
    func lightEffect(type: Int, result: Int, device: DeviceModel) {
        var content = "[LE,\(type),\(result)"
        if type == 0 { // LUNNAR
            // LUNNAR:开始时间，结束时间，强度(DB/CH2)
            // 如:0830,0930,50
            content += ",\(device.lunnar?.startTime ?? 0),\(device.lunnar?.endTime ?? 0),\(device.lunnar?.intensity ?? 0)]"
        } else if type == 1 { // LIGHTING
            // LIGHTING:开始时间，结束时间，频率，强度
            // 如:0830,0930,9,50
            content += ",\(device.lightning?.startTime ?? 0),\(device.lightning?.endTime ?? 0),\(device.lightning?.interval ?? 0),\(device.lightning?.frequency ?? 0),\(device.lightning?.intensity ?? 0)"
            if (device.lightning?.frequency ?? 0) > 0 {
                let frequency = device.lightning?.frequency ?? 0
                var duration = (device.lightning?.endTime ?? 0) - (device.lightning?.startTime ?? 0)
                let start = device.lightning?.startTime ?? 0
                if duration < 0 {
                    duration = 24 * 60 + duration
                }
                let value = duration / (frequency + 1)
                for i in 0..<frequency {
                    content += ",\(start + (i + 1) * value)"
                }
            }
            content += "]"
        } else if type == 2 { // CLOUDY
            // CLOUDY:开始时间，结束时间，强度，速度
            // 如:0830,0930,50,30
            content += ",\(device.cloudy?.startTime ?? 0),\(device.cloudy?.endTime ?? 0),\(device.cloudy?.intensity ?? 0),\(device.cloudy?.speed ?? 0)]"
        } else if type == 5 { // Fan
            content += ",\((device.fan?.enable ?? false) ? 0 : 1),\(device.fan?.startTime ?? 0),\(device.fan?.endTime ?? 0),\(device.fan?.intensity ?? 0)]"
        }
        send(value: content)
    }
    
    /// 灯光预览 [LP,0,{0,80,70,60,50,40,30}]
    func lightPreview(value: [Int], tag: Int = 0) {
        var content = "[LP,\(tag),{0,"
        for (index, item) in value.enumerated() {
            content += "\(item)"
            if index != value.count - 1 {
                content += ","
            }
        }
        content += "}]"
        send(value: content)
    }
    
    /// 读取固件版本信息
    func readVersion() {
        send(value: "[VER]")
    }
    
    /// 解析设备信息
    func parseDeviceInfo(value: String) {
        // [RP,设备类型，模式，SCHEDULE/ALLON/ACLM 参数,LUNNAER/LIGHTING/CLOUDY,参数]
        // [RP,3,1,2,{510,45,60,78,0,0,0},{810,45,60,78,0,0,0},0,{2,510,570,50},1,{2,510,570,9,50},
        //2,{0,510,570,50,30}]
        let array = value.components(separatedBy: ",")
        if array.count <= 0 {
            return
        }
        let deviceListModel = DeviceManager.sharedInstance.deviceListModel
        let current = DeviceManager.sharedInstance.currentIndex
        let device = deviceListModel.groups[current]
        if array.count > 1 {
            device.deviceType = Int(array[1]) ?? 6
        }
        if array.count > 2 {
            device.deviceState = Int(array[2]) ?? 0
        }
        if array.count > 2 {
            var list : [Int: [Int]] = [:]
            var temIndex = 0
            var values : [Int] = []
            for (index, item) in array.enumerated() {
                if item.contains("{") {
                    temIndex = index
                    values.append(Int(item.replacingOccurrences(of: "{", with: "")) ?? 0)
                }
                if item.contains("}") {
                    let v = item.replacingOccurrences(of: "}", with: "")
                    let v2 = v.replacingOccurrences(of: "]", with: "")
                    values.append(Int(v2) ?? 0)
                    list[temIndex] = values
                    temIndex = 0
                    values = []
                }
                if temIndex > 0 {
                    values.append(Int(item) ?? 0)
                }
            }
            if list.count > 0 {
                for (key, value) in list {
                    if value.count == 7 {
                        let k = array[key - 1]
                        let v = Int(k) ?? 0
                        if key > 3 && isPurnInt(string: k) && v < 3 { // 如果是数据的话，并且小于 3
                            
                        }
                    } else {
                        let k = array[key - 1]
                        let v = Int(k) ?? 0
                        if key > 3 && isPurnInt(string: k) && v < 3 { // 如果是数据的话，并且小于 3
                            if v == 0 && value.count >= 4 {
                                let lunnar = Lunnar()
                                lunnar.enable = value[0] > 1
                                lunnar.startTime = value[1]
                                lunnar.endTime = value[2]
                                lunnar.intensity = value[3]
                                device.lunnar = lunnar
                            } else if v == 1 && value.count >= 5 {
                                let lighting = Lightning()
                                lighting.enable = value[0] > 1
                                lighting.startTime = value[1]
                                lighting.endTime = value[2]
                                lighting.frequency = value[3]
                                lighting.intensity = value[4]
                            } else if v == 2 && value.count >= 5 {
                                let cloudy = Cloudy()
                                cloudy.enable = value[0] > 1
                                cloudy.startTime = value[1]
                                cloudy.endTime = value[2]
                                cloudy.intensity = value[3]
                                cloudy.speed = value[4]
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isPurnInt(string: String) -> Bool {
            let scan: Scanner = Scanner(string: string)
            var val:Int = 0
            return scan.scanInt(&val) && scan.isAtEnd
    }
    
    private func parseSchedule() {
        
    }
}

extension TCPSocketManager: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        log.info("Socket连接建立成功")
        DeviceManager.sharedInstance.connectStatus[ip] = 2
        shake(value: shakeValue)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        log.info("断开连接")
        DeviceManager.sharedInstance.connectStatus[ip] = 0
        shakeValue = 1
        socket.delegate = nil
        socket = nil 
        connect(ip)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        log.info("Socket返回的值：{\(data.hexEncodedString())}, \(data.count)")
        guard let value = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        log.info("Socket返回的字符串值：{\(value)}")
        if value.contains("[HS]") { // 握手
            if shakeValue == 0 {
                syncCurrentTime()
            }
        } else if value.contains("[TU]") { // 更新时间
            getVersion()
        } else if value.contains("[HB]") { // 心跳
            
        } else if value.contains("[LS]") { // 灯光预设
            
        } else if value.contains("[RP") {
            parseDeviceInfo(value: value)
            startHeartTimer()
        } else if value.contains("[VER") {
            let start = value.index(value.startIndex, offsetBy: 4)
            let end = value.index(value.endIndex, offsetBy: -1)
            firmwareVersion = String(value[start...end])
            reportProfile()
        } else if value.contains("[TP,") {
            let start = value.index(value.startIndex, offsetBy: 4)
            let end = value.index(value.endIndex, offsetBy: -1)
            let t = String(value[start...end])
            temperature = Int(t) ?? 0
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        log.info("读取到部分数据：\(partialLength)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        log.info("Socket写数据成功")
        socket.readData(withTimeout: -1, tag: 0)
    }
}
