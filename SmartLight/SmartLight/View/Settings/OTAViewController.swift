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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upgradeFirmwareALabel: UILabel!
    @IBOutlet weak var upgradeFirmwareBLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var fwLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var upgradeNowButton: UIButton!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var rightLConstraint: NSLayoutConstraint!
    private var bOTA = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadButton.layer.borderColor = Color.main.cgColor
        downloadButton.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = Color.main.cgColor
        textField.layer.borderWidth = 0.5
        
        titleLabel.text = "txt_firmware_hint".localized()
        upgradeFirmwareALabel.text = "txt_firewareupgrade".localized()
        upgradeFirmwareBLabel.text = "txt_firewareupgrade".localized()
        noteLabel.text = "txt_firmware_note".localized()
        upgradeNowButton.setTitle("txt_firmware_upgrade_now".localized(), for: .normal)
        attentionLabel.text = "txt_firmware_attention".localized()
        
        textField.text = "http://www.micmol.com/fw/fw.dpk"
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("fw.bin")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            bOTA = true
            upgradeNowButton.backgroundColor = UIColor.hexToColor(hexString: "2A98D5")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    deinit {
        TCPSocketManager.sharedInstance.disconnectOTASocket()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func upgradeNow(_ sender: Any) {
        if !bOTA {
            return
        }
        TCPSocketManager.sharedInstance.otaUpdate()
    }
    
    @IBAction func download(_ sender: Any) {
        textField.resignFirstResponder()
        let url = "http://www.woaiyijia.com/iot/micmol_firmware_upgrade.bin"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("micmol.bin")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(url, headers: ["Charset": "UTF-8"],to: destination).downloadProgress(closure: { (progress) in
            print(progress.fractionCompleted)
        }).response { [weak self] response in
            print(response)
            if response.error == nil {
                Toast(text: "ota_download_sucess".localized()).show()
                self?.bOTA = true
                self?.upgradeNowButton.backgroundColor = UIColor.hexToColor(hexString: "2A98D5")
            }
        }
    }
}
