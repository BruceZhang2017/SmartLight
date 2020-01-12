//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TableViewFooterView.swift
//  SmartLight
//
//  Created by ANKER on 2020/1/12.
//  Copyright © 2020 PDP-ACC. All rights reserved.
//
	

import UIKit

class TableViewFooterView: UIView {

    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initializeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeUI() {
        titleLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.text = "txt_fan_attention".localized()
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.top.equalTo(2)
            $0.bottom.equalTo(-20)
        }
    }
}
