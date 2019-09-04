//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  TopView.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/28.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class TopView: UIView {
    
    var drawView: UIView!
    var dotView: UIView!
    var floatView: UIView!
    var drawHeight: CGFloat = 0
    var currentItem = 0 // 当前的模式
    var moveTimeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabelValueViews()
        initLineView()
        initForDrawView()
        initDotView()
        initFloatView()
    }

    private func initLabelValueViews() {
        let labels = ["12AM", "4AM", "8AM", "12PM", "4PM", "8PM", "12AM"]
        for i in 0..<labels.count {
            let label = UILabel().then {
                $0.textColor = UIColor.darkGray
                $0.font = UIFont.systemFont(ofSize: 10)
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
                $0.top.equalTo(20)
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
            $0.top.equalTo(80)
        }
    }
    
    /// 初始化折线视图
    private func initForDrawView() {
        let topHeight = AppDelegate.isSameToIphoneX() ? 88 : 64
        let bottomHeight = AppDelegate.isSameToIphoneX() ? 83 : 49
        let height = (Dimension.screenHeight - CGFloat(topHeight + bottomHeight + 1)) / 2
        drawHeight = height - CGFloat(51 + 40 + 44)
        drawView = UIView()
        addSubview(drawView)
        drawView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(51)
            $0.height.equalTo(drawHeight)
        }
        drawLine()
    }
    
    /// 画线
    private func drawLine() {
        let colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        for i in 0..<colors.count {
            let shapeLayer = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: drawHeight))
            path.addLine(to: CGPoint(x: 100, y: drawHeight - CGFloat(10 * (i + 1))))
            path.addLine(to: CGPoint(x: 200, y: drawHeight - CGFloat(11 * (i + 1))))
            path.addLine(to: CGPoint(x: Dimension.screenWidth - 40, y: drawHeight))
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = colors[i].cgColor
            shapeLayer.frame = CGRect(x: 20, y: 0, width: Dimension.screenWidth - 40, height: drawHeight)
            drawView.layer.addSublayer(shapeLayer)
        }
        
    }
    
    /// 点视图
    private func initDotView() {
        dotView = UIView().then {
            $0.backgroundColor = Color.bar6.withAlphaComponent(0.5)
        }
        addSubview(dotView)
        dotView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(drawView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-44)
        }
    }
    
    private func initFloatView() {
        floatView = UIView()
        addSubview(floatView)
        floatView.snp.makeConstraints {
            $0.top.equalTo(60)
            $0.width.equalTo(40)
            $0.left.equalTo(20)
            $0.bottom.equalTo(dotView.snp.bottom)
        }
        
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 20), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = Color.circleBG.cgColor
        floatView.layer.insertSublayer(shapeLayer, at: 0)
        
        moveTimeLabel = UILabel().then {
            $0.textAlignment = .center
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 8)
            $0.text = "7:30 AM"
        }
        floatView.addSubview(moveTimeLabel)
        moveTimeLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let dotButton = UIButton(type: .custom).then {
            $0.backgroundColor = .clear
        }
        floatView.addSubview(dotButton)
        dotButton.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(dotView.snp.top)
        }
        
        let middleView = UIView().then {
            $0.backgroundColor = Color.circleBG.withAlphaComponent(0.5)
        }
        floatView.addSubview(middleView)
        middleView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(moveTimeLabel.snp.bottom)
            $0.bottom.equalTo(dotButton.snp.top)
        }
        
        let redBigImageView = UIImageView().then {
            $0.backgroundColor = UIColor.white
            $0.layer.borderColor = Color.circleBG.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 10
        }
        floatView.addSubview(redBigImageView)
        redBigImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.top.equalTo(dotButton.snp.top).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        let redSmallImageView = UIImageView().then {
            $0.backgroundColor = Color.circleBG
            $0.layer.cornerRadius = 5
        }
        floatView.addSubview(redSmallImageView)
        redSmallImageView.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.center.equalTo(redBigImageView.snp.center)
        }
        
        let redLineImageView = UIImageView().then {
            $0.backgroundColor = Color.circleBG
        }
        floatView.addSubview(redLineImageView)
        redLineImageView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalTo(moveTimeLabel.snp.bottom)
            $0.bottom.equalTo(redBigImageView.snp.top)
            $0.centerX.equalToSuperview()
        }
    }

}
