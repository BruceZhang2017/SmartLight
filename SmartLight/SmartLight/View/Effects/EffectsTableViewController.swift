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
    
    var titles: [String] = []
    
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
        let index = DeviceManager.sharedInstance.currentIndex
        let deviceModel = DeviceManager.sharedInstance.deviceListModel.groups[index]
        titles = deviceModel.deviceType == 3 ? Arrays.effectBs : Arrays.effects
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
        let vc = LBXScanViewController()
        vc.scanStyle = style
        vc.scanResultDelegate = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let allimationVC = AcclimationTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else if indexPath.row == 1 && titles.count > 3 {
            let allimationVC = LunnarTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else if (indexPath.row == 2 && titles.count > 3) || (indexPath.row == 1 && titles.count == 3)  {
            let allimationVC = LightningTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        } else {
            let allimationVC = CloudyTableViewController(style: .grouped)
            allimationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(allimationVC, animated: true)
        }
        
    }

}

extension EffectsTableViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}
