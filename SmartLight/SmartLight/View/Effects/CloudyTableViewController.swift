//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsSettingTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/8.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class CloudyTableViewController: EffectsSettingTableViewController {
    
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var cloudy: Cloudy!
    var preTimer: Timer?
    var currentIndex = 0
    var totalIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        cloudy = deviceModel.cloudy ?? Cloudy()
        tableView.register(TableViewHeadView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HEAD")
    }
    
    private func handleLightEffect() {
        TCPSocketManager.sharedInstance.lightEffect(type: 2, result: (deviceModel.deviceState & 0b00010000) > 0 ? 2 : 1, device: deviceModel)
    }
    
    // 10秒内预览 1s 一次
    private func PreviousFunction(count: Int) {
        preTimer?.invalidate()
        preTimer = nil
        totalIndex = count
        preTimer = Timer.scheduledTimer(timeInterval: Double(10) / Double(count), target: self, selector: #selector(handlePre), userInfo: nil, repeats: true)
        preTimer?.fire()
        showHUD()
    }
    
    @objc private func handlePre() {
        if currentIndex > totalIndex {
            preTimer?.invalidate()
            preTimer = nil
            hideHUD()
            currentIndex = 0
            handleLightEffect() // 发送真实的SCHEDULE
            return
        }
        let s2e = cloudy.endTime - cloudy.startTime
        let duration = s2e / totalIndex
        var value = [0, 0, 0, 0, 0, 0]
        let time = cloudy.startTime + currentIndex * duration
        for j in 0..<value.count {
            if j == 1 {
                if time < (cloudy.endTime + cloudy.startTime) / 2 {
                    value[j] = cloudy.intensity * (time - cloudy.startTime) / (s2e / 2)
                } else {
                    value[j] = cloudy.intensity * (cloudy.endTime - time) / (s2e / 2)
                }
            } else {
                let manager = CurrentLightValueManager()
                value[j] = Int(manager.calCurrent(deviceModel: deviceModel, currentTime: time, index: j))
            }
        }
        TCPSocketManager.sharedInstance.lightPreview(value: value, tag: 1)
        currentIndex += 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! EffectsSettingTableViewCell
            cell.delegate = self 
            if indexPath.row == 0 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
                cell.mSwitch.isOn = (deviceModel.deviceState & 0b00010000) > 0
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Enable"
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Start Date"
                cell.desLabel.text = cloudy.startTime.timeIntToStr()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "End Date"
                cell.desLabel.text = cloudy.endTime.timeIntToStr()
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        cell.delegate = self
        cell.tag = indexPath.section
        if indexPath.section == 1 {
            cell.mSlider.value = Float(cloudy.intensity) / Float(100)
        } else {
            cell.mSlider.value = Float(cloudy.speed) / Float(100)
            cell.mSlider.minimumValueImage = UIImage(named: "乌龟")
            cell.mSlider.maximumValueImage = UIImage(named: "兔子")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HEAD") as! TableViewHeadView
        if section == 0 {
            headView.titleLabel.text = " "
            headView.contentLabel.text = ""
        } else if section == 1 {
            headView.titleLabel.text = "Intensity".uppercased()
            headView.contentLabel.text = "\(cloudy.intensity)%"
        }else {
            headView.titleLabel.text = "Speed".uppercased()
            headView.contentLabel.text = "\(cloudy.speed)%"
        }
        return headView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDTimePicker) as! TimePickerViewController
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.delegate = self
                viewController.start = true
                present(viewController, animated: false, completion: nil)
            } else if indexPath.row == 2 {
                let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDTimePicker) as! TimePickerViewController
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.delegate = self
                viewController.start = false
                present(viewController, animated: false, completion: nil)
            }
        }
    }
}

extension CloudyTableViewController: TimePickerViewControllerDelegate {
    func timePickerView(value: String, start: Bool) {
        let time = value.timeStrToInt()
        if start {
            cloudy.startTime = time
        } else {
            cloudy.endTime = time
        }
        tableView.reloadData()
        deviceModel.cloudy = cloudy
        DeviceManager.sharedInstance.save()
        handleLightEffect()
    }
}

extension CloudyTableViewController: EffectsSettingBTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        if tag == 1 {
            cloudy.intensity = value
        } else {
            cloudy.speed = value
        }
        tableView.reloadData()
        deviceModel.cloudy = cloudy
        DeviceManager.sharedInstance.save()
        handleLightEffect()
    }
}

extension CloudyTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool, tag: Int) {
        if cloudy.startTime <= 0 ||
            cloudy.endTime <= 0 {
            tableView.reloadData()
            return
        }
   
        tableView.reloadData()
        deviceModel.cloudy = cloudy
        let state = deviceModel.deviceState
        let low = state & 0x0f
        let high = (state >> 4) & 0x0f
        deviceModel.deviceState = (((value ? 0x01 : 0x00) + high & 0b1110) << 4) + low
        DeviceManager.sharedInstance.save()
        if value {
            PreviousFunction(count: 50) // 先预览200ms一次
        } else {
            handleLightEffect()
        }
    }
}
