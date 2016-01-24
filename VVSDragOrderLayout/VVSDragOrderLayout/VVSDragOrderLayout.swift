//
//  VVSDragOrderLayout.swift
//  VVSDragOrderLayout
//
//  Created by Vishal V Shekkar on 24/01/16.
//  Copyright © 2016 Vishal. All rights reserved.
//

import UIKit

@objc protocol VVSDraggableCellDelegate : UICollectionViewDelegate {
    
    func cellDidMove(fromIndex : NSIndexPath, toIndex: NSIndexPath) -> Void
    
}

class VVSDraggableLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    
    var cellAttributes : [UICollectionViewLayoutAttributes] = []
    var animating : Bool = false
    var collectionViewFrameInCanvas : CGRect = CGRectZero
    var hitTestRectagles = [String:CGRect]()
    var darkTintView = UIView()
    var draggableArea : UIView? {
        didSet {
            if draggableArea != nil {
                calculateBorders()
            }
        }
    }
    
    struct DraggedCell {
        var offset : CGPoint = CGPointZero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : NSIndexPath
    }
    var draggedCell : DraggedCell?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: (collectionView?.frame.width)!, height: (collectionView?.frame.width)!)
    }
    
    var spacing: CGFloat = 15
    var smallerCellWidth: CGFloat {
        return 0.28*(collectionView?.bounds.width)!
    }
    var biggerCellWidth: CGFloat {
        return 0.6*(collectionView?.bounds.width)!
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        self.setup()
        self.calculateBorders()
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        let numberOfsections = (collectionView?.numberOfSections())!
        for section in 0..<numberOfsections
        {
            let numberOfCells = (collectionView?.numberOfItemsInSection(section))!
            cellAttributes = []
            for item in 0..<numberOfCells
            {
                cellAttributes.append(getAttributes(NSIndexPath(forItem: item, inSection: section)))
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attrs = [UICollectionViewLayoutAttributes]()
        for cellAttribute in cellAttributes {
            if CGRectContainsRect(rect, (cellAttribute.frame)) {
                attrs.append(cellAttribute)
            }
        }
        return attrs
    }
    
    func setupPlaceHoldersInView(view: UIView)
    {
        view.backgroundColor = UIColor.clearColor()
        for i in 0...5
        {
            let placeHolder = UIView(frame: getAttributes(NSIndexPath(forItem: i, inSection: 0)).frame)
            placeHolder.backgroundColor = UIColor.whiteColor()
            view.addSubview(placeHolder)
            view.sendSubviewToBack(placeHolder)
        }
    }
    
    func getAttributes(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        let cellAttribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        switch indexPath.row%6
        {
        case 0: cellAttribute.frame = CGRect(x: spacing, y: spacing, width: biggerCellWidth , height: biggerCellWidth)
        case 1: cellAttribute.frame = CGRect(x: biggerCellWidth + 2*spacing, y: spacing, width: smallerCellWidth, height: smallerCellWidth)
        case 2: cellAttribute.frame = CGRect(x: biggerCellWidth + 2*spacing, y: smallerCellWidth + 2*spacing, width: smallerCellWidth, height: smallerCellWidth)
        case 3: cellAttribute.frame = CGRect(x: biggerCellWidth + 2*spacing, y: 2*smallerCellWidth + 3*spacing, width: smallerCellWidth, height: smallerCellWidth)
        case 4: cellAttribute.frame = CGRect(x: smallerCellWidth + 2*spacing, y: 2*smallerCellWidth + 3*spacing, width: smallerCellWidth, height: smallerCellWidth)
        case 5: cellAttribute.frame = CGRect(x: spacing, y: 2*smallerCellWidth + 3*spacing, width: smallerCellWidth, height: smallerCellWidth)
        default: fatalError("This should never happen! Fret!")
        }
        return cellAttribute
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItemAtIndexPath(indexPath)
        let attribute = getAttributes(indexPath)
        return attribute
    }
    
    func setup() {
        darkTintView.backgroundColor = UIColor.blackColor()
        if let collectionView = collectionView {
            
            let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
            
            longPressGestureRecogniser.minimumPressDuration = 0.3
            longPressGestureRecogniser.delegate = self
            
            collectionView.addGestureRecognizer(longPressGestureRecogniser)
            
            if draggableArea == nil {
                draggableArea = collectionView.superview
            }
        }
    }
    
    private func calculateBorders() {
        
        if let collectionView = collectionView {
            
            collectionViewFrameInCanvas = collectionView.frame
            
            if draggableArea != collectionView.superview {
                collectionViewFrameInCanvas = draggableArea!.convertRect(collectionViewFrameInCanvas, fromView: collectionView)
            }
            
            var leftRect : CGRect = collectionViewFrameInCanvas
            leftRect.size.width = 20.0
            hitTestRectagles["left"] = leftRect
            
            var topRect : CGRect = collectionViewFrameInCanvas
            topRect.size.height = 20.0
            hitTestRectagles["top"] = topRect
            
            var rightRect : CGRect = collectionViewFrameInCanvas
            rightRect.origin.x = rightRect.size.width - 20.0
            rightRect.size.width = 20.0
            hitTestRectagles["right"] = rightRect
            
            var bottomRect : CGRect = collectionViewFrameInCanvas
            bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0
            bottomRect.size.height = 20.0
            hitTestRectagles["bottom"] = bottomRect
        }
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleGesture(gesture: UILongPressGestureRecognizer) -> Void {
        
        let dragPointOnCanvas = gesture.locationInView(draggableArea)
        if gesture.state == UIGestureRecognizerState.Began {
            
            if let ca = draggableArea {
                
                if let cv = collectionView {
                    
                    let pointPressedInCanvas = gesture.locationInView(ca)
                    
                    for cell in cv.visibleCells() {
                        
                        let cellInCanvasFrame = ca.convertRect(cell.frame, fromView: cv)
                        
                        if CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas ) {
                            let representationImage = cell.snapshotViewAfterScreenUpdates(true)
                            representationImage.frame = cellInCanvasFrame
                            let offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x, pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                            let indexPath : NSIndexPath = cv.indexPathForCell(cell as UICollectionViewCell)!
                            draggedCell = DraggedCell(
                                offset: offset,
                                sourceCell: cell,
                                representationImageView:representationImage,
                                currentIndexPath: indexPath
                            )
                            break
                        }
                    }
                }
            }
            if draggedCell != nil
            {
                draggedCell!.sourceCell.hidden = true
                draggableArea?.addSubview(draggedCell!.representationImageView)
                darkTintView.frame = draggedCell!.representationImageView.bounds
                UIView.animateWithDuration(0.15, animations: { [weak self]() -> Void in
                    self?.draggedCell!.representationImageView.alpha = 0.8
                })
            }
            
        }
        
        if draggedCell != nil
        {
            if gesture.state == UIGestureRecognizerState.Changed {
                
                // Update the representation image
                var imageViewFrame = draggedCell!.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - draggedCell!.offset.x
                point.y = dragPointOnCanvas.y - draggedCell!.offset.y
                imageViewFrame.origin = point
                draggedCell!.representationImageView.frame = imageViewFrame
                let dragPointOnCollectionView = gesture.locationInView(self.collectionView)
                if let indexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    if indexPath.isEqual(draggedCell!.currentIndexPath) == false {
                        if let delegate = self.collectionView!.delegate as? VVSDraggableCellDelegate {
                            delegate.cellDidMove(draggedCell!.currentIndexPath, toIndex: indexPath)
                        }
                        self.collectionView!.moveItemAtIndexPath(draggedCell!.currentIndexPath, toIndexPath: indexPath)
                        self.draggedCell!.currentIndexPath = indexPath
                    }
                    
                }
                
                
            }
            
            if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Failed || gesture.state == UIGestureRecognizerState.Cancelled  {
                draggedCell!.sourceCell.hidden = false
                draggedCell!.representationImageView.removeFromSuperview()
                if let _ = self.collectionView?.delegate as? VVSDraggableCellDelegate {
                    self.collectionView!.reloadData()
                }
                self.draggedCell = nil
            }
            
        }
    }
    
    
}
