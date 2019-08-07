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

class DashboardViewController: BaseViewController {
    
    var barValueViews: [BarValueView] = []
    var buttons: [UIButton] = []
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        setRightNavigationItem()
        setTitleView()
        initBarValueViews()
        initBtnViews()
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
    
    private func initBarValueViews() {
        let colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        
        for i in 0..<colors.count {
            guard let barValueView = Bundle.main.loadNibNamed(.kBarValueView, owner: nil, options: nil)?.first as? BarValueView else {
                return
            }
            barValueView.do {
                $0.titleLabel.text = Arrays.barTitles[i]
                $0.valueLabel.text = "0%"
                $0.currentValueImageView.backgroundColor = colors[i]
                $0.settingValueImageView.backgroundColor = colors[i]
                $0.totalValueImageview.backgroundColor = Color.barBG
            }
            let width = (Dimension.screenWidth - 80) / 6
            let x = 20 + width * CGFloat(i)
            barValueViews.append(barValueView)
            barView.addSubview(barValueView)
            barValueView.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.equalTo(width)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func initBtnViews() {
        let imageNormals = [UIImage.schedule_nomal, UIImage.alloff_nomal, UIImage.aclm_nomal, UIImage.lunnar_nomal, UIImage.lightning_nomal, UIImage.cloudy_nomal]
        let imagePresseds = [UIImage.schedule_pressed, UIImage.alloff_pressed, UIImage.aclm_pressed, UIImage.lunnar_pressed, UIImage.lightning_pressed, UIImage.cloudy_pressed]
        for i in 0..<Arrays.btnTitles.count {
            let button = UIButton(type: .custom).then {
                $0.setBackgroundImage(imageNormals[i], for: .normal)
                $0.setBackgroundImage(imagePresseds[i], for: .selected)
                $0.setTitle(Arrays.btnTitles[i], for: .normal)
                $0.setTitleColor(Color.barBG, for: .normal)
                $0.setTitleColor(Color.main, for: .selected)
                $0.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            }
            btnView.addSubview(button)
            let space = (Dimension.screenWidth - 40 - 360) / 7
            button.snp.makeConstraints {
                $0.left.equalTo(space * CGFloat(i + 1) + CGFloat(60 * i))
                $0.width.height.equalTo(60)
                $0.centerY.equalToSuperview()
            }
            if i > 2 {
                button.isSelected = true
            }
        }
    }
    
    // MARK: - Action
    
    @objc private func pushToMenu() {
        
    }
    
    @objc private func pushToQRCode() {
        
    }

}

