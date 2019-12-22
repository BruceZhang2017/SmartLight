//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  UIKit+Extension.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/4.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

extension UIColor {
    static func hexToColor(hexString: String) -> UIColor {
        
        let mString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if mString.count != 6 { return UIColor.black }
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (mString as NSString).substring(with: range)
        range.location = 2
        let gString = (mString as NSString).substring(with: range)
        range.location = 4
        let bString = (mString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1.0))
    }
    
    static func hexToColor(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(1.0))
    }
    
}

extension UIViewController {
    
    public func showHUD(_ text: String = "预览中...") {
        if let _ = view.viewWithTag(8888) as? MBProgressHUD {
           return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = text
        hud.tag = 8888
    }
    
    public func hideHUD() {
        if let hud = view.viewWithTag(8888) as? MBProgressHUD {
            hud.hide(animated: true)
        }
    }
}

extension UIView {
    public func showHUD(_ text: String = "预览中...") {
        if let _ = viewWithTag(8888) as? MBProgressHUD {
           return
        }
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = text
        hud.tag = 8888
    }
    
    public func hideHUD() {
        if let hud = viewWithTag(8888) as? MBProgressHUD {
            hud.hide(animated: true)
        }
    }
}
