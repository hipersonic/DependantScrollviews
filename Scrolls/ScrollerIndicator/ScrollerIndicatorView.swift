//
//  ScrollerIndicatorView.swift
//  Scrolls
//
//  Created by Daniel Rangelov on 6/10/16.
//  Copyright © 2016 Daniel Rangelov. All rights reserved.
//

import UIKit

protocol ScrollerIndicatorViewDelegate {
    func didChangeSelectedIndex(sender: ScrollerIndicatorView, selectedIndex: Int, dataModelForSelection:CellModel)
}

class ScrollerIndicatorView: UIView, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: ScrollerIndicatorViewDelegate?
    
    ///The data models from which the cells will be populated
    var contentModels = [CellModel]() {
        didSet {
            masterTableView.reloadData()
            indicatorTableView.reloadData()
        }
    }
    
    ///The height of the indicator and the cells in the tableViews
    var indicatorViewHeight:Float = 60 {
        didSet {
            updateIndicatorViewHeight()
        }
    }
    
    /**
     Holds the current selected index value
     For animated selection change Refer to: func changeSelection(selectedIndex: Int, animated: Bool = true)
     */
    private(set) var selectedIndex = 0
    
    private var masterTableView = UITableView()
    private var indicatorTableView = UITableView()
    private var indicatorHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let verticalInset = self.verticalInset()
        masterTableView.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
    }
    
    private func setup() {
        self.addSubview(masterTableView)
        self.addSubview(indicatorTableView)
        
        masterTableView.dataSource = self
        masterTableView.delegate = self
        masterTableView.showsVerticalScrollIndicator = false
        
        indicatorTableView.dataSource = self
        indicatorTableView.delegate = self
        indicatorTableView.userInteractionEnabled = false
        
        setupConstraints()
        
        masterTableView.setNeedsLayout()
        masterTableView.layoutIfNeeded()
        
        indicatorTableView.layer.borderColor = UIColor.greenColor().CGColor
        indicatorTableView.layer.borderWidth = 1
    }
    
    private func updateIndicatorViewHeight() {
        indicatorHeightConstraint?.constant = CGFloat(self.indicatorViewHeight)
        indicatorTableView.setNeedsUpdateConstraints()
        indicatorTableView.layoutIfNeeded()
    }
    
    private func setupConstraints() {
        let views = ["masterView": masterTableView,
                     "indicatorView": indicatorTableView]
        
        var allConstraints = [NSLayoutConstraint]()
        
        masterTableView.translatesAutoresizingMaskIntoConstraints = false
        indicatorTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let masterViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(0)-[masterView]-(0)-|",
            options: [],
            metrics: nil,
            views: views)
        allConstraints += masterViewHorizontalConstraints
        
        let masterViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(0)-[masterView]-(0)-|",
            options: [],
            metrics: nil,
            views: views)
        allConstraints += masterViewVerticalConstraints
        
        let indicatorViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(0)-[indicatorView]-(0)-|",
            options: [],
            metrics: nil,
            views: views)
        allConstraints += indicatorViewHorizontalConstraints
        
        let centerYConstraint = NSLayoutConstraint(
            item: indicatorTableView,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: masterTableView,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        allConstraints += [centerYConstraint]
        
        indicatorHeightConstraint = NSLayoutConstraint(
            item: indicatorTableView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: CGFloat(indicatorViewHeight))
        
        if let indicatorHeightConstraint = indicatorHeightConstraint {
            self.addConstraint(indicatorHeightConstraint)
            allConstraints += [indicatorHeightConstraint]
        }
        
        NSLayoutConstraint.activateConstraints(allConstraints)
    }
    
    /**
        Use this method to change the selection. It gives the option to animate the transition.
     
        - Parameter selectedIndex - the index to be selected
        - Parameter animated - should animation be visible to the user
    */
    func changeSelection(index: Int, animated: Bool = true) {
        selectedIndex = index
        masterTableView.setContentOffset(contentOffsetForRow(selectedIndex), animated: animated)
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    internal func scrollViewDidScroll(scrollView: UIScrollView) {
        matchScrollView(masterTableView, toScrollView: indicatorTableView)
    }
    
    internal func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let verticalInset = self.verticalInset()
        let targetXContentOffset = Float(targetContentOffset.memory.y)
        let newPage = Int(floor( (targetXContentOffset + Float(verticalInset) - indicatorViewHeight / 2) / indicatorViewHeight) + 1)
        selectedIndex = newPage
        
        let newTargetOffset = contentOffsetForRow(newPage)
        targetContentOffset.memory.y = newTargetOffset.y
        
        scrollView.setContentOffset(newTargetOffset, animated: true)
    }
    
    
    //MARK: - UIScrollView Synchronization Helpers
    
    private func matchScrollView(scrollView: UIScrollView, toScrollView otherScrollview: UIScrollView) {
        let verticalInset = self.verticalInset()
        var offset = otherScrollview.contentOffset
        offset.y = scrollView.contentOffset.y + verticalInset
        otherScrollview.contentOffset = offset
    }
    
    private func verticalInset() -> CGFloat {
        guard masterTableView.frame.size.height > 0 else {
            return 0
        }
        
        return (masterTableView.frame.size.height - CGFloat(indicatorViewHeight))/2
    }
    
    private func contentOffsetForRow(row: Int) -> CGPoint {
        return CGPoint(x: 0, y: CGFloat(row) * CGFloat(indicatorViewHeight) - verticalInset())
    }
    
    
    //MARK: - UITableViewDelegate
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        changeSelection(indexPath.row)
    }
    
    
    //MARK: - UITableViewDataSource
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentModels.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let contentModel = contentModels[indexPath.row]
        
        if tableView == masterTableView {
            let cellMaster = masterTableView.dequeueReusableCellWithIdentifier("cell") as? MasterTableViewCell ?? MasterTableViewCell()
            cellMaster.backgroundColor = contentModel.backgroundColor
            cellMaster.textLabel?.text = contentModel.title
            cellMaster.textLabel?.textColor = UIColor.whiteColor()
            cell = cellMaster as UITableViewCell
        } else if tableView == indicatorTableView {
            let cellIndicator = indicatorTableView.dequeueReusableCellWithIdentifier("cell") as? IndicatorTableViewCell ?? IndicatorTableViewCell()
            cellIndicator.backgroundColor = contentModel.backgroundColor
            cellIndicator.textLabel?.text = contentModel.title
            cell = cellIndicator as UITableViewCell
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(indicatorViewHeight)
    }
    
}
