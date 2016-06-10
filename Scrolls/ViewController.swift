//
//  ViewController.swift
//  Scrolls
//
//  Created by Daniel Rangelov on 6/9/16.
//  Copyright © 2016 Daniel Rangelov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let colors = [UIColor.redColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.brownColor(), UIColor.grayColor(), UIColor.purpleColor(), UIColor.cyanColor(), UIColor.magentaColor(), UIColor.orangeColor()]
    
    
    @IBOutlet weak var scrollIndicatorView: ScrollerIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentModels = colors.map { (color) -> CellModel in
            return CellModel(backgroundColor: color)
        }
        scrollIndicatorView.contentModels = contentModels
    }
}

