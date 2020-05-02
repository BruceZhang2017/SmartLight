//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  BottomView.swift
//  SmartLight
//
//  Created by ANKER on 2019/11/20.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class BottomView: UIView {
    
    var drawView: UIView!
    var leftRedView: UIView!
    var rightRedView: UIView!
    var drawHeight: CGFloat = 230
    var rampALabel: UILabel!
    var rampBLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabelValueViews()
        initLineView()
        initForDrawView()
        initFloatView()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    private func initLabelValueViews() {
        let labels = ["12" + "am".localized(),
                      "4" + "am".localized(),
                      "8" + "am".localized(),
                      "12" + "pm".localized(),
                      "4" + "pm".localized(),
                      "8" + "pm".localized(),
                      "12" + "am".localized()]
        for i in 0..<labels.count {
            let label = UILabel().then {
                $0.textColor = UIColor.darkGray
                $0.font = UIFont.systemFont(ofSize: 9)
                $0.text = labels[i]
            }
            let w = CGFloat(30 * labels.count)
            let space = (Dimension.screenWidth - 40 - w) / 6
            let x = 20 + 30 * CGFloat(i) + space * CGFloat(i)
            addSubview(label)
            label.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.equalTo(30)
                $0.height.equalTo(20)
                $0.top.equalTo(10)
            }
        }
    }
        
    /// 初始化线
    private func initLineView() {
        let lineImageView = UIImageView().then {
            $0.backgroundColor = Color.line
        }
        addSubview(lineImageView)
        lineImageView.snp.makeConstraints {
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(1)
            $0.top.equalTo(40)
        }
    }
        
    /// 初始化折线视图
    private func initForDrawView() {
        drawView = UIView()
        addSubview(drawView)
        drawView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(60)
            $0.height.equalTo(drawHeight)
        }
    }
        
    /// 画线
    func drawLine(deviceModel: DeviceModel) {
        if let layers = drawView.layer.sublayers {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        guard let accl = deviceModel.acclimation else {
            return
        }
        if accl.startTime == 0 {
            return
        }
        if accl.endTime == 0 {
            return
        }
        var colors: [UIColor] = []
        if deviceModel.deviceType == 3 {
            colors = [Color.bar6, Color.bar2, Color.bar5]
        } else {
            colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        }
        for i in 0..<colors.count {
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath()
            let h = accl.intesity[i]
            let value = drawHeight * CGFloat(100 - h) / CGFloat(100)
            if accl.startTime < accl.endTime {
                path.move(to: CGPoint(x: 0, y: drawHeight))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.startTime), y: drawHeight))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.startTime + accl.ramp * 60), y: value))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.endTime - accl.ramp * 60), y: value))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.endTime), y: drawHeight))
                path.addLine(to: CGPoint(x: Dimension.screenWidth - 40, y: drawHeight))
            } else {
                path.move(to: CGPoint(x: 0, y: value))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.endTime - accl.ramp * 60), y: value))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.endTime), y: drawHeight))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.startTime), y: drawHeight))
                path.addLine(to: CGPoint(x: timeToLeft(value: accl.startTime + accl.ramp * 60), y: value))
                path.addLine(to: CGPoint(x: Dimension.screenWidth - 40, y: value))
            }
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = colors[i].cgColor
            shapeLayer.frame = CGRect(x: 20, y: 0, width: Dimension.screenWidth - 40, height: drawHeight)
            drawView.layer.addSublayer(shapeLayer)
        }
        
        leftRedView.snp.updateConstraints {
            $0.left.equalTo(timeToLeft(value: accl.startTime) + 20)
            $0.width.equalTo(CGFloat(accl.ramp) / CGFloat(24) * (Dimension.screenWidth - 40))
        }
        rightRedView.snp.updateConstraints {
            $0.left.equalTo(timeToLeft(value: accl.endTime - accl.ramp * 60) + 20)
            $0.width.equalTo(CGFloat(accl.ramp) / CGFloat(24) * (Dimension.screenWidth - 40))
        }
        if accl.ramp > 0 {
            rampALabel.text = "txt_ramp".localized() + "\(accl.ramp)"
            rampBLabel.text = "txt_ramp".localized() + "\(accl.ramp)"
        } else {
            rampALabel.text = ""
            rampBLabel.text = ""
        }
    }
        
    private func initFloatView() {
        leftRedView = UIView().then {
            $0.backgroundColor = Color.circleBG.withAlphaComponent(0.2)
        }
        addSubview(leftRedView)
        leftRedView.snp.makeConstraints {
            $0.left.equalTo(0)
            $0.top.equalTo(60)
            $0.bottom.equalTo(-10)
            $0.width.equalTo(0)
        }
        
        rightRedView = UIView().then {
            $0.backgroundColor = Color.circleBG.withAlphaComponent(0.2)
        }
        addSubview(rightRedView)
        rightRedView.snp.makeConstraints {
            $0.left.equalTo(0)
            $0.top.equalTo(60)
            $0.bottom.equalTo(-10)
            $0.width.equalTo(0)
        }
        
        let lineImageView = UIImageView().then {
            $0.backgroundColor = Color.line
        }
        addSubview(lineImageView)
        lineImageView.snp.makeConstraints {
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(1)
            $0.bottom.equalTo(-10)
        }
        
        rampALabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.text = ""
        }
        addSubview(rampALabel)
        rampALabel.snp.makeConstraints {
            $0.centerX.equalTo(leftRedView.snp.centerX)
            $0.bottom.equalTo(leftRedView.snp.top).offset(-2)
        }
        
        rampBLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.text = ""
        }
        addSubview(rampBLabel)
        rampBLabel.snp.makeConstraints {
            $0.centerX.equalTo(rightRedView.snp.centerX)
            $0.bottom.equalTo(leftRedView.snp.top).offset(-2)
        }
    }
        
    func leftToTimeInt(value: CGFloat) -> Int {
        let time = Int(value * CGFloat(1440) / (Dimension.screenWidth - 40))
        return time
    }
        
    /// 时间转Left
    func timeToLeft(value: Int) -> CGFloat {
        let x = CGFloat(value) / CGFloat(1440) * (Dimension.screenWidth - 40)
        return min(Dimension.screenWidth - 20, max(0, x))
    }

}


