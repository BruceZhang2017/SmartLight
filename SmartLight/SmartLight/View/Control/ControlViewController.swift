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
import Toaster

class ControlViewController: BaseViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var topView: TopView!
    @IBOutlet weak var topManualView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    let colors = [Color.yellow, Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
    var patterns: PatternListModel!
    var currentPattern: PatternModel!
    var powerValueLabel: UILabel!
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var once = false
    var currentItem = 0 // 当前编辑的点
    var smallShapeLayer: CAShapeLayer!
    var powerShapeLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        currentPattern =  deviceModel.pattern ?? PatternModel()
        patterns = PatternListModel.down()
        setLeftNavigationItem()
        setRightNavigationItem()
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.tintColor = UIColor.white
        topView.delegate = self
        initBarValueViews()
        initbttonValueViews()
        initCircelView() // 初始化圆
        refreshTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if once {
            return
        }
        once = true
        for i in 0..<colors.count {
            let view = bottomView.viewWithTag(i + 100) as! TouchBarValueView
            let rect = bottomView.bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 56, right: 0))
            view.topLConstraint.constant = rect.size.height
        }
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
                $0.delegate = self
                $0.tag = i + 100
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
        let buttonTitles = ["中间-加号", "中间-减号", "中间-左箭头", "中间-右箭头", "中间-三角形", "中间-五角星", "中间-更多"]
        let count = buttonTitles.count
        for i in 0..<count {
            let button = UIButton(type: .custom).then {
                $0.addTarget(self, action: #selector(handleEvent(_:)), for: .touchUpInside)
                $0.setImage(UIImage(named: buttonTitles[i]), for: .normal)
                $0.tag = i
            }
            
            let space = (Dimension.screenWidth - CGFloat(40 + 30 * count)) / CGFloat(count - 1)
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
        
        smallShapeLayer = CAShapeLayer()
        let pathB = UIBezierPath(arcCenter: CGPoint(x: Dimension.screenWidth / 2, y: height / 2), radius: 80, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)
        smallShapeLayer.path = pathB.cgPath
        smallShapeLayer.fillColor = UIColor.white.cgColor
        topManualView.layer.addSublayer(smallShapeLayer)
        
        powerValueLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.boldSystemFont(ofSize: 30)
            $0.text = "0%"
        }
        topManualView.addSubview(powerValueLabel)
        powerValueLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        let powerLabel = UILabel().then {
            $0.textColor = UIColor.black
            $0.font = UIFont.boldSystemFont(ofSize: 30)
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
        showPowerValue()
    }
    
    private func showPowerValue() {
        let topHeight = AppDelegate.isSameToIphoneX() ? 88 : 64
        let bottomHeight = AppDelegate.isSameToIphoneX() ? 83 : 49
        let height = (Dimension.screenHeight - CGFloat(topHeight + bottomHeight + 1)) / 2
        powerShapeLayer = CAShapeLayer()
        let path = UIBezierPath(arcCenter: CGPoint(x: Dimension.screenWidth / 2, y: height / 2), radius: 80, startAngle: CGFloat(Double.pi / -2), endAngle: CGFloat(Double.pi * 3 / 2), clockwise: true)
        powerShapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        powerShapeLayer.position = CGPoint(x: Dimension.screenWidth / 2, y: height / 2)
        powerShapeLayer.frame = CGRect(x: 0, y: 0, width: Dimension.screenWidth, height: height)
        powerShapeLayer.path = path.cgPath
        powerShapeLayer.strokeColor = Color.power.cgColor
        powerShapeLayer.fillColor = UIColor.clear.cgColor
        powerShapeLayer.strokeStart = 0
        powerShapeLayer.strokeEnd = 0
        powerShapeLayer.lineWidth = 80
        topManualView.layer.insertSublayer(powerShapeLayer, below: smallShapeLayer)
    }
    
    func refreshPower() {
        var power = CGFloat(currentPattern.manual?.uv ?? 0) * CGFloat(0.16)
        power += CGFloat(currentPattern.manual?.db ?? 0) * 0.3
        power += CGFloat(currentPattern.manual?.b ?? 0) * 0.3
        power += CGFloat(currentPattern.manual?.g ?? 0) * 0.01
        power += CGFloat(currentPattern.manual?.dr ?? 0) * 0.01
        power += CGFloat(currentPattern.manual?.cw ?? 0) * 0.22
        let p = Int(power)
        if p == 0 {
            return
        }
        powerShapeLayer.strokeEnd = CGFloat(p) / CGFloat(100)
        powerValueLabel.text = "\(p)%"
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
        currentPattern.isManual = segmentedControl.selectedSegmentIndex != 0
        topView.isHidden = segmentedControl.selectedSegmentIndex != 0
        topManualView.isHidden = segmentedControl.selectedSegmentIndex == 0
        if currentPattern.manual == nil && topManualView.isHidden == false {
            let item = PatternItemModel()
            item.time =  0
            item.uv = 0
            item.db = 0
            item.b = 0
            item.g = 0
            item.dr = 0
            item.cw = 0
            currentPattern.manual = item
        }
        saveSchedule()
    }
    
    @objc private func handleEvent(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let tag = button.tag
        switch tag {
        case 0: // 增加点
            if currentPattern.items.count >= 4 {
                return
            }
            let item = PatternItemModel()
            let last = currentPattern.items.last?.time ?? 0
            item.time =  last > 0 ? (last + 60) : 0
            item.uv = currentPattern.items.last?.uv ?? 0
            item.db = currentPattern.items.last?.db ?? 0
            item.b = currentPattern.items.last?.b ?? 0
            item.g = currentPattern.items.last?.g ?? 0
            item.dr = currentPattern.items.last?.dr ?? 0
            item.cw = currentPattern.items.last?.cw ?? 0
            currentPattern.items.append(item)
            currentItem = currentPattern.items.count - 1
            topView.floatView.isHidden = false
            topView.left = topView.timeToLeft(value: item.time)
            refreshTopView()
            saveSchedule()
        case 1: // 删除点
            if currentPattern.items.count > 0 {
                currentPattern.items.removeLast()
                currentItem = 0
                topView.floatView.isHidden = true
                refreshTopView()
                saveSchedule()
            }
        case 2: // 左移
            if topView.floatView.isHidden == false {
                let w = 10 * (Dimension.screenWidth - 40) / 1440
                if currentItem > 0 {
                    let pre = topView.timeToLeft(value: currentPattern.items[currentItem - 1].time)
                    if topView.left - w >= pre + 40 {
                        return
                    }
                } else {
                    if topView.left - w <= 0 {
                        return
                    }
                }
                topView.left -= w
                currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                refreshTopView()
                saveSchedule()
            }
        case 3: // 右移
            if topView.floatView.isHidden == false {
                let w = 10 * (Dimension.screenWidth - 40) / 1440
                if currentItem < currentPattern.items.count - 1 {
                    let pre = topView.timeToLeft(value: currentPattern.items[currentItem + 1].time)
                    if topView.left + w + 40 >= pre {
                        return
                    }
                } else {
                    if topView.left + w + 40 >= Dimension.screenWidth - 40 {
                        return
                    }
                }
                topView.left += w
                currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                refreshTopView()
                saveSchedule()
            }
        case 4:
            print("需要和固件端联调")
        case 5:
            let alert = UIAlertController(title: "Save Current Settings", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak alert, weak self] (action) in
                guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    return
                }
                guard let self = self else { return }
                self.currentPattern.name = name
                self.patterns?.patterns.append(self.currentPattern)
                self.patterns?.save()
            }))
            present(alert, animated: true, completion: nil)
        case 6:
            let storyboard = UIStoryboard(name: .kSBNameControl, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDPreset)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            Toast(text: "正在开发 \(tag)").show()
        }
    }
    
    /// 刷新topView的折线
    private func refreshTopView() {
        topView.drawLine(currentPattern: currentPattern)
        topView.addDotButtons(currentPattern: currentPattern, current: currentItem)
    }
    
    private func saveSchedule() {
        deviceModel.pattern = currentPattern
        deviceListModel.groups[DeviceManager.sharedInstance.currentIndex] = deviceModel
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightSchedual(pattern: currentPattern)
    }
}

