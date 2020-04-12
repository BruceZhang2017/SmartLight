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

class LunnarTableViewController: EffectsSettingTableViewController {
    
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var lunnar: Lunnar!
    var preTimer: Timer?
    var currentIndex = 0
    var totalIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        lunnar = deviceModel.lunnar ?? Lunnar()
        tableView.register(TableViewHeadView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HEAD")
    }
    
    private func handleLunnar() {
        TCPSocketManager.sharedInstance.lightEffect(type: 0, result: (deviceModel.deviceState & 0b01000000) > 0 ? 2 : 1, device: deviceModel)
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
            handleLunnar() // 发送真实的SCHEDULE
            return
        }
        let duration = (lunnar.endTime - lunnar.startTime) / totalIndex
        var value = [0, 0, 0, 0, 0, 0]
        let time = lunnar.startTime + currentIndex * duration
        for j in 0..<value.count {
            if j == 1 {
                value[j] = lunnar.intensity
            } else {
                let manager = CurrentLightValueManager()
                value[j] = Int(manager.calCurrent(deviceModel: deviceModel, currentTime: time, index: j))
            }
        }
        TCPSocketManager.sharedInstance.lightPreview(value: value)
        currentIndex += 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
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
                cell.mSwitch.isOn = (deviceModel.deviceState & 0b01000000) > 0
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            cell.mSwitch.isUserInteractionEnabled = !CheckDeviceState().checkCurrentDeviceStateIsAllOnOrAllOff()
            if indexPath.row == 0 {
                cell.titleLabel.text = "txt_enable".localized()
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "txt_starttime".localized()
                cell.desLabel.text = lunnar.startTime.timeIntToStr()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "txt_endtime".localized()
                cell.desLabel.text = lunnar.endTime.timeIntToStr()
            }
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        cell.delegate = self
        cell.mSlider.value = Float(lunnar.intensity) / Float(100)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HEAD") as! TableViewHeadView
        if section == 0 {
            headView.titleLabel.text = " "
            headView.contentLabel.text = ""
        } else {
            headView.titleLabel.text = "txt_intensity".localized().uppercased()
            headView.contentLabel.text = "\(lunnar.intensity)%"
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

extension LunnarTableViewController: TimePickerViewControllerDelegate {
    func timePickerView(value: String, start: Bool) {
        let time = value.timeStrToInt()
        if start {
            lunnar.startTime = time
        } else {
            lunnar.endTime = time
        }
        tableView.reloadData()
        deviceModel.lunnar = lunnar
        DeviceManager.sharedInstance.save()
        handleLunnar()
    }
}

extension LunnarTableViewController: EffectsSettingBTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        lunnar.intensity = value
        tableView.reloadData()
        deviceModel.lunnar = lunnar
        DeviceManager.sharedInstance.save()
        handleLunnar()
    }
}

extension LunnarTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool, tag: Int) {
        if lunnar.startTime <= 0 || lunnar.endTime <= 0 {
            tableView.reloadData()
            return
        }
        tableView.reloadData()
        deviceModel.lunnar = lunnar
        let state = deviceModel.deviceState
        let low = state & 0x0f
        let high = (state >> 4) & 0x0f
        deviceModel.deviceState = (((value ? 0x04 : 0x00) + high & 0b1011) << 4) + low
        DeviceManager.sharedInstance.save()
        if value {
            PreviousFunction(count: 50) // 先预览200ms一次
        } else {
            handleLunnar()
        }
    }
}
