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

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var addDeviceLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var timeLabelTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLConstraint: NSLayoutConstraint!
    var clockTimer: Timer!
    var currentTime = 0 // 当前时间
    var indexs: [Int] = []
    var currentIndex = 0
    var scan: LBXScanViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false 
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
        timeLabelTopLConstraint.constant = AppDelegate.isSameToIphoneX() ? 40 : 20
        bottomLConstraint.constant = AppDelegate.isSameToIphoneX() ? 40 : 0
        startClock()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
        let model = DeviceManager.sharedInstance.deviceListModel
        let current = DeviceManager.sharedInstance.currentIndex
        if model.groups.count == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            welcomeView.isHidden = false
            navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = false
            guard let items = navigationController?.tabBarController?.tabBar.items else {
                return
            }
            for item in items {
                item.isEnabled = false
            }
        } else {
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
    }
    
    // MARK: - Action
    
    @objc private func clock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr.count > 16 {
            let start = dateStr.index(dateStr.startIndex, offsetBy: 11)
            let end = dateStr.index(dateStr.startIndex, offsetBy: 16)
            let time = String(dateStr[start..<end])
            timeLabel.text = time
            let array = time.components(separatedBy: ":")
            if array.count == 2 {
                currentTime = (Int(array[0]) ?? 0) * 60 + (Int(array[1]) ?? 0)
                collectionView.reloadData()
            }
        }
    }
    
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
        scan = LBXScanViewController()
        scan.scanStyle = style
        scan.scanResultDelegate = self
        scan.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scan, animated: true)
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
            TCPSocketManager.sharedInstance.disconnect()
            TCPSocketManager.sharedInstance.connectDeivce()
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
            TCPSocketManager.sharedInstance.disconnect()
            TCPSocketManager.sharedInstance.connectDeivce()
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        indexs.removeAll()
        var tem = 0
        for device in DeviceManager.sharedInstance.deviceListModel.groups {
            if device.group == false {
                indexs.append(tem)
            } else {
                indexs.append(tem)
                if device.child > 0 {
                    tem += device.child
                }
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
        cell.refreshUI(deviceModel: device, currentTime: currentTime)
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
        let device = DeviceManager.sharedInstance.deviceListModel.groups[tag]
        let value = device.deviceState
        let cTag = btnTag
        switch cTag {
        case 0: // SCHEDUAL
            let high = (value >> 4) & 0x0f
            device.deviceState = (high << 4) + (device.pattern?.isManual == true ? 0x08 : 0x04)
            DeviceManager.sharedInstance.save()
            if let _ = device.pattern {
            TCPSocketManager.sharedInstance.lightSchedual(model: device.pattern?.isManual == true ? 2 : 1, device: device)
            }
            collectionView.reloadData()
        case 1: // ALL ON / ALL OFF
            let high = (value >> 4) & 0x0f
            let low = value & 0x0f
            device.deviceState = result > 0 ? ((high << 4) + 0b0010) : (low + ((high + 8) << 4))
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightSchedual(model: result > 0 ? 3 : 5, device: device, allOn: result > 0)
            collectionView.reloadData()
        case 2: // ACCL
            let high = (value >> 4) & 0x0f
            device.deviceState = (high << 4) + 0x01
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightSchedual(model: 4, device: device)
            collectionView.reloadData()
        case 3: // Lunnar
            let low = value & 0x0f
            let high = (value >> 4) & 0x0f
            device.deviceState = (((result > 0 ? 0x04 : 0x00) + high & 0b0011) << 4) + low
            if device.lunnar == nil {
                device.lunnar = Lunnar()
            }
            device.lunnar?.enable = result > 0
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightEffect(type: 0, result: result + 1, device: device)
            collectionView.reloadData()
        case 4: // Lighting
            let low = value & 0x0f
            let high = (value >> 4) & 0x0f
            device.deviceState = (((result > 0 ? 0x02 : 0x00) + high & 0b0101) << 4) + low
            if device.lightning == nil {
                device.lightning = Lightning()
            }
            device.lightning?.enable = result > 0
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightEffect(type: 1, result: result + 1, device: device)
            collectionView.reloadData()
        case 5: // Cloudy
            let low = value & 0x0f
            let high = (value >> 4) & 0x0f
            device.deviceState = (((result > 0 ? 0x01 : 0x00) + high & 0b0110) << 4) + low
            if device.cloudy == nil {
                device.cloudy = Cloudy()
            }
            device.cloudy?.enable = result > 0
            DeviceManager.sharedInstance.save()
            TCPSocketManager.sharedInstance.lightEffect(type: 2, result: result + 1, device: device)
            collectionView.reloadData()
        default:
            print("todo")
        }
    }
    
}

