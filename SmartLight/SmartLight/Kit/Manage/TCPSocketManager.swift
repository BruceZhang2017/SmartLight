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
    var sockets: [GCDAsyncSocket] = []
    var shakeValue = 0
    var heartTimer: Timer!
    var connectTimer: Timer!
    private var threads: [AutoThread] = []
    private var bSelfDisconneced = false // 自己主动断开
    private var otaSocket: GCDAsyncSocket?
    private var util: YModemUtil?
    private var bSendOTAHead = false
    private var otaRetry = false
    
    public func connectDeivce() {
        let model = DeviceManager.sharedInstance.deviceListModel
        let current = DeviceManager.sharedInstance.currentIndex
        if current >= model.groups.count {
            return
        }
        if model.groups[current].group == true {
            if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" {
                return
            }
            let child = model.groups[current].child
            if child <= 0 {
                return
            }
            for i in 0..<child {
                if current + i + 1 >= model.groups.count {
                    return
                }
                let ip = model.groups[current + i + 1].ip ?? "192.168.4.1"
                if DeviceManager.sharedInstance.connectStatus[ip] == 2 {
                    print("设备已连接Group：\(ip)")
                    continue
                }
                let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
                socket.userData = ip
                DeviceManager.sharedInstance.connectStatus[ip] = 1
                sockets.append(socket)
                connect(ip, socket: socket)
                uploadDeviceToCloud(model: model.groups[current + i + 1], index: current)
            }
        } else {
            var ip = model.groups[current].ip ?? "192.168.4.1"
            if DeviceManager.sharedInstance.connectStatus[ip] == 2 {
                print("设备已连接Single：\(ip)")
                return
            }
            let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            socket.userData = ip
            DeviceManager.sharedInstance.connectStatus[ip] = 1
            if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" {
                ip = "192.168.4.1"
            }
            sockets.append(socket)
            connect(ip, socket: socket)
            uploadDeviceToCloud(model: model.groups[current], index: current)
        }
    }
    
    private func uploadDeviceToCloud( model: DeviceModel, index: Int) {
        if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" {
            return
        }
        if model.macAddress.count <= 0 {
            return
        }
        if model.uploadToCloud { // 已经上报过，则不再上报
            return
        }
        let thread = AutoThread(mac: model.macAddress)
        if threads.contains(thread) {
            return
        }
        threads.append(thread)
        thread.callback = {
            [weak self] in
            self?.saveDevices(index: index)
            self?.deleteThread(thread)
        }
    }
    
    private func saveDevices(index: Int) {
        let model = DeviceManager.sharedInstance.deviceListModel
        let device = model.groups[index]
        device.uploadToCloud = true
        model.groups[index] = device
        DeviceManager.sharedInstance.save()
    }
    
    private func deleteThread(_ thread: AutoThread) {
        for (index, item) in threads.enumerated() {
            if item.mac == thread.mac {
                threads.remove(at: index)
                break
            }
        }
    }
    
    @objc func connect(_ ip: String = "192.168.4.1", socket: GCDAsyncSocket) {
        do {
            if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" {
                log.info("建立Socket连接的IP: 192.168.4.1")
                try socket.connect(toHost: "192.168.4.1", onPort: 8089)
            } else {
                log.info("建立Socket连接的IP: \(ip)")
                try socket.connect(toHost: ip, onPort: 8089)
            }
        } catch {
            log.info("Socket 建立失败")
        }
    }
    
    func disconnectAll() {
        if sockets.count > 0 {
            for socket in sockets {
                let ip = socket.userData as? String ?? ""
                if ip.count > 0 {
                    DeviceManager.sharedInstance.connectStatus[ip] = 0
                }
                socket.disconnect()
            }
        }
        sockets.removeAll()
    }
    
    @objc func disconnectAllDevices() {
        bSelfDisconneced = true
        disconnectAll()
        print("2秒钟后执行回连")
        perform(#selector(reconnectDevice), with: nil, afterDelay: 2)
    }
    
    @objc private func reconnectDevice() {
        bSelfDisconneced = false 
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        var ip = "192.168.0.1"
        if DeviceOTAManager.sharedInstance.deviceOTAList.count > 0 {
            for (key , value) in DeviceOTAManager.sharedInstance.deviceOTAList {
                if value == true {
                    ip = key
                    break
                }
            }
        }
        print("查找到的ip值为：\(ip)")
        socket.userData = ip
        otaSocket = socket
        connect(ip, socket: socket)
    }
    
    func disconnect(ip: String) {
        if ip == "" {
            return
        }
        if sockets.count > 0 {
            for (index, socket) in sockets.enumerated() {
                let ipB = socket.userData as? String ?? ""
                if ipB.count > 0 && ip == ipB {
                    if ip.count > 0 {
                        DeviceManager.sharedInstance.connectStatus[ip] = 0
                    }
                    socket.disconnect()
                    sockets.remove(at: index)
                    break
                }
            }
        }
    }
    
    func disconnectOTASocket() {
        if otaSocket != nil {
            otaSocket?.disconnect()
            otaSocket = nil
            util?.delegate = nil
            util = nil 
        }
    }
    
    func send(value: String) {
        log.info("发送的值为：\(value)")
        guard let data = (value + "\r\n").data(using: String.Encoding.utf8) else {
            return
        }
        for socket in sockets {
            socket.write(data, withTimeout: -1, tag: 0)
        }
    }
    
    /// 握手
    private func shake(value: Int) {
        send(value: "[HS,\(value)]")
    }
    
    /// 获取版本号
    func getVersion() {
        send(value: "[VER]")
    }
    
    /// 更新WIFI名称和密码给设备
    func sendWIFINameAndPWD() {
        let ssid = WIFIManager().getSSID()
        let wifiList = UserDefaults.standard.object(forKey: .kWIFIPWD) as? [String : String] ?? [:]
        print("wifiList: \(wifiList)")
        let password = wifiList[ssid] ?? ""
        if ssid == "SmartLEDLight" { // 密码为12345678
            return
        }
        send(value: "[WPU,\(ssid),\(password)]")
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
            guard let items = device.pattern?.items, items.count > 0 else {
                return "[LS,1,{0,0,0,0,0,0,0}]"
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
        heartTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(sendHeart), userInfo: nil, repeats: true)
        RunLoop.current.add(heartTimer!, forMode: .common)
    }
    
    func getTemperature() {
        send(value: "[TP]")
    }
    
    @objc func sendHeart() {
        if otaSocket != nil {
            guard let ip = otaSocket?.userData as? String else {
                return
            }
            if DeviceOTAManager.sharedInstance.deviceOTAList[ip] == true {
                return
            }
        }
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
            let enable = device.fan?.enable ?? 0
            let intensity = device.fan?.intensity ?? 0
            content += ",\(enable),\(device.fan?.startTime ?? 0),\(device.fan?.endTime ?? 0),\(enable > 0 ? intensity : 0)]"
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
    /*[RP,3,4,2,{2,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0},{0,0,0,0}]}*/
        let array = value.components(separatedBy: ",")
        if array.count <= 0 {
            return
        }
        
        var temIndex = 0
        let deviceListModel = DeviceManager.sharedInstance.deviceListModel
        if deviceListModel.groups.count == 0 {
            return
        }
        let current = DeviceManager.sharedInstance.currentIndex
        let device = deviceListModel.groups[current]
        if array.count > 1 {
            device.deviceType = Int(array[1]) ?? 3 // 是3还是6
        }
        if array.count > 2 {
            device.deviceState = Int(array[2]) ?? 0 // 设备状态
        }
        temIndex = 2
        if array.count > 20 {
            let count = Int(array[3]) ?? 0 // 所有灯光控制点数目
            temIndex = 3
            if count > 0 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                parseForManual(device: device, array: Array(array[tem...temIndex]))
            }
            if count > 1 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                parseForAccl(device: device, array: Array(array[tem...temIndex]))
            }
            if count > 2 {
                var temArray: [[String]] = []
                for _ in 0..<count-2 {
                    temIndex += 1
                    let tem = temIndex
                    while !array[temIndex].contains("}") {
                        temIndex += 1
                    }
                    temArray.append(Array(array[tem...temIndex]))
                }
                parseForAuto(device: device, array: temArray)
            }
            if array.count >= temIndex + 4 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                let tArray = Array(array[tem...temIndex])
                let lunnar = Lunnar()
                lunnar.startTime = Int(tArray[1]) ?? 0
                lunnar.endTime = Int(tArray[2]) ?? 0
                lunnar.intensity = Int(tArray[3].replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "]", with: "")) ?? 0
                device.lunnar = lunnar
            }
            if array.count >= temIndex + 6 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                let tArray = Array(array[tem...temIndex])
                let lighting = Lightning()
                lighting.startTime = Int(tArray[1]) ?? 0
                lighting.endTime = Int(tArray[2]) ?? 0
                lighting.interval = Int(tArray[3]) ?? 0
                lighting.frequency = Int(tArray[4]) ?? 0
                lighting.intensity = Int(tArray[5].replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "]", with: "")) ?? 0
                device.lightning = lighting
            }
            if array.count >= temIndex + 5 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                let tArray = Array(array[tem...temIndex])
                let cloudy = Cloudy()
                cloudy.startTime = Int(tArray[1]) ?? 0
                cloudy.endTime = Int(tArray[2]) ?? 0
                cloudy.intensity = Int(tArray[3]) ?? 0
                cloudy.speed = Int(tArray[4].replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "]", with: "")) ?? 0
                device.cloudy = cloudy
            }
            if array.count >= temIndex + 4 {
                temIndex += 1
                let tem = temIndex
                while !array[temIndex].contains("}") {
                    temIndex += 1
                }
                let tArray = Array(array[tem...temIndex])
                let fan = Fan()
                fan.enable = Int(tArray[0]) ?? 0
                fan.startTime = Int(tArray[1]) ?? 0
                fan.endTime = Int(tArray[2]) ?? 0
                fan.intensity = Int(tArray[3].replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "]", with: "")) ?? 0
                device.fan = fan
            }
            
            deviceListModel.groups[current] = device
            DeviceManager.sharedInstance.save()
            log.info("发送通知刷新界面")
            NotificationCenter.default.post(name: Notification.Name("DashboardViewController"), object: 1)
        }
    }
    
    func isPurnInt(string: String) -> Bool {
            let scan: Scanner = Scanner(string: string)
            var val:Int = 0
            return scan.scanInt(&val) && scan.isAtEnd
    }
    
    private func parseSchedule() {
        
    }
    
    func otaUpdateAgain() {
        print("otaUpdateAgain")
        otaRetry = true
        send(value: "[UPGRADE]")
        perform(#selector(disconnectAndReconnect), with: nil, afterDelay: 10)
    }
    
    @objc private func disconnectAndReconnect() {
        if !otaRetry {
            return
        }
        guard let ip = otaSocket?.userData as? String else {
            return
        }
        DeviceOTAManager.sharedInstance.deviceOTAList = [:]
        DeviceOTAManager.sharedInstance.deviceOTAList[ip] = true
        DeviceOTAManager.sharedInstance.saveOTAState(ip: ip)
        perform(#selector(disconnectAllDevices), with: nil, afterDelay: 2)
    }
    
    @objc private func otaUpdate() {
        if otaSocket != nil {
            let ip = otaSocket?.userData as? String ?? ""
            if DeviceOTAManager.sharedInstance.deviceOTAList[ip] == true {
                if util == nil {
                    util = YModemUtil(1024)
                    util?.delegate = self
                    sendData(state: OrderStatusC)
                    return
                }
            }
        }
    }
    
    func sendData(state: OrderStatus) {
        util?.setFirmwareHandleOTADataWith(state, fileName: "micmol.bin", completion: { (current, total, msg) in
            
        })
    }
    
    @objc func handleOTAData(_ data: Data) {
        print("处理OTA返回数据")
        if data.count == 0 {
            return
        }
        if data[0] == 0x43 || (data.count > 1 && data[1] == 0x43) {
            if bSendOTAHead {
                sendData(state: OrderStatusFirst)
                return
            }
            bSendOTAHead = true
            otaUpdate()
        } else if data[0] == 0x06 {
            sendData(state: OrderStatusACK)
        } else if data[0] == 0x15 {
            sendData(state: OrderStatusNAK)
        }
     }
}

extension TCPSocketManager: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        guard let ip = sock.userData as? String else {
            return
        }
        log.info("Socket连接建立成功: \(ip)")
        if DeviceManager.sharedInstance.connectStatus[ip] == 2 {
            return
        }
        otaSocket = sock
        otaSocket?.userData = ip
        DeviceManager.sharedInstance.connectStatus[ip] = 2
        if DeviceOTAManager.sharedInstance.getOTAState(ip: ip) { // 进入OTA流程
            print("准备OTA逻辑")
            DeviceOTAManager.sharedInstance.deviceOTAList[ip] = true
            sock.readData(withTimeout: -1, tag: 0)
            return
        }
        shake(value: shakeValue)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("SOCKET 断开连接")
        if let error = err as NSError? {
            log.info("断开连接信息: \(error.code) \(error.domain)")
            if error.code == 7 {
                return
            }
        }
        if bSelfDisconneced {
            return
        }
        guard let ip = sock.userData as? String else {
            return
        }
        if DeviceOTAManager.sharedInstance.deviceOTAList[ip] == true {
            log.info("Socket连接建立失败 OTA")
            let array = ip.components(separatedBy: ".")
            if array.count == 4 && (Int(array[3]) ?? 0) >= 255 {
                print("OTA失败")
                return
            }
            let temIP = "\(array[0]).\(array[1]).\(array[2]).\((Int(array[3]) ?? 0) + 1)"
            DeviceOTAManager.sharedInstance.deviceOTAList[ip] = false
            DeviceOTAManager.sharedInstance.deviceOTAList[temIP] = true
            sock.userData = temIP
            sock.delegate = self
            connect(temIP, socket: sock)
            return
        }
        DeviceManager.sharedInstance.connectStatus[ip] = 0
        if sockets.count == 0 {
            return
        }
        if ip == "" {
            return
        }
        let name = ESPTools.getCurrentWiFiSsid() ?? ""
        if name.count == 0 {
            return
        }
        var a = false
        for socket in sockets {
            let ipB = socket.userData as? String ?? ""
            if ipB == ip {
                a = true
                break
            }
        }
        if a == false {
            return
        }
        
        sock.delegate = self
        connect(ip, socket: sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        log.info("Socket返回的值：{\(data.hexEncodedString())}, \(data.count)")
        guard let value = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        guard let ip = sock.userData as? String else {
            return
        }
        log.info("Socket返回的字符串值：{\(value)}")
        if DeviceOTAManager.sharedInstance.deviceOTAList[ip] == true {
            perform(#selector(handleOTAData(_:)), with: data, afterDelay: 1)
            return
        }
        if value.contains("[HS]") { // 握手
            if shakeValue == 0 {
                shakeValue = 1
                syncCurrentTime()
            }
        } else if value.contains("[TU]") { // 更新时间
            getVersion()
        } else if value.contains("[HB") { // 心跳
            print("接受到心跳数据")
        } else if value.contains("[LS]") { // 灯光预设
            
        } else if value.contains("[RP") {
            sendWIFINameAndPWD()
            parseDeviceInfo(value: value)
            startHeartTimer()
        } else if value.contains("[VER") {
            let array = value.split(separator: ",")
            if array.count >= 2 {
                firmwareVersion = String(array[1])
            }
            reportProfile()
        } else if value.contains("[TP") {
            let start = value.index(value.startIndex, offsetBy: 4)
            let end = value.index(value.endIndex, offsetBy: -1)
            let t = String(value[start..<end])
            print("获取到的温度：\(t)")
            temperature = Int(t) ?? 0
        } else if value.contains("[UPGRADE]") {
            print("正在OTA中的设备的IP地址为：\(ip)")
            otaRetry = false
            DeviceOTAManager.sharedInstance.deviceOTAList = [:]
            DeviceOTAManager.sharedInstance.deviceOTAList[ip] = true
            DeviceOTAManager.sharedInstance.saveOTAState(ip: ip)
            perform(#selector(disconnectAllDevices), with: nil, afterDelay: 6)
        } else if value.contains("[WPU") {
            getTemperature()
        } else {
            print("解析无用数据")
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        log.info("读取到部分数据：\(partialLength)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        log.info("Socket写数据成功")
        sock.readData(withTimeout: -1, tag: 0)
    }
}

extension TCPSocketManager: YModemUtilDelegate {
    func onWriteBleData(_ data: Data!) {
        if data.count <= 0 {
            return
        }
        var value = false
        var lData = Data()
        for (i, b) in data.enumerated() {
            if value == true {
                value = false
                continue
            }
            if i < data.count - 1 {
                if b == 0x0D && data[i + 1] == 0x0A {
                    lData.append(0x0D)
                    lData.append(0x01)
                    lData.append(0x0A)
                    lData.append(0x02)
                    value = true
                    continue
                }
            }
            lData.append(b.byteSwapped)
        }
        lData.append(0x0D)
        lData.append(0x0A)
        log.info("发送的数据： \(lData.hexEncodedString())")
        log.info("发送的数据的总长度： \(lData.count)")
        otaSocket?.write(lData, withTimeout: -1, tag: 0)
    }
    
    
    private func parseForManual(device: DeviceModel, array: [String]) {
        let manualAllOnAllOff = Int(array[0].replacingOccurrences(of: "{", with: "")) ?? 0
        if manualAllOnAllOff == 2 {
            var model: PatternModel? = device.pattern
            if model == nil {
                 model = PatternModel()
            }
            model?.isManual = (device.deviceState >> 3 & 0x01) > 0
            var itemModel: PatternItemModel? = model?.manual
            if itemModel == nil {
                itemModel = PatternItemModel()
            }
            for i in 0..<6 {
                if i != 5 {
                    itemModel?.intensity[i] = Int(array[1 + i]) ?? 0
                } else {
                    itemModel?.intensity[i] = Int(array[1 + i].replacingOccurrences(of: "}", with: "")) ?? 0
                }
            }
            device.pattern = model
        }
    }
    
    private func parseForAccl(device: DeviceModel, array: [String]) {
        var model: Acclimation? = device.acclimation
        if model == nil {
             model = Acclimation()
        }
        model?.startTime = Int(array[0].replacingOccurrences(of: "{", with: "")) ?? 0
        model?.endTime = Int(array[1]) ?? 0
        model?.ramp = Int(array[2]) ?? 0
        for i in 0..<6 {
            if i != 5 {
                model?.intesity[i] = Int(array[3 + i]) ?? 0
            } else {
                model?.intesity[i] = Int(array[3 + i].replacingOccurrences(of: "}", with: "")) ?? 0
            }
        }
        device.acclimation = model
    }
    
    private func parseForAuto(device: DeviceModel, array: [[String]]) {
        var model: PatternModel? = device.pattern
        if model == nil {
            model = PatternModel()
        }
        var values: [PatternItemModel] = []
        for i in 0..<array.count {
            let model: PatternItemModel = PatternItemModel()
            model.time = Int(array[i][0].replacingOccurrences(of: "{", with: "")) ?? 0
            for j in 0..<6 {
                model.intensity[j] = Int(array[i][1 + j].replacingOccurrences(of: "}", with: "")) ?? 0
            }
            values.append(model)
        }
        model?.items = values
        device.pattern = model
    }
}
