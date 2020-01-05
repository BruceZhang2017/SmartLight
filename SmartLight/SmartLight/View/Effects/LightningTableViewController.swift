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

class LightningTableViewController: EffectsSettingTableViewController {
    
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var ligtning: Lightning!
    var preTimer: Timer?
    var currentIndex = 0
    var totalIndex = 0
    var tag = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        ligtning = deviceModel.lightning ?? Lightning()
        tableView.register(TableViewHeadView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HEAD")
    }
    
    private func handleLightning() {
        TCPSocketManager.sharedInstance.lightEffect(type: 1, result: ligtning.enable ? 2 : 1, device: deviceModel)
    }
    
    // 10秒内预览 1s 一次
    private func PreviousFunction(count: Int) {
        preTimer?.invalidate()
        preTimer = nil
        totalIndex = count
        preTimer = Timer.scheduledTimer(timeInterval: Double(10) / Double(count), target: self, selector: #selector(handlePre), userInfo: nil, repeats: true)
        showHUD()
    }
    
    @objc private func handlePre() {
        if currentIndex > totalIndex {
            preTimer?.invalidate()
            preTimer = nil
            hideHUD()
            handleLightning() // 发送真实的SCHEDULE
            return
        }
        let duration = (ligtning.endTime - ligtning.startTime) / totalIndex
        var value = [0, 0, 0, 0, 0, 0]
        let time = ligtning.startTime + currentIndex * duration
        for j in 0..<value.count {
            if j == 1 {
                value[j] = ligtning.intensity
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! EffectsSettingTableViewCell
            cell.delegate = self
            if indexPath.row == 0 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
                cell.mSwitch.isOn = ligtning.enable
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Enable"
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Start Date"
                cell.desLabel.text = ligtning.startTime.timeIntToStr()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "End Date"
                cell.desLabel.text = ligtning.endTime.timeIntToStr()
            } else if indexPath.row == 3 {
                cell.titleLabel.text = "Interval"
                cell.desLabel.text = "\(ligtning.interval) 天"
            } else {
                cell.titleLabel.text = "Frequency"
                cell.desLabel.text = "\(ligtning.frequency) 次"
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        cell.delegate = self
        cell.mSlider.value = Float(ligtning.intensity) / Float(100)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HEAD") as! TableViewHeadView
        if section == 0 {
            headView.titleLabel.text = " "
            headView.contentLabel.text = ""
        } else {
            headView.titleLabel.text = "Intensity".uppercased()
            headView.contentLabel.text = "\(ligtning.intensity)%"
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
            } else if indexPath.row == 3 {
                let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDCustomPicker) as! CustomPickerViewController
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.delegate = self
                viewController.componentCount = 1
                present(viewController, animated: false, completion: nil)
                tag = 0
            } else if indexPath.row == 4 {
                let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDCustomPicker) as! CustomPickerViewController
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.delegate = self
                viewController.componentCount = 1
                present(viewController, animated: false, completion: nil)
                tag = 1
            }
        }
    }
}

extension LightningTableViewController: TimePickerViewControllerDelegate {
    func timePickerView(value: String, start: Bool) {
        let time = value.timeStrToInt()
        if start {
            ligtning.startTime = time
        } else {
            ligtning.endTime = time
        }
        tableView.reloadData()
        deviceModel.lightning = ligtning
        DeviceManager.sharedInstance.save()
        handleLightning()
    }
}

extension LightningTableViewController: EffectsSettingBTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        ligtning.intensity = value
        tableView.reloadData()
        deviceModel.lightning = ligtning
        DeviceManager.sharedInstance.save()
        handleLightning()
    }
}

extension LightningTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool, tag: Int) {
        if ligtning.startTime <= 0 ||
            ligtning.endTime <= 0 ||
            ligtning.interval == 0 ||
            ligtning.frequency == 0 {
            tableView.reloadData()
            return
        }
        ligtning.enable = value
        tableView.reloadData()
        deviceModel.lightning = ligtning
        let state = deviceModel.deviceState
        let low = state & 0x0f
        let high = (state >> 4) & 0x0f
        deviceModel.deviceState = (((value ? 0x02 : 0x00) + high & 0b0101) << 4) + low
        DeviceManager.sharedInstance.save()
        if value {
            PreviousFunction(count: ligtning.interval) // 先预览200ms一次
        } else {
            handleLightning()
        }
    }
}

extension LightningTableViewController: CustomPickerViewControllerDelegate {
    func customPickerView(value: Int) {
        if tag == 0 {
            ligtning.interval = value
        } else {
            ligtning.frequency = value
        }
        tableView.reloadData()
        deviceModel.lightning = ligtning
        DeviceManager.sharedInstance.save()
        handleLightning()
    }
}
