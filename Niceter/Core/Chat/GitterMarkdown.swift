//
//  GitterMarkdown.swift
//  Niceter
//
//  Created by uuttff8 on 4/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import MarkdownKit

class GitterMarkdown: MarkdownParser {
    init() {
        super.init(font : UIFont.systemFont(ofSize: UIFont.systemFontSize), color: UIColor.label)
    }
}
