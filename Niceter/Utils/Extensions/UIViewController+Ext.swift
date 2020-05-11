//
//  UIViewController+Ext.swift
//  Niceter
//
//  Created by uuttff8 on 3/17/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class PortaitViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = true
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UIViewController {
    func showOkAlert(config: SystemAlertConfiguration, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: config.title, message: config.subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: completion))
        let topViewController = UIApplication.shared.windows.last!.rootViewController!
        topViewController.present(alert, animated: true)
    }
}
