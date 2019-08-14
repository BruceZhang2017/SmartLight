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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        setRightNavigationItem()
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.tintColor = UIColor.white
        initBarValueViews()
        initLabelValueViews()
        initbttonValueViews()
        initLineView()
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
            let button = UIButton(type: .custom)
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
    
    private func initLineView() {
        let lineImageView = UIImageView().then {
            $0.backgroundColor = Color.line
        }
        topView.addSubview(lineImageView)
        lineImageView.snp.makeConstraints {
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(1)
            $0.top.equalTo(50)
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
        
    }
}

extension ControlViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
    }
}
