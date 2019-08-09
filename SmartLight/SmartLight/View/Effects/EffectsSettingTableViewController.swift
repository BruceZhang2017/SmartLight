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

class EffectsSettingTableViewController: UITableViewController {
    
    var tag = 0
    private let colors = [Color.bar1, Color.bar2, Color.bar3, Color.bar4, Color.bar5, Color.bar6, Color.yellow]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: .kEffectsSettingTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellIdentifier)
        tableView.register(UINib(nibName: .kEffectsSettingBTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellBIdentifier)
        tableView.register(UINib(nibName: .kEffectsSettingCTableViewCell, bundle: nil), forCellReuseIdentifier: .kCellCIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tag == 3 { return 3 }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tag == 0 {
            if section == 0 {
                return 4
            }else if section == 1 {
                return 7
            }
        } else if tag == 1 {
            if section == 0 {
                return 3
            } else if section == 1 {
                return 1
            }
        } else if tag == 2 {
            if section == 0 {
                return 4
            } else if section == 1 {
                return 1
            }
        } else {
            if section == 0 {
                return 3
            } else if section == 1 {
                return 1
            } else {
                return 1
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! EffectsSettingTableViewCell
            if indexPath.row == 0 {
                cell.mSwitch.isHidden = false
                cell.desLabel.isHidden = true
            } else {
                cell.mSwitch.isHidden = true
                cell.desLabel.isHidden = false
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Enable"
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Start Date"
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "End Date"
            } else {
                if tag == 0 {
                    cell.titleLabel.text = "End Ramp"
                } else {
                    cell.titleLabel.text = "Frequency"
                }
            }
            return cell
        } else {
            if tag == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: .kCellCIdentifier, for: indexPath) as! EffectsSettingCTableViewCell
                if indexPath.row < Arrays.barTitles.count {
                    cell.leftLabel.text = Arrays.barTitles[indexPath.row]
                } else {
                    cell.leftLabel.text = "All"
                }
                cell.mSlider.thumbTintColor = colors[indexPath.row]
                cell.mSlider.minimumTrackTintColor = colors[indexPath.row]
                cell.rightLabel.text = "50%"
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellBIdentifier, for: indexPath) as! EffectsSettingBTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if tag == 0 {
                return "Quickly Setup"
            }
        } else if section == 1 {
            if tag == 0 {
                return "Ramp Intensity"
            } else {
                return "Intensity"
            }
        } else {
            return "Speed"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
