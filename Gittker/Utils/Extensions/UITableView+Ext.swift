//
//  UITableView+Ext.swift
//  Gittker
//
//  Created by uuttff8 on 3/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

// MARK: - Searchable Protocol
protocol Searchable {}

// MARK: - Reusable Protocol
protocol ReusableCellIdentifiable {
    static var cellIdentifier: String { get }
}

extension ReusableCellIdentifiable where Self: UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension ReusableCellIdentifiable where Self: UICollectionViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableCellIdentifiable {}
extension UICollectionViewCell: ReusableCellIdentifiable {}


extension UITableView {
    
    func registerNib<T: UITableViewCell>(withClass cellClass: T.Type) {
        register(
            Config.Nib.loadNib(name: T.cellIdentifier),
            forCellReuseIdentifier: T.cellIdentifier
        )
    }
    
    func registerClass<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass.self, forCellReuseIdentifier: cellClass.cellIdentifier)
    }
    
    func cell<T: ReusableCellIdentifiable>(forRowAt indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.cellIdentifier, for: indexPath) as! T
    }
    
    func cell<T: ReusableCellIdentifiable>(forClass cellClass: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: T.cellIdentifier) as! T
    }
    
}
