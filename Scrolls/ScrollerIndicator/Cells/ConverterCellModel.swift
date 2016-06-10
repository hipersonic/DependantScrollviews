//
//  CellModel.swift
//  Scrolls
//
//  Created by Daniel Rangelov on 6/10/16.
//  Copyright © 2016 Daniel Rangelov. All rights reserved.
//

import UIKit

class CellModel: NSObject {
    var backgroundColor: UIColor!
    var title = "Test Title"
    
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }
}
