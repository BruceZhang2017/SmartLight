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
    
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    func connect(_ ip: String = "192.168.4.1") {
        self.ip = ip
        try? socket.connect(toHost: ip, onPort: 8089)
    }
    
    func disconnect() {
        socket.disconnect()
        socket = nil
    }
    
    func send(value: String) {
        guard let data = (value + "\r\n").data(using: String.Encoding.utf8) else {
            return
        }
        socket.write(data, withTimeout: -1, tag: 0)
    }
    
    /// 握手
    func shake(value: Int) {
        send(value: "[HS,\(value)]")
    }
    
    /// 同步当前时间
    func syncCurrentTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = dateFormatter.string(from: Date())
        dateString = dateString.replacingOccurrences(of: "-", with: "")
        dateString = dateString.replacingOccurrences(of: ":", with: "")
        var array = dateString.components(separatedBy: " ")
        send(value: "[TU,\(array[0]),\(array[1])]")
    }
    
    func lightSchedual(pattern: PatternModel) {
        var value = "[LS,"
        if pattern.isManual {
            value += "1,"
            value += "{0,\(pattern.manual?.all ?? 0),1,\(pattern.manual?.uv ?? 0),2,\(pattern.manual?.db ?? 0),3,\(pattern.manual?.b ?? 0),4,\(pattern.manual?.g ?? 0),5,\(pattern.manual?.dr ?? 0),6,\(pattern.manual?.cw ?? 0)}]"
        } else {
            value += "0,"
            for (index, item) in pattern.items.enumerated() {
                value += "{\(item.time),0,\(item.all),1,\(item.uv),2,\(item.db),3,\(item.b),4,\(item.g),5,\(item.dr),6,\(item.cw)}"
                if index != pattern.items.count - 1 {
                    value += ","
                } else {
                    value += "]"
                }
            }
        }
        print("value: \(value)")
        send(value: value)
    }
    
    /// 启动心跳
    func startHeartTimer() {
        heartTimer.invalidate()
        heartTimer = nil
        heartTimer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(sendHeart), userInfo: nil, repeats: true)
        RunLoop.current.add(heartTimer!, forMode: .common)
    }
    
    @objc func sendHeart() {
        send(value: "[HB]")
    }
    
    func reportProfile() {
        send(value: "[RP]")
    }
    
    func lightControl(type: Int, result: Int, device: DeviceModel) {
        var content = "[LC,\(type),\(result)"
        if type == 0 { // ALLON
            content += "]"
        } else if type == 1 { // ACLM
            // ACLM:开始时间，结束时间，Ramp 时长(小时)，各通道强度，分别是 UV、DB、B、G、 DR、CW、ALL
            // 如:0830,0930,1,50,60,40,70,30,20,10
            content += ",\(device.acclimation?.startTime ?? 0),\(device.acclimation?.endTime ?? 0),\(device.acclimation?.ramp ?? 0),\(device.acclimation?.intesity[0] ?? 0),\(device.acclimation?.intesity[1] ?? 0),\(device.acclimation?.intesity[2] ?? 0),\(device.acclimation?.intesity[3] ?? 0),\(device.acclimation?.intesity[4] ?? 0),\(device.acclimation?.intesity[5] ?? 0),\(device.acclimation?.intesity[6] ?? 0)]"
        } else if type == 2 { // LUNNAR
            // LUNNAR:开始时间，结束时间，强度(DB/CH2)
            // 如:0830,0930,50
            content += ",\(device.lunnar?.startTime ?? 0),\(device.lunnar?.endTime ?? 0),\(device.lunnar?.intensity ?? 0)]"
        } else if type == 3 { // LIGHTING
            // LIGHTING:开始时间，结束时间，频率，强度
            // 如:0830,0930,9,50
            content += ",\(device.lightning?.startTime ?? 0),\(device.lightning?.endTime ?? 0),\(device.lightning?.frequency ?? 0),\(device.lightning?.intensity ?? 0)]"
        } else if type == 4 { // CLOUDY
            // CLOUDY:开始时间，结束时间，强度，速度
            // 如:0830,0930,50,30
            content += ",\(device.cloudy?.startTime ?? 0),\(device.cloudy?.endTime ?? 0),\(device.cloudy?.intensity ?? 0),\(device.cloudy?.speed ?? 0)]"
        }
        send(value: content)
    }
    
    func parseDeviceInfo() {
        // [RP,设备类型，模式，SCHEDULE/ALLON/ACLM 参数,LUNNAER/LIGHTING/CLOUDY,参数]
        
        let deviceListModel = DeviceManager.sharedInstance.deviceListModel
        let current = DeviceManager.sharedInstance.currentIndex
        var device = deviceListModel.groups[current]
        device.deviceType = 0
        reportProfile()
    }
}

extension TCPSocketManager: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        DeviceManager.sharedInstance.connectStatus[ip] = 2
        shake(value: shakeValue)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("断开连接")
        DeviceManager.sharedInstance.connectStatus[ip] = 0
        shakeValue = 1
        connect()
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        guard let value = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        if value.contains("[HS]") { // 握手
            
        } else if value.contains("[TU]") { // 更新时间
            
        } else if value.contains("[HB]") { // 心跳
            
        } else if value.contains("[LS]") { // 灯光预设
            
        } else if value.contains("[RP") {
            // parseDeviceInfo()
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("\(partialLength)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("写数据")
    }
}
