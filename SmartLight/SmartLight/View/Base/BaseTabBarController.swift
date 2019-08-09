//
// Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
// The program and materials is not free. Without our permission, any use, including but not limited to reproduction, retransmission, communication, display, mirror, download, modification, is expressly prohibited. Otherwise, it will be pursued for legal liability.
// 
//  BaseTabBarController.swift
//  SmartLight
//
//  Created by ANKER on 2019/8/5.
//  Copyright © 2019 PDP-ACC. All rights reserved.
//
	

import UIKit

class BaseTabBarController: UITabBarController {
    
    private var currentItemTag = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag <= 2 {
            currentItemTag = item.tag
        }
    }

}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag > 2 {
            if viewController.tabBarItem.tag == 4 {
                let storyboard = UIStoryboard(name: String.kSBNameSettings, bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: .kSBIDSettings)
                (viewControllers?[currentItemTag - 1] as? BaseNavigationController)?.pushViewController(vc, animated: true)
            } else if viewController.tabBarItem.tag == 3 {
                let storyboard = UIStoryboard(name: String.kSBNameEffects, bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: .kSBIDEffects)
                (viewControllers?[currentItemTag - 1] as? BaseNavigationController)?.pushViewController(vc, animated: true)
            }
            return false
        }
        return true
    }
}
