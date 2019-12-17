//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  BaseViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import SnapKit
import Then
import Toaster
import Localize_Swift

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setText() {
        
    }
    
}
