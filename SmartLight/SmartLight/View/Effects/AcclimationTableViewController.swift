//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  EffectsSettingTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/17.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class AcclimationTableViewController: EffectsSettingTableViewController {
    
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var acclimation: Acclimation!
    var preTimer: Timer?
    var currentIndex = 0
    var totalIndex = 0
    var bottomView: BottomView!

    override func viewDidLoad() {
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        acclimation = deviceModel.acclimation ?? Acclimation()
        super.viewDidLoad()
        tableView.register(TableViewHeadView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HEAD")
        bottomView = BottomView(frame: CGRect(x: 0, y: 0, width: Dimension.screenWidth, height: 300))
        tableView.tableFooterView = bottomView
        bottomView.drawLine(deviceModel: deviceModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if deviceModel.deviceType == 3 {
            colors = [Color.bar6, Color.bar2, Color.bar5, Color.yellow]
        } else {
            colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6, Color.yellow]
        }
        tableView.reloadData()
    }
    
    /// 处理Acclimation相关内容
    private func handleAcclimation() {
        TCPSocketManager.sharedInstance.lightSchedual(model: 4, device: deviceModel)
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
            handleAcclimation() // 发送真实的SCHEDULE
            return
        }
        let duration = (acclimation.endTime - acclimation.startTime) / totalIndex
        var value = [0, 0, 0, 0, 0, 0]
        let time = acclimation.startTime + currentIndex * duration
        if time < acclimation.startTime + acclimation.ramp * 60 {
            for j in 0..<value.count {
                value[j] = acclimation.intesity[j] * (time - acclimation.startTime) / (acclimation.ramp * 60)
            }
        } else if time > acclimation.endTime - acclimation.ramp * 60 {
            for j in 0..<value.count {
                value[j] = acclimation.intesity[j] * (acclimation.endTime - time) / (acclimation.ramp * 60)
            }
        } else {
            for j in 0..<value.count {
                value[j] = acclimation.intesity[j]
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
            return 4
        }
        if deviceModel.deviceType == 3 {
            return 4
        }
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! EffectsSettingTableViewCell
            cell.delegate = self
            if indexPath.row == 0 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
                cell.mSwitch.isOn = (deviceModel.deviceState & 0x01) > 0
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Enable"
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Start Date"
                cell.desLabel.text = acclimation.startTime.timeIntToStr()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "End Date"
                cell.desLabel.text = acclimation.endTime.timeIntToStr()
            } else {
                cell.titleLabel.text = "Ramp"
                cell.desLabel.text =  "\(acclimation.ramp) hour"
            }
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellCIdentifier, for: indexPath) as! EffectsSettingCTableViewCell
        let count = deviceModel.deviceType == 3 ? Arrays.barTitleBs.count : Arrays.barTitles.count
        if indexPath.row < count {
            cell.leftLabel.text =  deviceModel.deviceType == 3 ? Arrays.barTitleBs[indexPath.row] : Arrays.barTitles[indexPath.row]
        } else {
            cell.leftLabel.text = "All"
        }
        cell.mSlider.thumbTintColor = colors[indexPath.row]
        cell.mSlider.minimumTrackTintColor = colors[indexPath.row]
        cell.rightLabel.text = "\(acclimation.intesity[indexPath.row])%"
        if (deviceModel.deviceType == 3 && indexPath.row == 3) || (deviceModel.deviceType == 6 && indexPath.row == 6) {
            let value = acclimation.intesity[6]
            cell.mSlider.value = Float(value) / Float(100)
        } else {
            let value = acclimation.intesity[indexPath.row]
            cell.mSlider.value = Float(value) / Float(100)
        }
        cell.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HEAD") as! TableViewHeadView
        headView.contentLabel.text = ""
        if section == 0 {
            headView.titleLabel.text = "Quickly Setup".uppercased()
        } else if section == 1 {
            headView.titleLabel.text = "Ramp Intensity".uppercased()
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
                present(viewController, animated: false, completion: nil)
            }
        }
    }
    
}

extension AcclimationTableViewController: EffectsSettingCTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        if (tag >= 6 && deviceModel.deviceType > 3) || (tag >= 3 && deviceModel.deviceType == 3) {
            if tag >= 6 && deviceModel.deviceType > 3 {
                acclimation.intesity = [value, value, value, value, value, value, value]
            } else {
                acclimation.intesity = [value, value, value, 0, 0, 0, value]
            }
        } else {
            acclimation.intesity[tag] = value
        }
        deviceModel.acclimation = acclimation
        DeviceManager.sharedInstance.save()
        tableView.reloadData()
        handleAcclimation()
        bottomView.drawLine(deviceModel: deviceModel)
    }
}

extension AcclimationTableViewController: TimePickerViewControllerDelegate {
    func timePickerView(value: String, start: Bool) {
        let time = value.timeStrToInt()
        if start {
            acclimation.startTime = time
        } else {
            acclimation.endTime = time
        }
        tableView.reloadData()
        deviceModel.acclimation = acclimation
        DeviceManager.sharedInstance.save()
        handleAcclimation()
        bottomView.drawLine(deviceModel: deviceModel)
    }
}

extension AcclimationTableViewController: CustomPickerViewControllerDelegate {
    func customPickerView(value: Int) {
        acclimation.ramp = value
        tableView.reloadData()
        deviceModel.acclimation = acclimation
        DeviceManager.sharedInstance.save()
        handleAcclimation()
        bottomView.drawLine(deviceModel: deviceModel)
    }
}

extension AcclimationTableViewController: EffectsSettingTableViewCellDelegate {
    // 开关
    func valueChanged(_ value: Bool, tag: Int) {
        if acclimation.startTime <= 0 || acclimation.endTime <= 0 || acclimation.ramp == 0 {
            tableView.reloadData()
            return
        }
        let high = (deviceModel.deviceState >> 4) & 0x0f
        deviceModel.deviceState = (high << 4) + (value ? 1 : 0)
        tableView.reloadData()
        deviceModel.acclimation = acclimation
        DeviceManager.sharedInstance.save()
//        if value {
//            PreviousFunction(count: 50) // 先预览200ms一次
//        } else {
            handleAcclimation()
        //}
    }
}
