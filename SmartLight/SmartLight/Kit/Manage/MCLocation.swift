//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  MCLocation.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/28.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	
import Foundation
import CoreLocation

public class MCLocation: NSObject {
    
    public static let shared = MCLocation()
    private var locationManager : CLLocationManager?
    private var viewController : UIViewController?      // 承接外部传过来的视图控制器，做弹框处理
    
    // 外部初始化的对象调用，执行定位处理。
    public func didUpdateLocation(_ vc:UIViewController) -> Bool {
        self.viewController = vc
        if (self.locationManager != nil) && (CLLocationManager.authorizationStatus() == .denied) {
            // 定位提示
            self.alter(viewController: viewController!)
            return false
        } else {
            self.requestLocationServicesAuthorization()
            return true 
        }
    }
    
    public static func getLocationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return true
        }
        return false
    }
    
    
    // 初始化定位
    private func requestLocationServicesAuthorization() {
        
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
        }
        
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.startUpdatingLocation()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            
        }
    }
    
    
    // 获取定位代理返回状态进行处理
    private func reportLocationServicesAuthorizationStatus(status:CLAuthorizationStatus) {
        
        if status == .notDetermined {
            // 未决定,继续请求授权
            requestLocationServicesAuthorization()
        } else if (status == .restricted) {
            // 受限制，尝试提示然后进入设置页面进行处理
            alter(viewController: viewController!)
        } else if (status == .denied) {
            // 受限制，尝试提示然后进入设置页面进行处理
            alter(viewController: viewController!)
        }
    }
    
    
    private func alter(viewController:UIViewController) {
        let alter = UIAlertController.init(title: "定位服务未开启,是否前往开启?", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction.init(title: "暂不开启", style: UIAlertAction.Style.cancel) { (a) in
        }
        let confirm = UIAlertAction.init(title: "前往开启", style: UIAlertAction.Style.default) { (b) in
            // 跳转到开启定位服务页面
            let url = NSURL.init(string: UIApplication.openSettingsURLString)
            if(UIApplication.shared.canOpenURL(url! as URL)) {
                UIApplication.shared.openURL(url! as URL)
            }
        }
        alter.addAction(cancle)
        alter.addAction(confirm)
        viewController.present(alter, animated: true, completion: nil)
    }
}


extension MCLocation:  CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        reportLocationServicesAuthorizationStatus(status: status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
