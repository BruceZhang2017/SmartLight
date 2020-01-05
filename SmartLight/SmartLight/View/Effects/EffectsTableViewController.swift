//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/8.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class EffectsTableViewController: UITableViewController {
    
    var titles: [[String]] = []
    var scan: LBXScanViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titles = Arrays.effects
        tableView.reloadData()
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
        scan = LBXScanViewController()
        scan.scanStyle = style
        scan.scanResultDelegate = self
        scan.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scan, animated: true)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section > 0 {
            let allimationVC = FanTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
            return
        }
        if indexPath.row == 0 {
            let allimationVC = AcclimationTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else if indexPath.row == 1 {
            let allimationVC = LunnarTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else if indexPath.row == 2 {
            let allimationVC = LightningTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else  if indexPath.row == 3 {
            let allimationVC = CloudyTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "light_effect_settings".localized()
        } else {
            return "other_settings".localized()
        }
    }
    
}

extension EffectsTableViewController: LBXScanViewControllerDelegate {
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
