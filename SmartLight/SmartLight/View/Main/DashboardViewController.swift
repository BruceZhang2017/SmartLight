//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  ViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/3.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import EFQRCode
import Localize_Swift
import Toaster

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var addDeviceLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var devicesLabel: UILabel!
    @IBOutlet weak var timeLabelTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLConstraint: NSLayoutConstraint!
    var clockTimer: Timer!
    private var currentTime = 0 // 当前时间
    private var currentTimeSecond = 0 // 当前时间秒
    var indexs: [Int] = []
    var currentIndex = 0 // 当前的坐标
    var scan: LBXScanViewController!
    private var reach: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false 
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
        timeLabelTopLConstraint.constant = AppDelegate.isSameToIphoneX() ? 40 : (Dimension.screenWidth > 375 ? 30 : 20)
        bottomLConstraint.constant = AppDelegate.isSameToIphoneX() ? 40 : (Dimension.screenWidth > 375 ? 40 : 10)
        startClock()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        monitorNetwork()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoti(notification:)), name: Notification.Name("DashboardViewController"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleScroll(notification:)), name: Notification.Name("Dashboard"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "txt_dashboard".localized()
        self.navigationController?.navigationBar.barTintColor = Color.main
        let model = DeviceManager.sharedInstance.deviceListModel
        let current = DeviceManager.sharedInstance.currentIndex
        if model.groups.count == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            welcomeView.isHidden = false
        } else {
            if current >= model.groups.count {
                return
            }
            deviceNameLabel.text = model.groups[current].name
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            welcomeView.isHidden = true
            navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = true
            guard let items = navigationController?.tabBarController?.tabBar.items else {
                return
            }
            for item in items {
                item.isEnabled = true
            }
            collectionView.reloadData()
            TCPSocketManager.sharedInstance.connectDeivce()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reach?.stopNotifier()
        reach = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Private
    
    private func setLeftNavigationItem() {
        let leftItem = UIBarButtonItem(image: UIImage.top_menu, style: .plain, target: self, action: #selector(pushToMenu))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setRightNavigationItem() {
        let rightItem = UIBarButtonItem(image: UIImage.top_qrcode, style: .plain, target: self, action: #selector(pushToQRCode))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    private func setTitleView() {
        navigationItem.titleView = UIImageView(image: UIImage.top_logo)
    }
    
    private func startClock() {
        clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(clock), userInfo: nil, repeats: true)
        clockTimer.fire()
        RunLoop.current.add(clockTimer, forMode: .common)
    }
    
    override func setText() {
        welcomeLabel.text = "txt_welcome".localized()
        addDeviceLabel.text = "txt_adddevice".localized()
        devicesLabel.text = "txt_devices".localized()
    }
    
    /// 监听一下当前网络情况
    private func monitorNetwork() {
        reach = Reachability(hostname: "www.baidu.com")
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: Notification.Name.reachabilityChanged, object: nil)
        try? reach?.startNotifier()
    }
    
    @objc func handleNotification(notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            return
        }
        print("当前网络状体：\(reachability.connection.description)")
        if reachability.connection == Reachability.Connection.wifi {
            let name = ESPTools.getCurrentWiFiSsid() ?? ""
            if name != "SmartLEDLight" {
                DeviceManager.sharedInstance.clearDirectConnection() // 清空直连设备
            }
            if wifiName != "" && wifiName != name {
                TCPSocketManager.sharedInstance.connectDeivce()
            } else if wifiName == "" {
                TCPSocketManager.sharedInstance.connectDeivce()
            }
            wifiName = name
        } else if reachability.connection == Reachability.Connection.none {
            let name = ESPTools.getCurrentWiFiSsid() ?? ""
            if name != "" {
                if wifiName != "" && wifiName != name {
                    TCPSocketManager.sharedInstance.connectDeivce()
                } else if wifiName == "" {
                    TCPSocketManager.sharedInstance.connectDeivce()
                }
            } else {
                wifiName = ""
            }
        } else {
            wifiName = "none"
        }
    }
    
    // MARK: - Action
    
    @objc private func clock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr.count > 16 {
            let start = dateStr.index(dateStr.startIndex, offsetBy: 11)
            let end = dateStr.endIndex
            let time = String(dateStr[start..<end])
            let array = time.components(separatedBy: ":")
            if array.count >= 2 {
                let hour = Int(array[0]) ?? 0
                let minute = Int(array[1]) ?? 0
                let second = Int(array[2]) ?? 0
                if Kit().getDeviceTimeSystemIs12() && hour > 12 {
                    let h = hour - 12 > 9 ? "\((hour - 12))" : "0\(hour - 12)"
                    let m = minute > 9 ? "\(minute)" : "0\(minute)"
                    timeLabel.text = "\(h):\(m)"
                } else {
                    let h = hour > 9 ? "\(hour)" : "0\(hour)"
                    let m = minute > 9 ? "\(minute)" : "0\(minute)"
                    timeLabel.text = "\(h):\(m)"
                }
                currentTime = hour * 60 + minute
                currentTimeSecond = currentTime * 60 + second
                collectionView.reloadData()
                NotificationCenter.default.post(name: Notification.Name("ControlViewController"), object: currentTime)
            }
        }
    }
    
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
    
    @objc private func handleReconnect() {
        UIApplication.shared.keyWindow?.hideHUD()
        TCPSocketManager.sharedInstance.connectDeivce()
    }

    @IBAction func addDevice(_ sender: Any) {
        if !MCLocation.shared.didUpdateLocation(self) {
            return
        }
        let storyboard = UIStoryboard(name: "Device", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceSearch) as! SearchDeviceViewController
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func prevous(_ sender: Any) {
        let model = DeviceManager.sharedInstance.deviceListModel
        if currentIndex > 0 {
            currentIndex -= 1
            DeviceManager.sharedInstance.currentIndex = indexs[currentIndex]
            collectionView.scrollToItem(
                at: IndexPath(item: currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: true)
            deviceNameLabel.text = model.groups[DeviceManager.sharedInstance.currentIndex].name
            TCPSocketManager.sharedInstance.disconnectAll()
            UIApplication.shared.keyWindow?.showHUD("switching_devcie".localized())
            perform(#selector(handleReconnect), with: nil, afterDelay: 3)
        }
    }
    
    @IBAction func next(_ sender: Any) {
        let model = DeviceManager.sharedInstance.deviceListModel
        let count = indexs.count
        if currentIndex < count - 1 {
            currentIndex += 1
            DeviceManager.sharedInstance.currentIndex = indexs[currentIndex]
            let current = DeviceManager.sharedInstance.currentIndex
            collectionView.scrollToItem(
                at: IndexPath(item: currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: true)
            deviceNameLabel.text = model.groups[current].name
            TCPSocketManager.sharedInstance.disconnectAll()
            UIApplication.shared.keyWindow?.showHUD("switching_devcie".localized())
            perform(#selector(handleReconnect), with: nil, afterDelay: 3)
        }
    }
    
    @objc private func handleNoti(notification: Notification) {
        if let value = notification.object as? Int, value > 0 {
            collectionView.reloadData()
            return
        }
        print("删除设备")
        currentIndex = 0
        DeviceManager.sharedInstance.currentIndex = 0
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @objc private func handleScroll(notification: Notification) {
        let index = notification.object as? Int ?? 0
        if index == DeviceManager.sharedInstance.currentIndex {
            return
        }
        if index >= DeviceManager.sharedInstance.deviceListModel.groups.count {
            return
        }
        let model = DeviceManager.sharedInstance.deviceListModel.groups[index]
        if model.superModel < 0 {
            for (k, i) in indexs.enumerated() {
                if i == index {
                    currentIndex = k
                    scrollToSpecialDevice()
                    return
                }
            }
        }
        if model.superModel > 0 {
            for (i, m) in DeviceManager.sharedInstance.deviceListModel.groups.enumerated() {
                if m.group && m.superModel == model.superModel {
                    for (k, j) in indexs.enumerated() {
                        if j == i {
                            currentIndex = k
                            scrollToSpecialDevice()
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func scrollToSpecialDevice() {
        DeviceManager.sharedInstance.currentIndex = indexs[currentIndex]
        let current = DeviceManager.sharedInstance.currentIndex
        collectionView.scrollToItem(
            at: IndexPath(item: currentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true)
        let model = DeviceManager.sharedInstance.deviceListModel
        deviceNameLabel.text = model.groups[current].name
        TCPSocketManager.sharedInstance.disconnectAll()
        perform(#selector(handleReconnect), with: nil, afterDelay: 3)
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexs.removeAll()
        var tem = 0
        for device in DeviceManager.sharedInstance.deviceListModel.groups {
            if device.group == false {
                if device.superModel == -1 {
                    indexs.append(tem)
                }
            } else {
                indexs.append(tem)
            }
            tem += 1
        }
        return indexs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCellIdentifier, for: indexPath) as! BashboardCollectionViewCell
        let device = DeviceManager.sharedInstance.deviceListModel.groups[indexs[indexPath.row]]
        cell.initBarValueViews(deviceModel: device)
        cell.initBtnViews(deviceModel: device)
        cell.refreshUI(deviceModel: device, currentTime: currentTimeSecond)
        cell.refreshButton(deviceModel: device)
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Dimension.screenWidth, height: AppDelegate.isSameToIphoneX() ? (Dimension.screenHeight - 88 - 83) : (Dimension.screenHeight - 64 - 49))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension DashboardViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let result = scanResult.strScanned {
            let array = QRCodeHelper().checkQR(content: result)
            if array.count > 0 {
                let alert = UIAlertController(title: "Overwrite Current Settins", message: "Selecting a QR Code Data will overwrite your current settings. Continue?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (action) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {[weak self] (action) in
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {[weak self] (action) in
            self?.scan?.startScan()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension DashboardViewController: BashboardCollectionViewCellDelegate {
    func handleMiddleButtonTap(btnTag: Int, tag: Int, result: Int) {
        let device = DeviceManager.sharedInstance.deviceListModel.groups[indexs[tag]]
        let value = device.deviceState
        let cTag = btnTag
        switch cTag { // 特殊处理：在全开/全关情况下，新月/闪电/多云不让点击
        case 2: // SCHEDUAL
            if result == 0 {
                return
            }
            let high = (value >> 4) & 0x0f
            device.deviceState = ((high >= 8 ? (high - 8) : high) << 4) + (result == 2 ? 0x08 : 0x04)
            DeviceManager.sharedInstance.save()
            if device.pattern == nil {
                device.pattern = PatternModel()
            }
            TCPSocketManager.sharedInstance.lightSchedual(model: result, device: device)
            collectionView.reloadData()
        case 0: // ALL ON / ALL OFF
            let high = (value >> 4) & 0x0f
            if result > 0 {
                device.deviceState = ((high >= 8 ? (high - 8) : high) << 4) + 2
            } else {
                device.deviceState = 0 + ((high >= 8 ? high : (high + 8)) << 4)
            }
            
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightSchedual(model: result > 0 ? 3 : 5, device: device, allOn: result > 0)
            collectionView.reloadData()
            perform(#selector(self.closeLunnar), with: nil, afterDelay: 0.05)
        case 1: // ACCL
            device.deviceState = 0x01
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightSchedual(model: 4, device: device)
            collectionView.reloadData()
        case 3: // Lunnar
            if CheckDeviceState().checkCurrentDeviceStateIsAllOnOrAllOff() {
                return
            }
            setLunnar(value: value, result: result, device: device)
        case 4: // Lighting
            if CheckDeviceState().checkCurrentDeviceStateIsAllOnOrAllOff() {
                return
            }
            setLighting(value: value, result: result, device: device)
        case 5: // Cloudy
            if CheckDeviceState().checkCurrentDeviceStateIsAllOnOrAllOff() {
                return
            }
            setCloud(value: value, result: result, device: device)
        default:
            print("todo")
        }
    }
    
    @objc private func closeLunnar() {
        let current = DeviceManager.sharedInstance.currentIndex
        if current >= DeviceManager.sharedInstance.deviceListModel.groups.count {
            return
        }
        let device = DeviceManager.sharedInstance.deviceListModel.groups[current]
        let lunar = (device.deviceState >> 6) & 0x01
        if lunar > 0 {
            setLunnar(value: device.deviceState, result: 0, device: device)
            perform(#selector(self.closeLighting), with: nil, afterDelay: 0.05)
        } else {
            closeLighting()
        }
        
    }
    
    private func setLunnar(value: Int, result: Int, device: DeviceModel) {
        let low = value & 0x0f
        let high = (value >> 4) & 0x0f
        device.deviceState = (((result > 0 ? 0x04 : 0x00) + high & 0b0011) << 4) + low
        if device.lunnar == nil {
            device.lunnar = Lunnar()
        }
        
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightEffect(type: 0, result: result + 1, device: device)
        collectionView.reloadData()
    }
    
    @objc private func closeLighting() {
        let current = DeviceManager.sharedInstance.currentIndex
        if current >= DeviceManager.sharedInstance.deviceListModel.groups.count {
            return
        }
        let device = DeviceManager.sharedInstance.deviceListModel.groups[current]
        let lighting = (device.deviceState >> 5) & 0x01
        if lighting > 0 {
            setLighting(value: device.deviceState, result: 0, device: device)
            perform(#selector(self.closeCloud), with: nil, afterDelay: 0.05)
        } else {
            closeCloud()
        }
    }
    
    private func setLighting(value: Int, result: Int, device: DeviceModel) {
        let low = value & 0x0f
        let high = (value >> 4) & 0x0f
        device.deviceState = (((result > 0 ? 0x02 : 0x00) + high & 0b0101) << 4) + low
        if device.lightning == nil {
            device.lightning = Lightning()
        }
        
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightEffect(type: 1, result: result + 1, device: device)
        collectionView.reloadData()
    }
    
    @objc private func closeCloud() {
        let current = DeviceManager.sharedInstance.currentIndex
        if current >= DeviceManager.sharedInstance.deviceListModel.groups.count {
            return
        }
        let device = DeviceManager.sharedInstance.deviceListModel.groups[current]
        let cloud = (device.deviceState >> 4) & 0x01
        if cloud > 0 {
            setCloud(value: device.deviceState, result: 0, device: device)
        }
    }
    
    private func setCloud(value: Int, result: Int, device: DeviceModel) {
        let low = value & 0x0f
        let high = (value >> 4) & 0x0f
        device.deviceState = (((result > 0 ? 0x01 : 0x00) + high & 0b0110) << 4) + low
        if device.cloudy == nil {
            device.cloudy = Cloudy()
        }
        
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightEffect(type: 2, result: result + 1, device: device)
        collectionView.reloadData()
    }
}

