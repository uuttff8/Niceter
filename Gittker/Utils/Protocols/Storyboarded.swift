//
//  Storyboarded.swift
//  Gittker
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

enum AppStoryboards: String {
    case LoginAuth = "LoginAuth"
}

protocol Storyboarded {
    static func instantiate(from storyboardId: AppStoryboards) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(from storyboardId: AppStoryboards) -> Self {
        let id = String(describing: self)
        // load our storyboard
        var storyboard: UIStoryboard!
        
        func createStoryboard(_ sb: AppStoryboards) {
            storyboard = UIStoryboard(name: sb.rawValue, bundle: Bundle.main)
            print("UIStoryboard: \(storyboard.value(forKey: "name") ?? "Error! Unknown class")")
        }
        
        // TODO(uuttff8): Refactor
        switch storyboardId {
        case .LoginAuth:
            createStoryboard(storyboardId)
        }
                
        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}
