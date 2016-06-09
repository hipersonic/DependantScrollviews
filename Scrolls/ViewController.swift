//
//  ViewController.swift
//  Scrolls
//
//  Created by Daniel Rangelov on 6/9/16.
//  Copyright © 2016 Daniel Rangelov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollViewBottom: UIScrollView!
    @IBOutlet weak var scrollViewTop: UIScrollView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewTop: UIStackView!
    
    
    let colors = [UIColor.redColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.brownColor(), UIColor.grayColor(), UIColor.purpleColor(), UIColor.cyanColor(), UIColor.magentaColor(), UIColor.orangeColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewTop.layer.borderColor = UIColor.grayColor().CGColor
        scrollViewTop.layer.borderWidth = 1
        
        for color in colors {
            stackViewBottom.addArrangedSubview(createRowWithColor(color))
            stackViewTop.addArrangedSubview(createRowWithColor(color))
        }
    }

    func createRowWithColor(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.heightAnchor.constraintEqualToConstant(60).active = true
        view.widthAnchor.constraintEqualToConstant(300).active = true
        return view
    }
    

    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var offset = scrollViewTop.contentOffset
        offset.y = scrollView.contentOffset.y
        scrollViewTop.contentOffset = offset
    }
    
    func matchScrollView(scrollView: UIScrollView, toScrollView otherScrollview: UIScrollView) {
        var offset = otherScrollview.contentOffset
        offset.y = scrollView.contentOffset.y
        otherScrollview.contentOffset = offset
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight:Float = 60
        let targetXContentOffset = Float(targetContentOffset.memory.y)
        let newPage = floor((targetXContentOffset - pageHeight / 2) / pageHeight) + 1
        
        let newTargetOffset = CGFloat(newPage * pageHeight)
        targetContentOffset.memory.y = newTargetOffset
        
        scrollView.setContentOffset(CGPointMake(0, newTargetOffset), animated: true)
    }
}

