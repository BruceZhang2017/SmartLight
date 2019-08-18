//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsSettingBTableViewCell.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/8.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class EffectsSettingBTableViewCell: UITableViewCell {

    @IBOutlet weak var mSlider: UISlider!
    weak var delegate: EffectsSettingBTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        delegate?.valueChanged(value: Int(mSlider.value * 100), tag: tag)
    }
}

protocol EffectsSettingBTableViewCellDelegate: NSObjectProtocol {
    func valueChanged(value: Int, tag: Int)
}
