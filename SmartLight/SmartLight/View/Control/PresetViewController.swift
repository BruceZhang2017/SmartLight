//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  PresetTableViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/14.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class PresetViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var patterns: PatternListModel!
    var isEdit = false
    var current = 0
    var barButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        patterns = PatternListModel.down()
        if patterns.patterns.count > 0 {
            setNavigationRight()
        }
    }
    
    private func setNavigationRight() {
        barButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func edit() {
        isEdit = !isEdit
        barButtonItem.title = isEdit ? "Done" : "Edit"
        tableView.reloadData()
    }

    @IBAction func upload(_ sender: Any) {
        if current == 0 {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Export QR code to Photos", style: .default, handler: { (action) in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deletePattern(_ sender: Any) {
        if current == 0 {
            return
        }
        let alert = UIAlertController(title: "提示", message: "确定删除该模式?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {[weak self] (action) in
            self?.patterns.patterns.remove(at: self!.current - 1)
            self?.tableView.reloadData()
            self?.patterns.save()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension PresetViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patterns?.patterns.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kCellIdentifier, for: indexPath) as! PresetTableViewCell
        cell.nameButton?.setTitle(patterns?.patterns[indexPath.row].name, for: .normal)
        cell.selectImageView.isHidden = !isEdit
        cell.leftLConstraint.constant = isEdit ? 60 : 20
        cell.selectImageView.image = UIImage(named: current - 1 == indexPath.row ? "circle_selected" : "circle_normal")
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isEdit {
            if current - 1 == indexPath.row {
                return
            }
            current = indexPath.row + 1
            tableView.reloadData()
        } else {
            let alert = UIAlertController(title: "Overwrite Current Settings", message: "Selecting apreset will overwrite your current settings.Continues?", preferredStyle: .alert)
            alert.addTextField { (textField) in
                
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {[weak self] (action) in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension PresetViewController: PresetTableViewCellDelegate {
    func editName(index: Int) {
        let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak alert, weak self] (action) in
            guard let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            self?.patterns.patterns[index].name = name
            self?.tableView.reloadData()
            self?.patterns.save()
        }))
        present(alert, animated: true, completion: nil)
    }
}
