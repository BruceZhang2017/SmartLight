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
    
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        connect()
    }
    
    func connect() {
        try? socket.connect(toHost: "192.168.4.1", onPort: 8089)
    }
    
    func disconnect() {
        socket.disconnect()
        socket = nil
    }
    
    func send(value: String) {
        guard let data = value.data(using: String.Encoding.utf8) else {
            return
        }
        socket.write(data, withTimeout: -1, tag: 0)
    }
    
    /// 处理心跳
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
    
}

extension TCPSocketManager: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        shake(value: shakeValue)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("断开连接")
        shakeValue = 1
        connect()
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        guard let value = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        print("获取到设备: \(value)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("\(partialLength)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("写数据")
    }
}
