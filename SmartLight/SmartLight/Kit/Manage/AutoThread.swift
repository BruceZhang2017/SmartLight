//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  AutoThread.swift
//  SmartLight
//
//  Created by ANKER on 2020/1/13.
//  Copyright © 2020 PDP-ACC. All rights reserved.
//
	

import UIKit

class AutoThread: NSObject {
    
    private var socket: GCDAsyncSocket!
    final let SERVER = "www.woaiyijia.com"
    final let PORT: UInt16 = 18866
    public var mac = ""
    public var callback: (() -> ())?
    
    init(mac: String) {
        super.init()
        self.mac = mac
        initialize()
    }
    
    private func initialize() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "AutoThread"))
        do {
            print("准备连接服务器")
            try socket.connect(toHost: SERVER, onPort: PORT)
        }catch {
            print("错误信息")
            print(error.localizedDescription)
        }
    }
    
    private func write() {
        
        var dict: [String: Any] = [:]
        dict["cmd"] = 1020
        var sDict: [String: String] = [:]
        sDict["chipid"] = mac
        sDict["ver"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        sDict["model"] = "smartLEDLight"
        dict["msg"] = sDict
        guard let d = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed) else {
            return
        }
        guard let str = String(data: d, encoding: .utf8) else {
            return
        }
        
        var data = Data()
        data.append(UInt8(str.count & 0xff))
        data.append(UInt8((str.count >> 8) & 0xff))
        data.append(UInt8((str.count >> 16) & 0xff))
        data.append(UInt8((str.count >> 24) & 0xff))
        data.append(UInt8(0))
        data.append(UInt8(0))
        data.append(UInt8(0))
        data.append(UInt8(0))
        socket.write(data, withTimeout: -1, tag: 0)
        socket.readData(withTimeout: -1, tag: 0)
        socket.write(d, withTimeout: -1, tag: 1)
        socket.readData(withTimeout: -1, tag: 1)
        
        
    }
}

extension AutoThread: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        print("连接成功")
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("连接成功")
        write()
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("写成功 \(tag)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("读成功 \(tag)")
        print(String(data: data, encoding: .utf8) ?? "")
        callback?()
    }
}
