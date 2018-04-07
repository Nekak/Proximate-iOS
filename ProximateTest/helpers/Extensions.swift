//
//  Extensions.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    func show() {
        present(true, completion: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIAlertController.hideAlertController), name: NSNotification.Name(rawValue: "DismissAllAlertsNotification"), object: nil)
    }
    
    func present(_ animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    fileprivate func presentFromController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
    
    @objc func hideAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}
