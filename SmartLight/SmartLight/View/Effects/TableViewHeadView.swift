//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TableViewHeadView.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/13.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class TableViewHeadView: UITableViewHeaderFooterView {
    
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initialUI()
        backgroundColor = UIColor.hexToColor(hexString: "CACACE")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        titleLabel = UILabel().then {
            $0.textColor = UIColor.hexToColor(hexString: "787878")
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(10)
        }
        
        contentLabel = UILabel().then {
            $0.textColor = UIColor.hexToColor(hexString: "787878")
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.top.equalToSuperview().offset(10)
        }
    }
    
}
