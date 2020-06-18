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
import Localize_Swift

class ControlViewController: BaseViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var topView: TopView!
    @IBOutlet weak var topManualView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    var colors: [UIColor] = []
    var patterns: PatternListModel!
    var currentPattern: PatternModel!
    var powerValueLabel: UILabel!
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var currentItem = -1 // 当前编辑的点
    var smallShapeLayer: CAShapeLayer!
    var powerShapeLayer: CAShapeLayer!
    var scan: LBXScanViewController!
    var preTimer: Timer? // 预览定时器
    var currentIndex = 0 // 当前预览节点
    var totalIndex = 0 //  总预览数量
    var detectionTimer: Timer!
    var currentTime = 0
    var once = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        setRightNavigationItem()
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.tintColor = UIColor.white
        topView.delegate = self
        
        initbttonValueViews()
        initCircelView() // 初始化圆
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: Notification.Name("ControlViewController"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DeviceManager.sharedInstance.deviceListModel.groups.count == 0 {
            return
        }
        title = "txt_control".localized()
        self.navigationController?.navigationBar.barTintColor = Color.main
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        currentPattern =  deviceModel.pattern ?? PatternModel()
        patterns = PatternListModel.down()
        refreshTopView() // 刷新顶部视图
        if deviceModel.deviceType == 3 {
            colors = [Color.yellow, Color.bar6, Color.bar2, Color.bar5]
        } else {
            colors = [Color.yellow, Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        }
        if bottomView.subviews.count == 0 {
            initBarValueViews()
        }
        topView?.refreshLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentTime == 0 {
            clock()
            let touchView = bottomView.viewWithTag(100) as? TouchBarValueView
            touchView?.setValue(0)
        }
        if deviceModel == nil {
            return
        }
        let state = deviceModel.deviceState
        let low = state & 0x0f
        if low == 8 {
            segmentedControl.selectedSegmentIndex = 1
            if currentPattern.manual == nil {
                let item = PatternItemModel()
                item.time = 0
                item.intensity = [0, 0, 0, 0, 0, 0, 0]
                currentPattern.manual = item
            }
            refreshSliderValueManual()
            refreshPower()
            topView.isHidden = true
            topManualView.isHidden = false
        } else {
            segmentedControl.selectedSegmentIndex = 0
            topView.isHidden = false
            topManualView.isHidden = true
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            refreshSliderValue(currentTime: currentTime)
        }
    }
    
    private func clock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr.count > 16 {
            let start = dateStr.index(dateStr.startIndex, offsetBy: 11)
            let end = dateStr.index(dateStr.startIndex, offsetBy: 16)
            let time = String(dateStr[start..<end])
            let array = time.components(separatedBy: ":")
            if array.count == 2 {
                currentTime = (Int(array[0]) ?? 0) * 60 + (Int(array[1]) ?? 0)
            }
        }
    }
    
    override func setText() {
        segmentedControl.setTitle("txt_auto".localized(), forSegmentAt: 0)
        segmentedControl.setTitle("txt_manual".localized(), forSegmentAt: 1)
    }
    
    private func startDetectionTimer() {
        endDetectionTimer()
        detectionTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: false)
    }
    
    private func endDetectionTimer() {
        detectionTimer?.invalidate()
        detectionTimer = nil
    }
    
    @objc private func handleTimer() {
        endDetectionTimer()
    }
    
    /// 处理通知
    @objc private func handleNotification(notification: Notification) {
        if let currentTime = notification.object as? Int {
            self.currentTime = currentTime
            if detectionTimer == nil &&
                preTimer == nil &&
                segmentedControl.selectedSegmentIndex == 0 {
                topView.floatView.isHidden = false
                currentItem = -1
                topView.left = topView.timeToLeft(value: currentTime)
                topView.floatView.isUserInteractionEnabled = false
                bottomView.isUserInteractionEnabled = false
                refreshSliderValue(currentTime: currentTime)
                topView.showAllDotButton()
            }
            return
        }
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        currentPattern =  deviceModel.pattern ?? PatternModel()
        patterns = PatternListModel.down()
        refreshTopView()
        saveSchedule()
    }
    
    private func refreshSliderValue(currentTime: Int) {
        if deviceModel == nil {
            return
        }
        for i in 1..<colors.count {
            let touchView = bottomView.viewWithTag(100 + i) as! TouchBarValueView
            let value = CurrentLightValueManager.sharedInstance.calCurrentB(deviceModel: deviceModel, currentTime: currentTime, index: i - 1)
            touchView.setValue(Int(value))
        }
    }
    
    private func refreshSliderValueManual() {
        if deviceModel == nil {
            return
        }
        for i in 1..<colors.count {
            let touchView = bottomView.viewWithTag(100 + i) as! TouchBarValueView
            touchView.setValue(Int(currentPattern.manual?.intensity[i - 1] ?? 0))
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
    
    func initBarValueViews() {
        for subView in bottomView.subviews {
            subView.removeFromSuperview()
        }
        for i in 0..<colors.count {
            guard let barValueView = Bundle.main.loadNibNamed(.kTouchBarValueView, owner: nil, options: nil)?.first as? TouchBarValueView else {
                return
            }
            barValueView.do {
                $0.titleLabel.text = i == 0 ? "txt_light_all".localized() : (deviceModel.deviceType == 3 ? Arrays.barTitleBs[i - 1] : Arrays.barTitles[i - 1])
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
        let buttonImages = ["中间-加号", "中间-减号", "中间-左箭头", "中间-右箭头", "中间-三角形", "中间-五角星", "中间-更多"]
        let count = buttonImages.count
        for i in 0..<count {
            let button = UIButton(type: .custom).then {
                $0.addTarget(self, action: #selector(handleEvent(_:)), for: .touchUpInside)
                $0.setImage(UIImage(named: buttonImages[i]), for: .normal)
                $0.tag = i
                if i == 4 {
                    $0.setImage(UIImage(named: "中间-五角星彩色"), for: .selected)
                }
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
    
    /// 刷新手动Power值
    func refreshPower() {
        var power: CGFloat = 0
        if deviceModel.deviceType == 3 {
            power += CGFloat(currentPattern.manual?.intensity[0] ?? 0) * CGFloat(0.4)
            power += CGFloat(currentPattern.manual?.intensity[1] ?? 0) * 0.4
            power += CGFloat(currentPattern.manual?.intensity[2] ?? 0) * 0.2
        } else {
            power += CGFloat(currentPattern.manual?.intensity[0] ?? 0) * CGFloat(0.16)
            power += CGFloat(currentPattern.manual?.intensity[1] ?? 0) * 0.3
            power += CGFloat(currentPattern.manual?.intensity[2] ?? 0) * 0.3
            power += CGFloat(currentPattern.manual?.intensity[3] ?? 0) * 0.01
            power += CGFloat(currentPattern.manual?.intensity[4] ?? 0) * 0.01
            power += CGFloat(currentPattern.manual?.intensity[5] ?? 0) * 0.22
        }
        let p = Int(power)
        powerShapeLayer.strokeEnd = CGFloat(p) / CGFloat(100)
        powerValueLabel.text = "\(p)%"
    }
    
    // MARK: - Action
    
    @objc private func pushToMenu() {
        if ESPTools.getCurrentWiFiSsid() == "SmartLEDLight" {
            Toast(text: "ap_mode_can_not_use".localized()).show()
            return
        }
        let storyboard = UIStoryboard(name: .kSBNameDevice, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceList) as! DeviceListViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func pushToQRCode() {
        title = "back".localized()
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
        scan = LBXScanViewController()
        scan.scanStyle = style
        scan.scanResultDelegate = self
        scan.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scan, animated: true)
    }

    @IBAction func valueChanged(_ sender: Any) {
        if currentPattern == nil {
            return
        }
        endDetectionTimer()
        currentPattern.isManual = segmentedControl.selectedSegmentIndex != 0
        topView.isHidden = segmentedControl.selectedSegmentIndex != 0
        topManualView.isHidden = segmentedControl.selectedSegmentIndex == 0
        bottomView.isUserInteractionEnabled = segmentedControl.selectedSegmentIndex == 1
        if currentPattern.manual == nil && topManualView.isHidden == false {
            let item = PatternItemModel()
            item.time =  0
            item.intensity = [0, 0, 0, 0, 0, 0, 0]
            currentPattern.manual = item
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            refreshSliderValueManual()
            refreshPower()
        }
        saveSchedule()
        if segmentedControl.selectedSegmentIndex == 0 {
            refreshSliderValue(currentTime: currentTime)
        }
    }
    
    @objc private func handleEvent(_ sender: Any) {
        if currentPattern == nil {
            return
        }
        guard let button = sender as? UIButton else {
            return
        }
        let tag = button.tag
        switch tag {
        case 0: // 增加点
            if currentPattern.items.count >= 12 {
                return
            }
            if (currentPattern.items.last?.time ?? 0) >= 23 * 60 {
                return
            }
            if currentItem >= 0 && currentItem < currentPattern.items.count - 1 {
                if currentPattern.items[currentItem + 1].time - currentPattern.items[currentItem].time <= 60 {
                    return
                }
            }
            startDetectionTimer()
            bottomView.isUserInteractionEnabled = true
            topView.floatView.isUserInteractionEnabled = true
            let item = PatternItemModel()
            if currentItem >= 0 {
                item.time = currentPattern.items[currentItem].time + 60
            } else {
                let last = currentPattern.items.last?.time ?? 0
                item.time =  last > 0 ? (last + 60) : 0 // 在最后一个点往后移动1小时
            }
            item.intensity = currentPattern.items.last?.intensity ?? [0, 0, 0, 0, 0, 0, 0]
            if currentItem >= 0 {
                currentPattern.items.insert(item, at: currentItem + 1)
                currentItem = currentItem + 1
            } else {
                currentPattern.items.append(item)
                if currentPattern.items.count > 0 {
                    currentItem = currentPattern.items.count - 1
                } else {
                    currentItem = 0
                }
                
            }
            topView.floatView.isHidden = false
            topView.left = topView.timeToLeft(value: item.time)
            refreshTopView()
            saveSchedule()
        case 1: // 删除点
            if currentPattern.items.count > 0 {
                if currentItem == -1 {
                    currentPattern.items.removeLast()
                } else {
                    if currentItem < currentPattern.items.count {
                        currentPattern.items.remove(at: currentItem)
                    }
                }
                currentItem = -1
                refreshTopView()
                saveSchedule()
            }
            if currentPattern.items.count == 0 {
                topView.floatView.isHidden = true
            } else {
                topView.left = topView.timeToLeft(value: currentPattern.items.last?.time ?? 0)
                startDetectionTimer()
            }
        case 2: // 左移
            if detectionTimer == nil {
                return
            }
            startDetectionTimer()
            bottomView.isUserInteractionEnabled = true
            if topView.floatView.isUserInteractionEnabled == true {
                let w = 1 * (Dimension.screenWidth - 40) / 1440 // 修改为1分钟
                if currentItem > 0 {
                    let pre = topView.timeToLeft(value: currentPattern.items[currentItem - 1].time)
                    print("左移：\(pre)")
                    if topView.left - w <= pre {
                        return
                    }
                    topView.left -= w
                    currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                    refreshTopView()
                    saveSchedule()
                } else {
                    print("左移")
                    if topView.left - w <= 0 {
                        return
                    }
                    topView.left -= w
                    currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                    refreshTopView()
                    saveSchedule()
                }
            }
        case 3: // 右移
            if detectionTimer == nil {
                return
            }
            startDetectionTimer()
            bottomView.isUserInteractionEnabled = true
            if topView.floatView.isUserInteractionEnabled == true {
                let w = 1 * (Dimension.screenWidth - 40) / 1440 // 修改为1分钟
                if currentItem < currentPattern.items.count - 1 {
                    let pre = topView.timeToLeft(value: currentPattern.items[currentItem + 1].time)
                    print("右移：\(pre)")
                    if topView.left + w >= pre {
                        return
                    }
                    topView.left += w
                    currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                    refreshTopView()
                    saveSchedule()
                } else {
                    print("右移")
                    if topView.left + w + 40 >= Dimension.screenWidth - 40 {
                        return
                    }
                    topView.left += w
                    currentPattern.items[currentItem].time = topView.leftToTimeInt(value: topView.left)
                    refreshTopView()
                    saveSchedule()
                }
            }
        case 4:// 预览
            print("设置预览")
            if preTimer != nil { // 停止预览
                let button = buttonsView.viewWithTag(4) as! UIButton
                button.setImage(UIImage(named: "中间-三角形"), for: .normal)
                preTimer?.invalidate()
                preTimer = nil
                topView.floatView.isHidden = true
                //topView.setFloatViewDot(isShown: true)
                currentIndex = 0
                touchEnable(value: true)
                return
            }
            button.setImage(UIImage(named: "中间-返回"), for: .normal)
            PreviousFunction(count: 150) // 每200ms一次
        case 5:
            let alert = UIAlertController(title: "txt_savefavor".localized(), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                
            }
            alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert, weak self] (action) in
                guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    return
                }
                guard let self = self else { return }
                self.currentPattern.name = name
                self.patterns?.patterns.append(self.currentPattern)
                self.patterns?.save()
                button.isSelected = true
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
        topView.drawLine(deviceModel: deviceModel)
        topView.addDotButtons(currentPattern: currentPattern, current: currentItem)
    }
    
    private func saveSchedule() {
        deviceModel.pattern = currentPattern
        let state = deviceModel.deviceState
        let high = (state >> 4) & 0x0f
        //let low = state & 0x0f
        let isManual = (deviceModel.pattern?.isManual ?? false) == true
        print("当前模式是手动吗？\(isManual)")
        deviceModel.deviceState = (high << 4) + (isManual ? 8 : 4)
        deviceListModel.groups[DeviceManager.sharedInstance.currentIndex] = deviceModel
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightSchedual(model: isManual ? 2 : 1, device: deviceModel)
    }
    
    // 30秒内预览 200ms 一次
    private func PreviousFunction(count: Int) {
        touchEnable(value: false)
        preTimer?.invalidate()
        preTimer = nil
        totalIndex = count
        preTimer = Timer.scheduledTimer(timeInterval: Double(30) / Double(count), target: self, selector: #selector(handlePre), userInfo: nil, repeats: true)
        preTimer?.fire()
        topView.floatView.isHidden = false
        //topView.setFloatViewDot(isShown: false)
    }
    
    @objc private func handlePre() {
        if currentIndex > totalIndex {
            preTimer?.invalidate()
            preTimer = nil
            topView.floatView.isHidden = true
            //topView.setFloatViewDot(isShown: true)
            let button = buttonsView.viewWithTag(4) as! UIButton
            button.setImage(UIImage(named: "中间-三角形"), for: .normal)
            currentIndex = 0
            touchEnable(value: true)
            return
        }
        let duration = 24 * 60 / totalIndex
        topView.left = topView.timeToLeft(value: currentIndex * duration)
        var value = [0, 0, 0, 0, 0, 0]
        for j in 0..<value.count {
            let manager = CurrentLightValueManager()
            let v = manager.calCurrentB(deviceModel: deviceModel, currentTime: currentIndex * duration, index: j)
            value[j] = Int(v)
        }
        refreshSliderValue(currentTime: currentIndex * duration)
        TCPSocketManager.sharedInstance.lightPreview(value: value)
        currentIndex += 1
    }
    
    /// 预览时，不交互
    private func touchEnable(value: Bool) {
        bottomView.isUserInteractionEnabled = value
        segmentedControl.isUserInteractionEnabled = value
        topView.dotView.isUserInteractionEnabled = value
        topView.drawView.isUserInteractionEnabled = value
        for subView in buttonsView.subviews {
            if subView.tag == 4 {
                subView.isUserInteractionEnabled = true
            } else {
                subView.isUserInteractionEnabled = value
            }
        }
        topView.canTouch = value
        navigationItem.leftBarButtonItem?.isEnabled = value
        navigationItem.rightBarButtonItem?.isEnabled = value
        navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = value
    }
}

extension ControlViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let result = scanResult.strScanned {
            let array = QRCodeHelper().checkQR(content: result)
            if array.count > 0 {
                let alert = UIAlertController(title: "txt_preset_overwrite".localized(), message: "txt_preset_overwrite_hint".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: {[weak self] (action) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
                    let models = DeviceManager.sharedInstance.deviceListModel.groups
                    let current = DeviceManager.sharedInstance.currentIndex
                    if current < models.count {
                        models[current].pattern?.items = array
                    }
                    DeviceManager.sharedInstance.deviceListModel.groups = models
                    DeviceManager.sharedInstance.save()
                    NotificationCenter.default.post(name: Notification.Name("ControlViewController"), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                }))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        let alert = UIAlertController(title: "Unaval", message: "No data found.Continue to scan?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: {[weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
            self?.scan?.startScan()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ControlViewController: TouchBarValueViewDelegate {
    func progress(tag: Int, top: CGFloat, value: Int) {
        startDetectionTimer()
        if tag == 100 {
            for i in 1..<colors.count {
                let view = bottomView.viewWithTag(i + 100) as! TouchBarValueView
                view.setValue(value)
            }
            if topManualView.isHidden == false {
                if deviceModel.deviceType == 3 {
                    currentPattern.manual?.intensity = [value, value, value, 0, 0, 0, value]
                } else {
                    currentPattern.manual?.intensity = [value, value, value, value, value, value, value]
                }
                refreshPower()
                saveSchedule()
                return
            }
            if currentPattern.items.count > 0 {
                if deviceModel.deviceType == 3 {
                    currentPattern.items[currentItem].intensity = [value, value, value, 0, 0, 0, value]
                } else {
                    currentPattern.items[currentItem].intensity = [value, value, value, value, value, value, value]
                }
                refreshTopView()
                saveSchedule()
            }
        } else {
            if topManualView.isHidden == false {
                if tag >= 101 && tag <= 106 {
                    currentPattern.manual?.intensity[tag - 101] = value
                }
                refreshPower()
                saveSchedule()
            } else {
                if currentPattern.items.count > 0 {
                    if tag >= 101 && tag <= 106 {
                        currentPattern.items[currentItem].intensity[tag - 101] = value
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
        if currentItem < 0 {
            return
        }
        if currentItem >= currentPattern.items.count {
            return
        }
        startDetectionTimer()
        bottomView.isUserInteractionEnabled = true
        let time = Int((pointX) / (Dimension.screenWidth - 40) * 1440)
        if currentItem - 1 >= 0 {
            if currentPattern.items[currentItem - 1].time >= time {
                return
            }
        }
        if currentItem + 1 < currentPattern.items.count {
            if currentPattern.items[currentItem + 1].time <= time {
                return
            }
        }
        currentPattern.items[currentItem].time = Int((pointX) / (Dimension.screenWidth - 40) * 1440)
        refreshTopView()
        saveSchedule()
    }
    
    func touchCurrent(_ current: Int) {
        if currentPattern == nil {
            return
        }
        currentItem = current
        if currentItem >= currentPattern.items.count {
            return
        }
        startDetectionTimer()
        bottomView.isUserInteractionEnabled = true
        topView.floatView.isUserInteractionEnabled = true
        for i in 1..<colors.count {
            let view = bottomView.viewWithTag(i + 100) as! TouchBarValueView
            if i >= 1 && i <= 6 {
                view.setValue(currentPattern.items[currentItem].intensity[i - 1])
            }
        }
        topView.addDotButtons(currentPattern: currentPattern, current: currentItem)
    }
    
    func readBeforeValue() -> Int {
        if currentPattern == nil {
            return 0
        }
        if currentItem - 1 >= 0 {
            return currentPattern.items[currentItem - 1].time
        }
        return 0
    }
    
    func readAfterValue() -> Int {
        if currentPattern == nil {
            return 0
        }
        if currentItem + 1 < currentPattern.items.count {
            return currentPattern.items[currentItem + 1].time
        }
        return 0
    }
}
