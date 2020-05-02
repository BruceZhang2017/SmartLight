//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  CustomPickerViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/18.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class CustomPickerViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    weak var delegate: CustomPickerViewControllerDelegate?
    var componentCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.setTitle("txt_done".localized(), for: .normal)
    }
    
    @IBAction func done(_ sender: Any) {
        let value = pickerView.selectedRow(inComponent: 0)
        delegate?.customPickerView(value: value + 1)
        dismiss(animated: true, completion: nil)
    }
    
}

protocol CustomPickerViewControllerDelegate: NSObjectProtocol {
    func customPickerView(value: Int)
}

extension CustomPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentCount
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 12
    }
    
}

extension CustomPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
}
