//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DatePickerViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/7.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func valueChanged(_ sender: Any) {
        
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
