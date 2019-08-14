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

class DeviceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editOrMoveToButton: UIButton!
    private var model : DeviceListModel!
    private var isEdit = false
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
        if let model = DeviceListModel.load() {
            self.model = model
        } else {
            model = DeviceListModel()
        }
    }
    
    private func setLeftNavigationItem() {
        let leftItem = UIBarButtonItem(image: UIImage.top_menu, style: .plain, target: self, action: #selector(pushToMenu))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc private func pushToMenu() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addDevice(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: .kSBIDDeviceSearch) as! SearchDeviceViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addGroup(_ sender: Any) {
        let alert = UIAlertController(title: "New Group Name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak alert, weak self] (action) in
            guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            let model = DeviceModel()
            model.name = name
            model.child = 0
            model.group = true
            self?.model.groups.append(model)
            self?.tableView.reloadData()
            self?.model.save()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editDevice(_ sender: Any) {
        if isEdit {
            //isEdit = false
            //editOrMoveToButton.setTitle("Edit", for: .normal)
            //deleteButton.isHidden = true
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
            let sheet = UIAlertController(title: nil, message: "Attension: More to any group, will rewrite all the settings as same as this group. If more to non group from any group, the current settings will no change.", preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "no group", style: .default, handler: nil))
            for item in array {
                sheet.addAction(UIAlertAction(title: item.name ?? "", style: .default, handler: { (action) in
                    
                }))
            }
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        } else {
            isEdit = true
            editOrMoveToButton.setTitle("More To", for: .normal)
            deleteButton.isHidden = false
        }
        tableView.reloadData()
    }
    
    @IBAction func deleteDevice(_ sender: Any) {
        if selectedIndex == 0 {
            return
        }
        let alert = UIAlertController(title: "Delete Device", message: "Delete this device will be disconnect, if you want to control it again, you need reconnect it.Continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {[weak self] (action) in
            let child = self?.model.groups[self!.selectedIndex - 1].child ?? 0
            if child >  0 {
                self?.model.groups.removeSubrange(self!.selectedIndex - 1...(self!.selectedIndex - 1 + child))
            } else {
                self?.model.groups.remove(at: self!.selectedIndex - 1)
            }
            self?.selectedIndex = 0
            self?.tableView.reloadData()
            self?.model.save()
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
        cell.arrowImageView.isHidden = model.groups[indexPath.row].child == 0
        cell.stateImageView.isHidden = !isEdit
        cell.leftLConstraint.constant = isEdit ? 45 : 20
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
        let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak alert, weak self] (action) in
            guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            self?.model.groups[index].name = name
            self?.tableView.reloadData()
            self?.model.save()
        }))
        present(alert, animated: true, completion: nil)
    }
}
