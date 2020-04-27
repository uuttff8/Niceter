//
//  RoundButton.swift
//  Niceter
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
}