extension ControlViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}

extension ControlViewController: TouchBarValueViewDelegate {
    func progress(tag: Int, top: CGFloat, value: Int) {
        if tag == 100 {
            for i in 1..<colors.count {
                let view = bottomView.viewWithTag(i + 100) as! TouchBarValueView
                view.setValue(value)
            }
            if topManualView.isHidden == false {
                currentPattern.manual?.uv = value
                currentPattern.manual?.db = value
                currentPattern.manual?.b = value
                currentPattern.manual?.g = value
                currentPattern.manual?.dr = value
                currentPattern.manual?.cw = value
                refreshPower()
                saveSchedule()
                return
            }
            if currentPattern.items.count > 0 {
                currentPattern.items[currentItem].uv = value
                currentPattern.items[currentItem].db = value
                currentPattern.items[currentItem].b = value
                currentPattern.items[currentItem].g = value
                currentPattern.items[currentItem].dr = value
                currentPattern.items[currentItem].cw = value
                refreshTopView()
                saveSchedule()
            }
        } else {
            if topManualView.isHidden == false {
                if tag == 101 {
                    currentPattern.manual?.uv = value
                } else if tag == 102 {
                    currentPattern.manual?.db = value
                } else if tag == 103 {
                    currentPattern.manual?.b = value
                } else if tag == 104 {
                    currentPattern.manual?.g = value
                } else if tag == 105 {
                    currentPattern.manual?.dr = value
                } else if tag == 106 {
                    currentPattern.manual?.cw = value
                }
                refreshPower()
                saveSchedule()
            } else {
                if currentPattern.items.count > 0 {
                    if tag == 101 {
                        currentPattern.items[currentItem].uv = value
                    } else if tag == 102 {
                        currentPattern.items[currentItem].db = value
                    } else if tag == 103 {
                        currentPattern.items[currentItem].b = value
                    } else if tag == 104 {
                        currentPattern.items[currentItem].g = value
                    } else if tag == 105 {
                        currentPattern.items[currentItem].dr = value
                    } else if tag == 106 {
                        currentPattern.items[currentItem].cw = value
                    }
                    refreshTopView()
                    saveSchedule()
                }
            }
        }
    }
    
    
}

extension ControlViewController: TopViewDelegate {
    func touchValue(_ pointX: CGFloat) {
        if currentItem >= currentPattern.items.count {
            return
        }
        currentPattern.items[currentItem].time = Int((pointX) / (Dimension.screenWidth - 40) * 1440)
        refreshTopView()
        saveSchedule()
    }
    
    func touchCurrent(_ current: Int) {
        currentItem = current
        if currentItem >= currentPattern.items.count {
            return
        }
        for i in 1..<colors.count {
            let view = bottomView.viewWithTag(i + 100) as! TouchBarValueView
            if i == 1 {
                view.setValue(currentPattern.items[currentItem].uv)
            } else if i == 2 {
                view.setValue(currentPattern.items[currentItem].db)
            } else if i == 3 {
                view.setValue(currentPattern.items[currentItem].b)
            } else if i == 4 {
                view.setValue(currentPattern.items[currentItem].g)
            } else if i == 5 {
                view.setValue(currentPattern.items[currentItem].dr)
            } else if i == 6 {
                view.setValue(currentPattern.items[currentItem].cw)
            }
        }
        topView.addDotButtons(currentPattern: currentPattern, current: currentItem)
    }
}
