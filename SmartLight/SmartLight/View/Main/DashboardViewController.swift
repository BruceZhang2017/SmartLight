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

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var timeLabelTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLConstraint: NSLayoutConstraint!
    var clockTimer: Timer!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
        let model = DeviceListModel.down()
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
        }
        let _ = TCPSocketManager.sharedInstance
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
    
    // MARK: - Action
    
    @objc private func clock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr.count > 16 {
            let start = dateStr.index(dateStr.startIndex, offsetBy: 11)
            let end = dateStr.index(dateStr.startIndex, offsetBy: 16)
            timeLabel.text = String(dateStr[start..<end])
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
        let vc = LBXScanViewController()
        vc.scanStyle = style
        vc.scanResultDelegate = self
        vc.hidesBottomBarWhenPushed = true 
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func addDevice(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Device", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDDeviceSearch) as! SearchDeviceViewController
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func prevous(_ sender: Any) {
        let model = DeviceListModel.down()
        if DeviceManager.sharedInstance.currentIndex > 0 {
            DeviceManager.sharedInstance.currentIndex -= 1
            let current = DeviceManager.sharedInstance.currentIndex
            collectionView.scrollToItem(
                at: IndexPath(item: current, section: 0),
                at: .centeredHorizontally,
                animated: true)
            deviceNameLabel.text = model.groups[current].name
        }
    }
    
    @IBAction func next(_ sender: Any) {
        let model = DeviceListModel.down()
        let count = model.groups.count
        if DeviceManager.sharedInstance.currentIndex < count {
            DeviceManager.sharedInstance.currentIndex += 1
            let current = DeviceManager.sharedInstance.currentIndex
            collectionView.scrollToItem(
                at: IndexPath(item: current, section: 0),
                at: .centeredHorizontally,
                animated: true)
            deviceNameLabel.text = model.groups[current].name
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DeviceListModel.down().groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCellIdentifier, for: indexPath) as! BashboardCollectionViewCell
        let device = DeviceListModel.down().groups[indexPath.row]
        
        return cell
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Dimension.screenWidth, height: AppDelegate.isSameToIphoneX() ? (Dimension.screenHeight - 88 - 49) : (Dimension.screenHeight - 64 - 44))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DashboardViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}

