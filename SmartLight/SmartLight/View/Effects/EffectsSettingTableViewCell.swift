//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsSettingTableViewCell.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/8.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class EffectsSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var mSwitch: UISwitch!
    weak var delegate: EffectsSettingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        delegate?.valueChanged(mSwitch.isOn, tag: tag)
    }
}

protocol EffectsSettingTableViewCellDelegate: NSObjectProtocol {
    func valueChanged(_ value: Bool, tag: Int)
}
