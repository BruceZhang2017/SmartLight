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

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        lunnar = deviceModel.lunnar ?? Lunnar()
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
                cell.mSwitch.isOn = lunnar.enable
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Enable"
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Start Date"
                cell.desLabel.text = lunnar.startTime.timeIntToStr()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "End Date"
                cell.desLabel.text = lunnar.endTime.timeIntToStr()
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        cell.delegate = self
        cell.mSlider.value = Float(lunnar.intensity) / Float(100)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            
        } else if section == 1 {
            return "Intensity"
        } else {
            return "Speed"
        }
        return ""
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
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightControl(type: 2, result: lunnar.enable ? 1 : 0, device: deviceModel)
    }
}

extension LunnarTableViewController: EffectsSettingBTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        lunnar.intensity = value
        tableView.reloadData()
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightControl(type: 2, result: lunnar.enable ? 1 : 0, device: deviceModel)
    }
}

extension LunnarTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool) {
        lunnar.enable = value
        tableView.reloadData()
        DeviceManager.sharedInstance.save()
        TCPSocketManager.sharedInstance.lightControl(type: 2, result: lunnar.enable ? 1 : 0, device: deviceModel)
    }
}
