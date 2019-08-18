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
    
    var acclimation: Acclimation!

    override func viewDidLoad() {
        super.viewDidLoad()
        acclimation = Acclimation.load()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
                cell.mSwitch.isOn = acclimation.enable
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
                cell.titleLabel.text = "End Ramp"
                cell.desLabel.text =  "\(acclimation.ramp) hour"
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellCIdentifier, for: indexPath) as! EffectsSettingCTableViewCell
        if indexPath.row < Arrays.barTitles.count {
            cell.leftLabel.text = Arrays.barTitles[indexPath.row]
        } else {
            cell.leftLabel.text = "All"
        }
        cell.mSlider.thumbTintColor = colors[indexPath.row]
        cell.mSlider.minimumTrackTintColor = colors[indexPath.row]
        cell.rightLabel.text = "\(acclimation.intesity[indexPath.row])%"
        let value = acclimation.intesity[indexPath.row]
        cell.mSlider.value = Float(value) / Float(100)
        cell.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Quickly Setup"
        } else if section == 1 {
            return "Ramp Intensity"
        } else {
            return "Speed"
        }
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
        if tag >= 6 {
            acclimation.intesity = [value, value, value, value, value, value, value]
        } else {
            acclimation.intesity[tag] = value
        }
        acclimation.save()
        tableView.reloadData()
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
        acclimation.save()
    }
}

extension AcclimationTableViewController: CustomPickerViewControllerDelegate {
    func customPickerView(value: Int) {
        acclimation.ramp = value
        tableView.reloadData()
        acclimation.save()
    }
}

extension AcclimationTableViewController: EffectsSettingTableViewCellDelegate {
    func valueChanged(_ value: Bool) {
        acclimation.enable = value
        tableView.reloadData()
        acclimation.save()
    }
}