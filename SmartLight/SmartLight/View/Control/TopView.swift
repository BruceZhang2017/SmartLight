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
    var moveTimeLabel: UILabel!
    var left: CGFloat = 0 {
        didSet {
            floatView.snp.updateConstraints {
                $0.left.equalTo(left)
            }
            moveTimeLabel.text = leftToTime(value: left)
        }
    }
    weak var delegate: TopViewDelegate?
    var canTouch = true
    var totalHeight: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabelValueViews()
        initLineView()
        initForDrawView()
        initDotView()
        initFloatView()
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
                $0.tag = 10000 + i
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
        totalHeight = height
        drawHeight = height - CGFloat(51 + 40 + 44)
        drawView = UIView()
        addSubview(drawView)
        drawView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(51)
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
        if deviceModel.pattern?.items.count == 0 {
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
            path.move(to: CGPoint(x: 0, y: drawHeight))
            for j in 0..<(deviceModel.pattern?.items.count ?? 0) {
                let x = CGFloat(deviceModel.pattern?.items[j].time ?? 0) / CGFloat(1440) * (Dimension.screenWidth - 40)
                if x == 0 {
                    continue
                }
                //print("x: \(x)")
                var h = 0
                switch i {
                case 0:
                    h = deviceModel.pattern?.items[j].intensity[0] ?? 0
                case 1:
                    h = deviceModel.pattern?.items[j].intensity[1] ?? 0
                case 2:
                    h = deviceModel.pattern?.items[j].intensity[2] ?? 0
                case 3:
                    h = deviceModel.pattern?.items[j].intensity[3] ?? 0
                case 4:
                    h = deviceModel.pattern?.items[j].intensity[4] ?? 0
                case 5:
                    h = deviceModel.pattern?.items[j].intensity[5] ?? 0
                default:
                    continue
                }
                let point = CGPoint(x: x, y: (drawHeight - 29) * CGFloat(100 - h) / CGFloat(100) + 29)
                //print("point: \(point.x) \(point.y)")
                path.addLine(to: point)
            }
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
    
    func addDotButtons(currentPattern: PatternModel, current: Int) {
        for view in dotView.subviews {
            view.removeFromSuperview()
        }
        for j in 0..<currentPattern.items.count {
            let button = UIButton(type: .custom).then {
                $0.setImage(UIImage(named: "蓝色圆圈"), for: .normal)
                if j == current && floatView.isHidden == false {
                    $0.isHidden = true
                } else {
                    $0.isHidden = false
                }
                $0.tag = 1000 * (currentPattern.items[j].time) + j
                $0.addTarget(self, action: #selector(tapDot(_:)), for: .touchUpInside)
            }
            dotView.addSubview(button)
            button.snp.makeConstraints {
                $0.width.height.equalTo(40)
                $0.centerY.equalToSuperview()
                let x = CGFloat(currentPattern.items[j].time) / CGFloat(1440) * (Dimension.screenWidth - 40)
                $0.left.equalTo(x - 20)
            }
        }
    }
    
    @objc private func tapDot(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let tag = button.tag % 1000
        let time = button.tag / 1000
        left = timeToLeft(value: time)
        floatView.isHidden = false
        delegate?.touchCurrent(tag)
    }
    
    private func initFloatView() {
        floatView = UIView().then {
            $0.isHidden = true
        }
        addSubview(floatView)
        floatView.snp.makeConstraints {
            $0.top.equalTo(60)
            $0.width.equalTo(40)
            $0.left.equalTo(left)
            $0.bottom.equalTo(dotView.snp.bottom)
        }
        
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 20), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5))
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = Color.circleBG.cgColor
        floatView.layer.insertSublayer(shapeLayer, at: 0)
        
        moveTimeLabel = UILabel().then {
            $0.textAlignment = .center
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 7)
            $0.text = "12:00 " + "am".localized()
        }
        floatView.addSubview(moveTimeLabel)
        moveTimeLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let dotButton = UIButton(type: .custom).then {
            $0.backgroundColor = .clear
            $0.tag = 2
        }
        floatView.addSubview(dotButton)
        dotButton.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(dotView.snp.top)
        }
        
        let middleView = UIView().then {
            $0.backgroundColor = Color.circleBG.withAlphaComponent(0.2)
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
            $0.tag = 4
        }
        floatView.addSubview(redBigImageView)
        redBigImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.centerY.equalTo(dotButton.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        let redSmallImageView = UIImageView().then {
            $0.backgroundColor = Color.circleBG
            $0.layer.cornerRadius = 5
            $0.tag = 5
        }
        floatView.addSubview(redSmallImageView)
        redSmallImageView.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.center.equalTo(redBigImageView.snp.center)
        }
        
        let redLineImageView = UIImageView().then {
            $0.backgroundColor = Color.circleBG
            $0.tag = 3
        }
        floatView.addSubview(redLineImageView)
        redLineImageView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalTo(moveTimeLabel.snp.bottom)
            $0.bottom.equalTo(redBigImageView.snp.top)
            $0.centerX.equalToSuperview()
        }
    }
    
