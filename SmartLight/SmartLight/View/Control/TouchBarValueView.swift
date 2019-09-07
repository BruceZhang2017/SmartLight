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
    weak var delegate: TouchBarValueViewDelegate?
    
    func setValue(_ value: Int) {
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        let h1 = rect.size.height - 20
        let v1: CGFloat = CGFloat(100 - value)
        let top = v1 * h1 / 100 + 20
        topLConstraint.constant = top
        valueLabel.text = "\(value)%"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            let top = min(point.y, rect.size.height)
            //print("start\(top)")
            topLConstraint.constant = top
            let value = 100 - Int((top - 20) * 100 / (rect.size.height - 20))
            delegate?.progress(tag: tag, top: top, value: value)
            valueLabel.text = "\(value)%"
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            let top = min(point.y, rect.size.height)
            //print("move\(top)")
            topLConstraint.constant = top
            let value = 100 - Int((top - 20) * 100 / (rect.size.height - 20))
            delegate?.progress(tag: tag, top: top, value: value)
            valueLabel.text = "\(value)%"
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            let top = min(point.y, rect.size.height)
            //print("end\(top)")
            topLConstraint.constant = top
            let value = 100 - Int((top - 20) * 100 / (rect.size.height - 20))
            delegate?.progress(tag: tag, top: top, value: value)
            valueLabel.text = "\(value)%"
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let rect = bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
        if rect.contains(point) {
            let top = min(point.y, rect.size.height)
            //print("cancel\(top)")
            topLConstraint.constant = top
            let value = 100 - Int((top - 20) * 100 / (rect.size.height - 20))
            delegate?.progress(tag: tag, top: top, value: value)
            valueLabel.text = "\(value)%"
        }
    }
}

protocol TouchBarValueViewDelegate: NSObjectProtocol {
    func progress(tag: Int, top: CGFloat, value: Int)
}
