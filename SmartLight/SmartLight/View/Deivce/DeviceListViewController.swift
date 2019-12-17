//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  DeviceListViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/11.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class DeviceListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editOrMoveToButton: UIButton!
    private var model : DeviceListModel!
    private var isEdit = false
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        model = DeviceManager.sharedInstance.deviceListModel
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.main
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    private func setLeftNavigationItem() {
        let leftItem = UIBarButtonItem(image: UIImage.top_menu, style: .plain, target: self, action: #selector(pushToMenu))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    override func setText() {
        
    }
    
    @objc private func pushToMenu() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addDevice(_ sender: Any) {
        if !MCLocation.shared.didUpdateLocation(self) {
            return
        }
        let viewController = storyboard?.instantiateViewController(withIdentifier: .kSBIDDeviceSearch) as! SearchDeviceViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addGroup(_ sender: Any) {
        let alert = UIAlertController(title: "txt_newgroup".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert, weak self] (action) in
            guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            let model = DeviceModel()
            model.name = name
            model.child = 0
            model.group = true
            model.ip = "\(Int(Date().timeIntervalSince1970))"
            self?.model.groups.append(model)
            self?.tableView.reloadData()
            DeviceManager.sharedInstance.save()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editDevice(_ sender: Any) {
        if isEdit {
            if selectedIndex == 0 {
                return
            }
            let item = model.groups[selectedIndex - 1]
            if item.group {
                return
            }
            let array = model.groups.filter{$0.group}
            if array.count == 0 {
                return
            }
            var keys: [Int] = []
            for (index, value) in model.groups.enumerated() {
                if value.group {
                    keys.append(index)
                }
            }
            let sheet = UIAlertController(title: nil, message: "txt_group_moveto_int".localized(), preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Non-Group", style: .default, handler: {
                [weak self] (action) in
                let child = self?.model.groups[self!.selectedIndex - 1].child ?? 0
                if child > 0 {
                    return
                }
                guard let item = self?.model.groups.remove(at: self!.selectedIndex - 1) else {
                    return
                }
                if item.superModel < 0 {
                    return
                }
                self?.model.groups[item.superModel].child -= 1
                item.superModel = -1
                self?.model.groups.insert(item, at: 0)
                self?.selectedIndex = 0
                self?.tableView.reloadData()
                DeviceManager.sharedInstance.save()
            }))
            for (index, item) in array.enumerated() {
                sheet.addAction(UIAlertAction(title: item.name ?? "", style: .default, handler: { [weak self] (action) in
                    let child = self?.model.groups[self!.selectedIndex - 1].child ?? 0
                    if child > 0 {
                        return
                    }
                    guard let item = self?.model.groups.remove(at: self!.selectedIndex - 1) else {
                        return
                    }
                    if (self!.selectedIndex - 1) > keys[index] {
                        item.superModel = keys[index]
                        self?.model.groups.insert(item, at: keys[index] + 1)
                    } else {
                        item.superModel = keys[index] - 1
                        self?.model.groups.insert(item, at: keys[index])
                    }
                    self?.selectedIndex = 0
                    self?.tableView.reloadData()
                    DeviceManager.sharedInstance.save()
                }))
            }
            sheet.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        } else {
            isEdit = true
            editOrMoveToButton.setTitle("txt_movetogroup".localized(), for: .normal)
            deleteButton.isHidden = false
        }
        tableView.reloadData()
    }
    
    @IBAction func deleteDevice(_ sender: Any) {
        if selectedIndex == 0 {
            return
        }
        let alert = UIAlertController(title: "txt_deletedevice".localized(), message: "txt_deletedevice_hint".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
            let child = self?.model.groups[self!.selectedIndex - 1].child ?? 0
            if child >  0 {
                self?.model.groups.removeSubrange(self!.selectedIndex - 1...(self!.selectedIndex - 1 + child))
            } else {
                self?.model.groups.remove(at: self!.selectedIndex - 1)
            }
            self?.selectedIndex = 0
            self?.tableView.reloadData()
            DeviceManager.sharedInstance.save()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! DeviceListTableViewCell
        cell.nameButton?.setTitle( model.groups[indexPath.row].name, for: .normal)
        cell.arrowImageView.isHidden = !model.groups[indexPath.row].group
        cell.stateImageView.isHidden = !isEdit
        let left = model.groups[indexPath.row].superModel >= 0 ? 15 : 0
        cell.leftLConstraint.constant = CGFloat((isEdit ? 45 : 20) + left)
        cell.circleImageLeftLConstraint.constant = CGFloat(left + 15)
        cell.nameButton.titleLabel?.font = model.groups[indexPath.row].child == 0 ? UIFont.systemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 16)
        cell.tag = indexPath.row
        cell.delegate = self
        if selectedIndex - 1 == indexPath.row {
            cell.stateImageView.image = UIImage(named: "circle_selected")
        } else {
            cell.stateImageView.image = UIImage(named: "circle_normal")
        }
        return cell
    }
    
    
}

extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isEdit {
            return
        }
        if selectedIndex - 1 == indexPath.row {
            selectedIndex = 0
            tableView.reloadData()
        } else {
            selectedIndex = indexPath.row + 1
            tableView.reloadData()
        }
    }
}

extension DeviceListViewController: DeviceListTableViewCellDelegate {
    func editName(index: Int) {
        let alert = UIAlertController(title: "txt_rename".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert, weak self] (action) in
            guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            self?.model.groups[index].name = name
            self?.tableView.reloadData()
             DeviceManager.sharedInstance.save()
        }))
        present(alert, animated: true, completion: nil)
    }
}