//    public func setFloatViewDot(isShown: Bool) {
//        let button = floatView.viewWithTag(2) as! UIButton
//        let imageView = floatView.viewWithTag(3) as! UIImageView
//        let imageViewB = floatView.viewWithTag(4) as! UIImageView
//        let imageViewC = floatView.viewWithTag(5) as! UIImageView
//        button.isHidden = !isShown
//        imageView.isHidden = !isShown
//        imageViewB.isHidden = !isShown
//        imageViewC.isHidden = !isShown
//    }
    
    func showAllDotButton() {
        if dotView.subviews.count == 0 {
            return
        }
        for subView in dotView.subviews {
            if subView is UIButton {
                subView.isHidden = false
            }
        }
    }
    
    func refreshLabel() {
        let labels = ["12" + "am".localized(),
        "4" + "am".localized(),
        "8" + "am".localized(),
        "12" + "pm".localized(),
        "4" + "pm".localized(),
        "8" + "pm".localized(),
        "12" + "am".localized()]
        for subView in subviews {
            if subView.tag >= 10000 {
                if subView.tag - 10000 < labels.count {
                    if let label = subView as? UILabel {
                        label.text = labels[subView.tag - 10000]
                    }
                }
            }
        }
    }
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !canTouch {
            return
        }
        let touch = (touches as NSSet).anyObject() as AnyObject
        let point = touch.location(in:self)
        if point.y >= totalHeight - 88 && point.y <= totalHeight {
            return
        }
        //print("start: \(point.x) \(point.y)")
        let tem = min(Dimension.screenWidth - 20, max(0, point.x - 20))
        let time = leftToTimeInt(value: tem)
        if (delegate?.readBeforeValue() ?? 0) >= time {
            return
        }
        if (delegate?.readAfterValue() ?? 0) > 0 && (delegate?.readAfterValue() ?? 0) <= time {
            return
        }
        if point.x >= Dimension.screenWidth - 20 {
            return
        }
        left = tem
        delegate?.touchValue(left)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !canTouch {
            return
        }
        let touch = (touches as NSSet).anyObject() as AnyObject
        let point = touch.location(in:self)
        if point.y >= totalHeight - 88 && point.y <= totalHeight {
            return
        }
        //print("move: \(point.x) \(point.y)")
        let tem = min(Dimension.screenWidth - 20, max(0, point.x - 20))
        let time = leftToTimeInt(value: tem)
        if (delegate?.readBeforeValue() ?? 0) >= time {
            return
        }
        if (delegate?.readAfterValue() ?? 0) > 0 && (delegate?.readAfterValue() ?? 0) <= time {
            return
        }
        if point.x >= Dimension.screenWidth - 20 {
            return
        }
        left = tem
        delegate?.touchValue(left)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !canTouch {
            return
        }
        let touch = (touches as NSSet).anyObject() as AnyObject
        let point = touch.location(in:self)
        if point.y >= totalHeight - 88 && point.y <= totalHeight {
            return
        }
        //print("cancel: \(point.x) \(point.y)")
        let tem = min(Dimension.screenWidth - 20, max(0, point.x - 20))
        let time = leftToTimeInt(value: tem)
        if (delegate?.readBeforeValue() ?? 0) >= time {
            return
        }
        if (delegate?.readAfterValue() ?? 0) > 0 && (delegate?.readAfterValue() ?? 0) <= time {
            return
        }
        if point.x >= Dimension.screenWidth - 20 {
            return
        }
        left = tem
        delegate?.touchValue(left)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !canTouch {
            return
        }
        let touch = (touches as NSSet).anyObject() as AnyObject
        let point = touch.location(in:self)
        if point.y >= totalHeight - 88 && point.y <= totalHeight {
            return
        }
        //print("end: \(point.x) \(point.y)")
        let tem = min(Dimension.screenWidth - 20, max(0, point.x - 20))
        let time = leftToTimeInt(value: tem)
        if (delegate?.readBeforeValue() ?? 0) >= time {
            return
        }
        if (delegate?.readAfterValue() ?? 0) > 0 && (delegate?.readAfterValue() ?? 0) <= time {
            return
        }
        if point.x >= Dimension.screenWidth - 20 {
            return
        }
        left = tem
        delegate?.touchValue(left)
    }
    
    public func leftToTime(value: CGFloat) -> String {
        let time = Int(value * CGFloat(1440) / (Dimension.screenWidth - 40))
        var h = time / 60
        let m = time % 60
        if h >= 12 {
            return String(format: "%02d", h > 12 ? (h - 12) : h) + ":" + String(format: "%02d", m) + " " + "pm".localized()
        } else {
            if h == 0 {
                h = 12
            }
            return String(format: "%02d", h) + ":" + String(format: "%02d", m) + " " + "am".localized()
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

protocol TopViewDelegate: NSObjectProtocol {
    func touchValue(_ pointX: CGFloat)
    func touchCurrent(_ current: Int)
    func readBeforeValue() -> Int
    func readAfterValue() -> Int
}
