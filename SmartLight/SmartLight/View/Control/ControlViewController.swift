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
    @IBOutlet weak var topView: TopView!
    @IBOutlet weak var topManualView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    
    var patterns: PatternListModel!
    var powerValueLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patterns = PatternListModel.load()
        setLeftNavigationItem()
        setRightNavigationItem()
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.tintColor = UIColor.white
        initBarValueViews()
        initbttonValueViews()
        initCircelView() // 初始化圆
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        let buttonTitles = ["中间-加号", "中间-减号", "中间-返回", "中间-左箭头", "中间-右箭头", "中间-三角形", "中间-垃圾桶", "中间-五角星", "中间-更多"]
        for i in 0..<buttonTitles.count {
            let button = UIButton(type: .custom).then {
                $0.addTarget(self, action: #selector(handleEvent(_:)), for: .touchUpInside)
                $0.setImage(UIImage(named: buttonTitles[i]), for: .normal)
                $0.tag = i
            }
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
        
        let lightningImageView = UIImageView().then {
            $0.image = UIImage(named: "闪电")
        }
        topManualView.addSubview(lightningImageView)
        lightningImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(powerValueLabel.snp.top).offset(-2)
            $0.width.equalTo(32)
            $0.height.equalTo(52)
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
