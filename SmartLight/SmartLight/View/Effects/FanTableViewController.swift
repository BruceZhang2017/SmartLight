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

class FanTableViewController: EffectsSettingTableViewController {
    var deviceListModel: DeviceListModel!
    var deviceModel: DeviceModel!
    var fan: Fan!
    var preTimer: Timer?
    var currentIndex = 0
    var totalIndex = 0
    var headerView: TableViewHeaderView!
    var footerView: TableViewFooterView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if DeviceManager.sharedInstance.deviceListModel.groups.count == 0 {
            return
        }
        deviceListModel = DeviceManager.sharedInstance.deviceListModel
        deviceModel = deviceListModel.groups[DeviceManager.sharedInstance.currentIndex]
        fan = deviceModel.fan ?? Fan()
        tableView.register(TableViewHeadView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HEAD")
        headerView = TableViewHeaderView(frame: CGRect(x: 0, y: 0, width: Dimension.screenWidth, height: 90))
        tableView.tableHeaderView = headerView
        let attrString = NSAttributedString(string: "txt_fan_attention".localized(), attributes: [.font: UIFont.systemFont(ofSize: 10)])
        let height = attrString.boundingRect(with: CGSize(width: Dimension.screenWidth - 30, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size.height + 60
        footerView = TableViewFooterView(frame: CGRect(x: 0, y: 0, width: Dimension.screenWidth, height: height))
        tableView.tableFooterView = footerView
    }
    
    private func handleFan() {
        TCPSocketManager.sharedInstance.lightEffect(type: 5, result: fan.enable, device: deviceModel)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if deviceModel == nil {
            return 0
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deviceModel == nil {
            return 0
        }
        if section == 0 {
            return 4
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! EffectsSettingTableViewCell
            cell.delegate = self
            cell.tag = indexPath.row
            if indexPath.row == 0 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
                cell.mSwitch.isOn = fan.enable == 1
            } else if indexPath.row == 1 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
                cell.mSwitch.isOn = fan.enable == 2
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "txt_auto".localized()
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "txt_manual".localized()
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "txt_starttime".localized()
                cell.desLabel.text = fan.startTime.timeIntToStr()
            } else if indexPath.row == 3 {
                cell.titleLabel.text = "txt_endtime".localized()
                cell.desLabel.text = fan.endTime.timeIntToStr()
            }
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        cell.delegate = self
        cell.mSlider.value = Float(min(100, fan.intensity)) / Float(100)
        cell.mSlider.minimumValueImage = UIImage(named: "乌龟")
        cell.mSlider.maximumValueImage = UIImage(named: "兔子")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HEAD") as! TableViewHeadView
        if section == 0 {
            headView.titleLabel.text = ""
            headView.contentLabel.text = ""
        } else {
            headView.titleLabel.text = "txt_fan_speed".localized().uppercased()
            headView.contentLabel.text = "\(min(100, fan.intensity))%"
        }
        return headView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                let storyboard = UIStoryboard(name: .kSBNamePublic, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: .kSBIDTimePicker) as! TimePickerViewController
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.delegate = self
                viewController.start = true
                present(viewController, animated: false, completion: nil)
            } else if indexPath.row == 3 {
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

extension FanTableViewController: TimePickerViewControllerDelegate {
    func timePickerView(value: String, start: Bool) {
        let time = value.timeStrToInt()
        if start {
            fan.startTime = time
        } else {
            fan.endTime = time
        }
        tableView.reloadData()
        deviceModel.fan = fan
        DeviceManager.sharedInstance.save()
        handleFan()
    }
}

extension FanTableViewController: EffectsSettingBTableViewCellDelegate {
    func valueChanged(value: Int, tag: Int) {
        fan.intensity = value
        tableView.reloadData()
        deviceModel.fan = fan
        DeviceManager.sharedInstance.save()
        handleFan()
    }
}

extension FanTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool, tag: Int) {
        if tag == 0 {
            if value {
                fan.enable = 1
            } else {
                if fan.enable == 2 {
                    return
                }
                fan.enable = 0
            }
        } else {
            if value {
                fan.enable = 2
            } else {
                if fan.enable == 1 {
                    return
                }
                fan.enable = 0
            }
        }
        tableView.reloadData()
        deviceModel.fan = fan
        DeviceManager.sharedInstance.save()
        handleFan()
    }
}
