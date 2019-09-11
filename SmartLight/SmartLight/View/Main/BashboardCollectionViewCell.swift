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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnViewHeightLConstriant.constant = Dimension.screenWidth <= 320 || Dimension.screenHeight <= 667 ? 60 : 100
        topLConstraint.constant = AppDelegate.isSameToIphoneX() ? 138 : 78
        if Dimension.screenWidth <= 320 {
            barHeight = 220
        } else {
            barHeight = Dimension.screenWidth / 375 * 300
        }
        initBarValueViews()
        initBtnViews()
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
    
    /// 刷新Cell UI
    ///
    /// - Parameter deviceModel: 对象参数值
    func refreshUI(deviceModel: DeviceModel, currentTime: Int) {
        for (index, barValueView) in barValueViews.enumerated() {
            if deviceModel.pattern?.isManual == true {
                var value: CGFloat = 0
                if index == 0 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.uv ?? 0)) / 100 * (barHeight - 71)
                } else if index == 1 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.db ?? 0)) / 100 * (barHeight - 71)
                } else if index == 2 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.b ?? 0)) / 100 * (barHeight - 71)
                } else if index == 3 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.g ?? 0)) / 100 * (barHeight - 71)
                } else if index == 4 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.dr ?? 0)) / 100 * (barHeight - 71)
                } else if index == 5 {
                    value = CGFloat(100 - (deviceModel.pattern?.manual?.cw ?? 0)) / 100 * (barHeight - 71)
                }
                barValueView.maxValueTopLConstraint.constant = value + 20
                barValueView.currentValueTopLConstraint.constant = value + 20
            } else {
                var maxValue: CGFloat = 0
                var currentValue: CGFloat = 0
                if index == 0 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.uv < $1.uv}?.uv ?? 0)
                    currentValue = calCurrentUV(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("uv: \(currentValue)")
                } else if index == 1 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.db < $1.db}?.db ?? 0)
                    currentValue = calCurrentDB(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("db: \(currentValue)")
                } else if index == 2 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.b < $1.b}?.b ?? 0)
                    currentValue = calCurrentB(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("b: \(currentValue)")
                } else if index == 3 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.g < $1.g}?.g ?? 0)
                    currentValue = calCurrentG(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("g: \(currentValue)")
                } else if index == 4 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.dr < $1.dr}?.dr ?? 0)
                    currentValue = calCurrentDR(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("dr: \(currentValue)")
                } else if index == 5 {
                    maxValue = CGFloat(deviceModel.pattern?.items.max{$0.cw < $1.cw}?.cw ?? 0)
                    currentValue = calCurrentCW(deviceModel: deviceModel, currentTime: currentTime)
                    log.info("cw: \(currentValue)")
                }
                maxValue = CGFloat(100 - maxValue) / 100 * (barHeight - 71) + CGFloat(20)
                currentValue = CGFloat(100 - currentValue) / 100 * (barHeight - 71) + CGFloat(20)
                barValueView.maxValueTopLConstraint.constant = maxValue
                barValueView.currentValueTopLConstraint.constant = currentValue
            }
        }
    }
    
    func calCurrentUV(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.uv) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.uv)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.uv - pre.uv) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.uv)
                } else {
                    return CGFloat(item.uv) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func calCurrentDB(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.db) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.db)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.db - pre.db) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.db)
                } else {
                    return CGFloat(item.db) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func calCurrentB(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.b) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.b)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.b - pre.b) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.b)
                } else {
                    return CGFloat(item.b) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func calCurrentG(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.g) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.g)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.g - pre.g) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.g)
                } else {
                    return CGFloat(item.g) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func calCurrentDR(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.dr) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.dr)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.dr - pre.dr) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.dr)
                } else {
                    return CGFloat(item.dr) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func calCurrentCW(deviceModel: DeviceModel, currentTime: Int) -> CGFloat {
        guard let pattern = deviceModel.pattern else {
            return 0
        }
        for (index, item) in pattern.items.enumerated() {
            if index == pattern.items.count - 1 {
                return CGFloat(0 - item.cw) * CGFloat(currentTime - item.time) / CGFloat(1440 - item.time) + CGFloat(item.cw)
            }
            if item.time > currentTime {
                if index > 0 {
                    let pre = pattern.items[index - 1]
                    return CGFloat(item.cw - pre.cw) * CGFloat(currentTime - pre.time) / CGFloat(item.time - pre.time) + CGFloat(pre.cw)
                } else {
                    return CGFloat(item.cw) * CGFloat(currentTime) / CGFloat(item.time)
                }
            }
        }
        return 0
    }
    
    func refreshButton(deviceModel: DeviceModel) {
        let value = deviceModel.deviceState
        let low = value & 0x0f
        let high = value & 0xf0
        buttons[0].isSelected = low == 4
        buttons[1].isSelected = low == 2
        buttons[2].isSelected = low == 1
        buttons[3].isSelected = high == 4
        buttons[4].isSelected = high == 2
        buttons[5].isSelected = high == 1
    }
}
