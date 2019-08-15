//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  ControlViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/13.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class ControlViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topManualView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    var drawView: UIView!
    var dotView: UIView!
    var floatView: UIView!
    var drawHeight: CGFloat = 0
    var currentItem = 0 // 当前的模式
    var patterns: PatternListModel!
    var powerValueLabel: UILabel!
    var moveTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patterns = PatternListModel.load()
        setLeftNavigationItem()
        setRightNavigationItem()
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.tintColor = UIColor.white
        initBarValueViews()
        initLabelValueViews()
        initbttonValueViews()
        initLineView()
        initForDrawView()
        initDotView()
        initCircelView() // 初始化圆
        initFloatView()
    }
    
    private func setLeftNavigationItem() {
        let leftItem = UIBarButtonItem(image: UIImage.top_menu, style: .plain, target: self, action: #selector(pushToMenu))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setRightNavigationItem() {
        let rightItem = UIBarButtonItem(image: UIImage.top_qrcode, style: .plain, target: self, action: #selector(pushToQRCode))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func initBarValueViews() {
        let colors = [Color.yellow, Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        
        for i in 0..<colors.count {
            guard let barValueView = Bundle.main.loadNibNamed(.kTouchBarValueView, owner: nil, options: nil)?.first as? TouchBarValueView else {
                return
            }
            barValueView.do {
                $0.titleLabel.text = i == 0 ? "All" : Arrays.barTitles[i - 1]
                $0.valueLabel.text = "0%"
                $0.currentValueImageView.backgroundColor = colors[i]
                $0.settingValueImageView.backgroundColor = colors[i]
                $0.smallImageView.backgroundColor = colors[i]
                $0.circleImageView.layer.borderColor = UIColor.lightGray.cgColor
                $0.circleImageView.layer.borderWidth = 0.5
            }
            let width = (Dimension.screenWidth - 40) / CGFloat(colors.count)
            let x = 20 + width * CGFloat(i)
            bottomView.addSubview(barValueView)
            barValueView.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.equalTo(width)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func initbttonValueViews() {
        for i in 0..<9 {
            let button = UIButton(type: .custom).then {
                $0.addTarget(self, action: #selector(handleEvent(_:)), for: .touchUpInside)
                $0.tag = i
            }
            button.backgroundColor = UIColor.black
            let space = (Dimension.screenWidth - 40 - 30 * 9) / 8
            let x = 20 + 30 * CGFloat(i) + space * CGFloat(i)
            buttonsView.addSubview(button)
            button.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.height.equalTo(30)
                $0.centerY.equalToSuperview()
            }
        }
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
            topView.addSubview(label)
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
        topView.addSubview(lineImageView)
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
        topView.addSubview(drawView)
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
        topView.addSubview(dotView)
        dotView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(drawView.snp.bottom)
            $0.bottom.equalTo(buttonsView.snp.top)
        }
    }
    
    /// POWER
    private func initCircelView() {
        let topHeight = AppDelegate.isSameToIphoneX() ? 88 : 64
        let bottomHeight = AppDelegate.isSameToIphoneX() ? 83 : 49
        let height = (Dimension.screenHeight - CGFloat(topHeight + bottomHeight + 1)) / 2
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(arcCenter: CGPoint(x: Dimension.screenWidth / 2, y: height / 2), radius: 120, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = Color.cirBG.cgColor
        topManualView.layer.addSublayer(shapeLayer)
        
        let smallShapeLayer = CAShapeLayer()
        let pathB = UIBezierPath(arcCenter: CGPoint(x: Dimension.screenWidth / 2, y: height / 2), radius: 80, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
        smallShapeLayer.path = pathB.cgPath
        smallShapeLayer.fillColor = UIColor.white.cgColor
        topManualView.layer.addSublayer(smallShapeLayer)
        
        powerValueLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 30)
            $0.text = "0%"
        }
        topManualView.addSubview(powerValueLabel)
        powerValueLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        let powerLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.systemFont(ofSize: 30)
            $0.text = "POWER"
        }
        topManualView.addSubview(powerLabel)
        powerLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(powerValueLabel.snp.bottom)
        }
    }
    
    private func initFloatView() {
        floatView = UIView()
        topView.addSubview(floatView)
        floatView.snp.makeConstraints {
            $0.top.equalTo(60)
            $0.width.equalTo(40)
            $0.left.equalTo(20)
            $0.bottom.equalTo(dotView.snp.bottom)
        }
        
        moveTimeLabel = UILabel().then {
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 20), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = Color.circleBG.cgColor
            $0.layer.addSublayer(shapeLayer)
            $0.textAlignment = .center
            $0.textColor = UIColor.white
            $0.font = UIFont.systemFont(ofSize: 8)
        }
        floatView.addSubview(moveTimeLabel)
        moveTimeLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        let dotButton = UIButton(type: .custom).then {
            $0.backgroundColor = Color.bar6.withAlphaComponent(0.5)
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
        
    }
    
    // MARK: - Action
    
    @objc private func pushToMenu() {
        let storyboard = UIStoryboard(name: .kSBNameDevice, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceList) as! DeviceListViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func pushToQRCode() {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")
        let vc = LBXScanViewController()
        vc.scanStyle = style
        vc.scanResultDelegate = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func valueChanged(_ sender: Any) {
        topView.isHidden = segmentedControl.selectedSegmentIndex != 0
        topManualView.isHidden = segmentedControl.selectedSegmentIndex == 0
    }
    
    @objc private func handleEvent(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let tag = button.tag
        switch tag {
        case 8:
            let storyboard = UIStoryboard(name: .kSBNameControl, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDPreset)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            print(tag)
        }
    }
}

extension ControlViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}
