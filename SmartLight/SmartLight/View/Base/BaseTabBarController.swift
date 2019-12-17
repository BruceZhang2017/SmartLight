//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  BaseTabBarController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	
import UIKit
import Localize_Swift

class BaseTabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setText() {
        guard let items = tabBar.items else {
            return
        }
        let titles = ["txt_dashboard".localized(),
                      "txt_control".localized(),
                      "txt_effects".localized(),
                      "txt_settings".localized()]
        if items.count == titles.count {
            for i in 0..<4 {
                items[i].title = titles[i]
            }
        }
    }

}
