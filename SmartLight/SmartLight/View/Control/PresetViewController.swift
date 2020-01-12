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
import EFQRCode

class PresetViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var patterns: PatternListModel!
    var isEdit = false
    var current = 0
    var barButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.setTitle("txt_delete".localized(), for: .normal)
    }
    
    private func setNavigationRight() {
        barButtonItem = UIBarButtonItem(title: "txt_edit".localized(), style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func setText() {
        patterns = PatternListModel.down()
        if patterns.patterns.count > 0 {
            setNavigationRight()
        }
    }
    
    @objc private func edit() {
        isEdit = !isEdit
        barButtonItem.title = isEdit ? "txt_done".localized() : "txt_edit".localized()
        tableView.reloadData()
        uploadButton.isHidden = !isEdit
        deleteButton.isHidden = !isEdit
    }

    @IBAction func upload(_ sender: Any) {
        if current == 0 {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_qrcode_save".localized(), style: .default, handler: { [weak self] (action) in
            self?.createQRCode()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deletePattern(_ sender: Any) {
        if current == 0 {
            return
        }
        let alert = UIAlertController(title: "tip".localized(), message: "delete_mode".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
            self?.patterns.patterns.remove(at: self!.current - 1)
            self?.tableView.reloadData()
            self?.patterns.save()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func createQRCode() {
        if let tryImage = EFQRCode.generate(
            content: TCPSocketManager.sharedInstance.createQRCode(pattern: patterns.patterns[current - 1]),
            watermark: UIImage(named: "logo")?.toCGImage()
            ) {
            print("Create QRCode image success: \(tryImage)")
            UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: tryImage), self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("Create QRCode image failed!")
        }
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        print("保存失败")
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
            let alert = UIAlertController(title: "txt_preset_overwrite".localized(), message: "txt_preset_overwrite_hint".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "txt_ok".localized(), style: .default, handler: {[weak self] (action) in
                let models = DeviceManager.sharedInstance.deviceListModel.groups
                let current = DeviceManager.sharedInstance.currentIndex
                if current < models.count {
                    models[current].pattern = self?.patterns?.patterns[indexPath.row]
                }
                DeviceManager.sharedInstance.deviceListModel.groups = models
                DeviceManager.sharedInstance.save()
                NotificationCenter.default.post(name: Notification.Name("ControlViewController"), object: nil)
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension PresetViewController: PresetTableViewCellDelegate {
    func editName(index: Int) {
        let alert = UIAlertController(title: "txt_rename".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        alert.addAction(UIAlertAction(title: "txt_cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "txt_save".localized(), style: .default, handler: {[weak alert, weak self] (action) in
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
