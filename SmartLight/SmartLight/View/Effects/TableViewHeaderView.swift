//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TableViewHeaderView.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/13.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class TableViewHeaderView: UIView {
    
    var titleLabel: UILabel!
    var temperatureCLabel: UILabel!
    var temperatureFLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeUI() {
        titleLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.text = "Water Temperature"
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(15)
        }
        let bView = UIView().then {
            $0.backgroundColor = Color.main
        }
        addSubview(bView)
        bView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(30)
            $0.right.equalToSuperview().offset(-30)
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.height.equalTo(40)
        }
        let imageView = UIImageView().then {
            $0.backgroundColor = UIColor.white
        }
        bView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(3)
            $0.bottom.equalTo(-3)
            $0.width.equalTo(1)
        }
        temperatureCLabel = UILabel().then {
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textAlignment = .center
            $0.text = "\(temperature)C"
        }
        bView.addSubview(temperatureCLabel)
        temperatureCLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalTo(imageView.snp.left)
        }
        temperatureFLabel = UILabel().then {
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textAlignment = .center
            $0.text = "\(32 + temperature)F"
        }
        bView.addSubview(temperatureFLabel)
        temperatureFLabel.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.left.equalTo(imageView.snp.right)
        }
    }
}
