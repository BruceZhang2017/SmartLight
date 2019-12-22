//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  Arrays.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import Localize_Swift

class Arrays: NSObject {
    static let barTitleBs = ["CH1", "CH2", "CH3"]
    static let barTitles = ["UV", "DB", "B", "G", "DR", "CW"]
    static let btnTitles = [
        "txt_allon".localized(),
        "txt_aclm".localized(),
        "txt_schedule".localized(),
        "txt_lunnar".localized(),
        "txt_lighting".localized(),
        "txt_cloudy".localized()]
    static let settingTitles = [
        ["txt_datetime".localized(),
         "txt_networks".localized(),
         "txt_languages".localized(),
         "txt_help".localized()],
        ["txt_firewareversion".localized(),
         "txt_firewareupgrade".localized()]]
    static let settingHeadTitles = ["txt_sysinfo".localized(), "txt_deviceinfo".localized()]
    static let effects = [
        ["txt_acclimation".localized(),
        "txt_lunnar".localized(),
        "txt_lighting".localized(),
        "txt_cloudy".localized()],
        ["txt_fan".localized()]]
}
