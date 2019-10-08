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
    @IBOutlet weak var topLConstraint: NSLayoutConstraint!
    var barHeight: CGFloat = 0
    weak var delegate: BashboardCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnViewHeightLConstriant.constant = Dimension.screenWidth <= 320 || Dimension.screenHeight <= 667 ? 60 : 100
        topLConstraint.constant = AppDelegate.isSameToIphoneX() ? 138 : 78
        if Dimension.screenWidth <= 320 {
            barHeight = 220
        } else {
            barHeight = Dimension.screenWidth / 375 * 300
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initBarValueViews(deviceModel: DeviceModel) {
        barValueViews.removeAll()
        for subView in barView.subviews {
            subView.removeFromSuperview()
        }
        var colors: [UIColor] = []
        if deviceModel.deviceType == 3 {
            colors = [Color.bar6, Color.bar2, Color.bar5]
        } else {
            colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6]
        }
        
        for i in 0..<colors.count {
            guard let barValueView = Bundle.main.loadNibNamed(.kBarValueView, owner: nil, options: nil)?.first as? BarValueView else {
                return
            }
            barValueView.do {
                $0.titleLabel.text = colors.count == 3 ? Arrays.barTitleBs[i] : Arrays.barTitles[i]
                $0.valueLabel.text = "0%"
                $0.currentValueImageView.backgroundColor = colors[i]
                $0.settingValueImageView.backgroundColor = colors[i]
                $0.totalValueImageview.backgroundColor = Color.barBG
                $0.maxValueTopLConstraint.constant = barHeight - 51
                $0.currentValueTopLConstraint.constant = barHeight - 51
            }
            let width = (Dimension.screenWidth - 80) / CGFloat(colors.count)
            let x = 20 + width * CGFloat(i)
            barValueViews.append(barValueView)
            barView.addSubview(barValueView)
            barValueView.snp.makeConstraints {
                $0.left.equalTo(x)
                $0.width.equalTo(width)
                $0.top.bottom.equalToSuperview()
                $0.height.equalTo(barHeight)
            }
        }
    }
    
    func initBtnViews(deviceModel: DeviceModel) {
        buttons.removeAll()
        for subView in btnView.subviews {
            subView.removeFromSuperview()
        }
        var imageNormals: [UIImage?] = []
        var imagePresseds: [UIImage?] = []
        if deviceModel.deviceType == 3 {
            imageNormals = [UIImage.schedule_nomal, UIImage.alloff_nomal, UIImage.aclm_nomal, UIImage.lightning_nomal, UIImage.cloudy_nomal]
            imagePresseds = [UIImage.schedule_pressed, UIImage.alloff_pressed, UIImage.aclm_pressed, UIImage.lightning_pressed, UIImage.cloudy_pressed]
        } else {
            imageNormals = [UIImage.schedule_nomal, UIImage.alloff_nomal, UIImage.aclm_nomal, UIImage.lunnar_nomal, UIImage.lightning_nomal, UIImage.cloudy_nomal]
            imagePresseds = [UIImage.schedule_pressed, UIImage.alloff_pressed, UIImage.aclm_pressed, UIImage.lunnar_pressed, UIImage.lightning_pressed, UIImage.cloudy_pressed]
        }
        let width = Dimension.screenWidth <= 320 ? 40 : 50
        let count = deviceModel.deviceType == 3 ? Arrays.btnTitleBs.count : Arrays.btnTitles.count
        for i in 0..<count {
            let button = UIButton(type: .custom).then {
                $0.setBackgroundImage(imageNormals[i], for: .normal)
                $0.setBackgroundImage(imagePresseds[i], for: .selected)
                let value = deviceModel.deviceState
                let low = value & 0b00001000
                $0.setTitle(deviceModel.deviceType == 3 ? Arrays.btnTitleBs[i] : Arrays.btnTitles[i], for: .normal)
                if i == 1 && low == 8 {
                    $0.setTitle("ALL OFF", for: .normal)
                }
                $0.setTitleColor(Color.barBG, for: .normal)
                $0.setTitleColor(Color.main, for: .selected)
                $0.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: Dimension.screenWidth <= 320 ? 6 : 8)
                $0.addTarget(self, action: #selector(handleButtonTapEvent(_:)), for: .touchUpInside)
                $0.tag = i
            }
            btnView.addSubview(button)
            buttons.append(button)
            let space = (Dimension.screenWidth - 40 - CGFloat(width * count)) / CGFloat(count + 1)
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
                        delegate?.handleMiddleButtonTap(btnTag: tag, tag: self.tag, result: 0)
                    } else {
                        buttons[tag].setTitle("All ON", for: .normal)
                        delegate?.handleMiddleButtonTap(btnTag: tag, tag: self.tag, result: 1)
                        
                    }
                }
                return
            } else {
                if tag == 1 {
                    if button.title(for: .normal) == "All ON" {
                        delegate?.handleMiddleButtonTap(btnTag: tag, tag: self.tag, result: 1)
                    } else {
                        delegate?.handleMiddleButtonTap(btnTag: tag, tag: self.tag, result: 0)
                    }
                }
            }
        }
        delegate?.handleMiddleButtonTap(btnTag: tag, tag: self.tag, result: button.isSelected ? 0 : 1)
    }
    
    /// 刷新Cell UI
    ///
    /// - Parameter deviceModel: 对象参数值
    func refreshUI(deviceModel: DeviceModel, currentTime: Int) {
        for (index, barValueView) in barValueViews.enumerated() {
            if deviceModel.pattern?.isManual == true {
                var value: CGFloat = 0
                value = CGFloat(100 - (deviceModel.pattern?.manual?.intensity[index] ?? 0)) / 100 * (barHeight - 71)
                barValueView.maxValueTopLConstraint.constant = value + 20
                barValueView.currentValueTopLConstraint.constant = value + 20
            } else {
                var maxValue: CGFloat = 0
                var currentValue: CGFloat = 0
                maxValue = CGFloat(deviceModel.pattern?.items.max{$0.intensity[index] < $1.intensity[index]}?.intensity[index] ?? 0)
                currentValue = calCurrent(deviceModel: deviceModel, currentTime: currentTime, index: index)
                maxValue = CGFloat(100 - maxValue) / 100 * (barHeight - 71) + CGFloat(20)
                currentValue = CGFloat(100 - currentValue) / 100 * (barHeight - 71) + CGFloat(20)
                barValueView.maxValueTopLConstraint.constant = maxValue
                barValueView.currentValueTopLConstraint.constant = currentValue
            }
        }
    }
    
    func calCurrent(deviceModel: DeviceModel, currentTime: Int, index: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 && item.time <= currentTime {
                return CGFloat(item.intensity[index]) * CGFloat(1440 - currentTime) / CGFloat(1440 - item.time)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.intensity[index] - pre.intensity[index]) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.intensity[index])
                } else {
                    return CGFloat(item.intensity[index]) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func refreshButton(deviceModel: DeviceModel) {
        let value = deviceModel.deviceState
        let low = value & 0x0f
        let high = (value >> 4) & 0x0f
        if deviceModel.deviceType == 3 {
            
        } else {
            buttons[0].isSelected = low == 4
            buttons[1].isSelected = (low == 2 || low == 10)
            buttons[2].isSelected = low == 1
            buttons[3].isSelected = (high & 0b0100) > 0
            buttons[4].isSelected = (high & 0b0010) > 0
            buttons[5].isSelected = (high & 0b0001) > 0
        }
    }
}

protocol BashboardCollectionViewCellDelegate: NSObjectProtocol {
    func handleMiddleButtonTap(btnTag: Int, tag: Int, result: Int)
}
