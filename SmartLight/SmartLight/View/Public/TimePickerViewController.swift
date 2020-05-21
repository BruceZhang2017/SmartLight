//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TimePickerViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/18.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import Localize_Swift

class TimePickerViewController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    weak var delegate: TimePickerViewControllerDelegate?
    var start = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.setTitle("txt_done".localized(), for: .normal)
        let currentLanguage = Localize.currentLanguage()
        if currentLanguage.count > 0 {
            if currentLanguage.contains("zh") {
                timePicker.locale = Locale(identifier: "zh_CN")
            } else {
                timePicker.locale = Locale(identifier: "en_US")
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        let dateStr = formatter.string(from: timePicker.date)
        delegate?.timePickerView(value: dateStr, start: start)
    }
}

protocol TimePickerViewControllerDelegate: NSObjectProtocol {
    func timePickerView(value: String, start: Bool)
}
