//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  OTAViewController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/15.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit
import Toaster
import Alamofire

class OTAViewController: BaseViewController {

    @IBOutlet weak var upgradeFirmwareALabel: UILabel!
    @IBOutlet weak var upgradeFirmwareBLabel: UILabel!
    @IBOutlet weak var fwLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var upgradeNowButton: UIButton!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var rightLConstraint: NSLayoutConstraint!
    private var bOTA = false
    private var bOTAing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upgradeFirmwareALabel.text = "txt_firewareupgrade".localized()
        upgradeFirmwareBLabel.text = "txt_firewareupgrade".localized()
        noteLabel.text = "txt_firmware_note".localized()
        upgradeNowButton.setTitle("txt_firmware_upgrade_now".localized(), for: .normal)
        upgradeNowButton.backgroundColor = UIColor.hexToColor(hexString: "2A98D5")
        attentionLabel.text = "txt_firmware_attention".localized()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("fw.bin")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            bOTA = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("OTAViewController"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    deinit {
        TCPSocketManager.sharedInstance.disconnectOTASocket()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        let count = notification.object as? NSNumber
        let value = count?.intValue ?? 0
        let total = Dimension.screenWidth - 40
        if value < 0 {
            rightLConstraint.constant = 0
        } else {
            let max = value / 1000
            let current = value % 1000 + 1
            rightLConstraint.constant = CGFloat(CGFloat(max - current) * total / CGFloat(max))
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func upgradeNow(_ sender: Any) {
        if bOTAing == true {
            return
        }
        if !bOTA {
            download()
            return
        }
        TCPSocketManager.sharedInstance.otaUpdate()
        bOTAing = true
    }
    
    func download() {
        let url = "http://www.woaiyijia.com/iot/micmol_firmware_upgrade.bin"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("micmol.bin")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        view.showHUD()
        Alamofire.download(url, headers: ["Charset": "UTF-8"],to: destination).downloadProgress(closure: { (progress) in
            print(progress.fractionCompleted)
        }).response { [weak self] response in
            self?.view.hideHUD()
            print(response)
            if response.error == nil {
                self?.bOTA = true
                TCPSocketManager.sharedInstance.otaUpdate()
                self?.bOTAing = true
            } else {
                Toast(text: "txt_firewareupgrade_fail".localized()).show()
            }
        }
    }
}
