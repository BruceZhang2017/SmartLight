//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TouchBarValueView.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/13.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class TouchBarValueView: UIView {

    @IBOutlet weak var settingValueImageView: UIImageView!
    @IBOutlet weak var currentValueImageView: UIImageView!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var smallImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLConstraint: NSLayoutConstraint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            topLConstraint.constant = min(point.y, rect.size.height)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            topLConstraint.constant = min(point.y, rect.size.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            topLConstraint.constant = min(point.y, rect.size.height)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            topLConstraint.constant = min(point.y, rect.size.height)
        }
    }
}
