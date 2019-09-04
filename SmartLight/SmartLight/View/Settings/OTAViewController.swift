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

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var fwLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var rightLConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadButton.layer.borderColor = Color.main.cgColor
        downloadButton.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = Color.main.cgColor
        textField.layer.borderWidth = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.navBG
        self.navigationController?.navigationBar.tintColor = Color.main
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func upgradeNow(_ sender: Any) {
        
    }
    
    @IBAction func download(_ sender: Any) {
        textField.resignFirstResponder()
        guard let url = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), url.count > 0 else {
            Toast(text: "请输入地址").show()
            return
        }
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("ota.data")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination).downloadProgress(closure: { (progress) in
            print(progress.fractionCompleted)
        }).response {[weak self] response in
            print(response)
            if response.error == nil {
                self?.fwLabel.text = ""
            }
        }
    }
}
