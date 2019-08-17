//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  BashboardCollectionViewCell.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/9.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class BashboardCollectionViewCell: UICollectionViewCell {
    
    var barValueViews: [BarValueView] = []
    var buttons: [UIButton] = []
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var btnViewHeightLConstriant: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initBarValueViews()
        initBtnViews()
        btnViewHeightLConstriant.constant = Dimension.screenWidth <= 320 ? 60 : 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            let width = (Dimension.screenWidth - 80) / CGFloat(colors.count)
            let x = 20 + width * CGFloat(i)
            barValueViews.append(barValueView)
            barView.addSubview(barValueView)
            barValueView.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.equalTo(width)
                $0.top.bottom.equalToSuperview()
                if Dimension.screenWidth <= 320 {
                    $0.height.equalTo(220)
                } else {
                    $0.height.equalTo(Dimension.screenWidth / 375 * 300)
                }
            }
        }
    }
    
    private func initBtnViews() {
        let imageNormals = [UIImage.schedule_nomal, UIImage.alloff_nomal, UIImage.aclm_nomal, UIImage.lunnar_nomal, UIImage.lightning_nomal, UIImage.cloudy_nomal]
        let imagePresseds = [UIImage.schedule_pressed, UIImage.alloff_pressed, UIImage.aclm_pressed, UIImage.lunnar_pressed, UIImage.lightning_pressed, UIImage.cloudy_pressed]
        let width = Dimension.screenWidth <= 320 ? 40 : 50
        for i in 0..<Arrays.btnTitles.count {
            let button = UIButton(type: .custom).then {
                $0.setBackgroundImage(imageNormals[i], for: .normal)
                $0.setBackgroundImage(imagePresseds[i], for: .selected)
                $0.setTitle(Arrays.btnTitles[i], for: .normal)
                $0.setTitleColor(Color.barBG, for: .normal)
                $0.setTitleColor(Color.main, for: .selected)
                $0.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: Dimension.screenWidth <= 320 ? 6 : 8)
                $0.addTarget(self, action: #selector(handleButtonTapEvent(_:)), for: .touchUpInside)
                $0.tag = i
            }
            btnView.addSubview(button)
            buttons.append(button)
            let space = (Dimension.screenWidth - 40 - CGFloat(width * Arrays.btnTitles.count)) / 7
            button.snp.makeConstraints {
                $0.left.equalTo(space * CGFloat(i + 1) + CGFloat(width * i))
                $0.width.height.equalTo(width)
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    @objc private func handleButtonTapEvent(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let tag = button.tag
        if tag < 3 {
            if buttons[tag].isSelected {
                if tag == 1 {
                    if button.title(for: .normal) == "All ON" {
                        buttons[tag].setTitle("All OFF", for: .normal) // All ON / All OFF
                    } else {
                        buttons[tag].setTitle("All ON", for: .normal)
                    }
                }
                return
            }
            for i in 0..<3 {
                if i == tag {
                    buttons[i].isSelected = true
                } else {
                    buttons[i].isSelected = false
                }
            }
            return
        }
        button.isSelected = !button.isSelected
    }
}
