//
//  MJKLayout.swift
//  Fankins
//
//  Created by Morgan Kennedy on 10/12/2014.
//  Copyright (c) 2014 FankinsApp. All rights reserved.
//

import Foundation
import CoreGraphics

enum MJKHAlign: Int
{
    // X Coordinate Alignments
    case HCenter = 1,
    Left,
    Right,
    ExactHCenter,
    ExactLeft, // Aligns the view to the extreme left of the parent view (ie: x = 0)
    ExactRight, // Aligns the view to the extreme right of the parent view
    None
}

enum MJKVAlign: Int
{
    // Y Coordinate Alignments
    case VCenter = 1,
    Top,
    Bottom,
    ExactVCenter,
    ExactTop,
    ExactBottom,
    None
}

enum MJKPlace: Int
{
    case OnLeft = 1,
    OnRight,
    Above,
    Below,
    Within
}

enum MJKSize: Int
{
    case UseAllWidth = 1,
    UseAllHeight,
    UseAvailableWidth,
    UseAvailableHeight
}

class MJKPadding
{
    var top: CGFloat
    var bottom: CGFloat
    var left: CGFloat
    var right: CGFloat
    
    init()
    {
        self.top = 0
        self.bottom = 0
        self.left = 0
        self.right = 0
    }
    
    init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
    {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
    
    init(allSidesEqual side: CGFloat) // Generally make it zero (but standard initi does that)
    {
        self.top = side
        self.bottom = side
        self.left = side
        self.right = side
    }
}

class MJKLayout
{
    // MARK: Size Determinant Helper Methods
    class func sizeForLabel(#label: UILabel, maxSize: CGSize) -> CGSize
    {
        var labelSize = label.sizeThatFits(maxSize)
        
        return labelSize
    }
    
    class func sizeForLabel(#label: UILabel, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize
    {
        return self.sizeForLabel(label: label, maxSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    class func sizeForTextView(#textView: UITextView, maxSize: CGSize) -> CGSize
    {
        var textViewSize = textView.sizeThatFits(maxSize)
        
        return textViewSize
    }
    
    class func sizeForTextView(#textView: UITextView, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize
    {
        return self.sizeForTextView(textView: textView, maxSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    // MARK: Layout Methods
    // View to View
    class func layoutView(#view: UIView, relativeToView relativeView: UIView, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withSize size: CGSize, withPadding padding: MJKPadding) -> UIView
    {
        return self.layoutView(view: view, relativeToView: relativeView, placement: placement, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: size.width, withHeight: size.height, withPadding: padding)
    }
    
    class func layoutView(#view: UIView, relativeToView relativeView: UIView, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withWidth width: CGFloat, withHeight height: CGFloat, withPadding padding: MJKPadding) -> UIView
    {
        if let nonNilViewSuperview = view.superview
        {
            if (placement == MJKPlace.Within)
            {
                relativeView.addSubview(view)
            }
            else if let nonNilRelativeViewSuperview = relativeView.superview
            {
                nonNilRelativeViewSuperview.addSubview(view)
            }
        }
        
        var viewFrame = view.frame
        
        viewFrame.size.width = width
        viewFrame.size.height = height
        
        // Update the view with the correct size
        view.frame = viewFrame
        
        // Is the view a child of the relative View
        if  (view.superview === relativeView)
        {
            view.frame = self.calculateLayoutFrame(frame: view.frame, withinParentBounds: relativeView.bounds, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: width, withHeight: height, padding: padding)
        }
        else // Assume the view is a peer of the relative view
        {
            view.frame = self.calculateLayoutFrame(frame: view.frame, relativeToPeerFrame: relativeView.frame, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, placement: placement, withWidth: width, withHeight: height, padding: padding)
        }
        
        view.frame = self.roundFrame(frame: view.frame)
        
        return view
    }
    
    // View to Node
    class func layoutView(#view: UIView, relativeToNode relativeNode: ASDisplayNode, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withSize size: CGSize, withPadding padding: MJKPadding) -> UIView
    {
        return self.layoutView(view: view, relativeToNode: relativeNode, placement: placement, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: size.width, withHeight: size.height, withPadding: padding)
    }
    
    class func layoutView(#view: UIView, relativeToNode relativeNode: ASDisplayNode, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withWidth width: CGFloat, withHeight height: CGFloat, withPadding padding: MJKPadding) -> UIView
    {
        if let nonNilViewSuperview = view.superview
        {
            if (placement == MJKPlace.Within)
            {
                relativeNode.view.addSubview(view)
            }
            else if let nonNilRelativeViewSuperview = relativeNode.view.superview
            {
                nonNilRelativeViewSuperview.addSubview(view)
            }
        }
        
        var viewFrame = view.frame
        
        viewFrame.size.width = width
        viewFrame.size.height = height
        
        // Update the view with the correct size
        view.frame = viewFrame
        
        // Is the view a child of the relative View
        if  (view.superview === relativeNode.view)
        {
            view.frame = self.calculateLayoutFrame(frame: view.frame, withinParentBounds: relativeNode.bounds, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: width, withHeight: height, padding: padding)
        }
        else // Assume the view is a peer of the relative view
        {
            view.frame = self.calculateLayoutFrame(frame: view.frame, relativeToPeerFrame: relativeNode.frame, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, placement: placement, withWidth: width, withHeight: height, padding: padding)
        }
        
        view.frame = self.roundFrame(frame: view.frame)
        
        return view
    }
    
    // Node to Node
    class func layoutNode(#node: ASDisplayNode, relativeToNode relativeNode: ASDisplayNode, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withSize size: CGSize, withPadding padding: MJKPadding) -> ASDisplayNode
    {
        return self.layoutNode(node: node, relativeToNode: relativeNode, placement: placement, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: size.width, withHeight: size.height, withPadding: padding)
    }
    
    class func layoutNode(#node: ASDisplayNode, relativeToNode relativeNode: ASDisplayNode, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withWidth width: CGFloat, withHeight height: CGFloat, withPadding padding: MJKPadding) -> ASDisplayNode
    {
        if let nonNilNodeSupernode = node.subnodes
        {
            if (placement == MJKPlace.Within)
            {
                relativeNode.addSubnode(node)
            }
            else if let nonNilRelativeNodeSupernode = relativeNode.supernode
            {
                nonNilRelativeNodeSupernode.addSubnode(node)
            }
        }
        
        var nodeFrame = node.frame
        
        nodeFrame.size.width = width
        nodeFrame.size.height = height
        
        // Update the view with the correct size
        node.frame = nodeFrame
        
        // Is the view a child of the relative View
        if  (node.supernode === relativeNode)
        {
            node.frame = self.calculateLayoutFrame(frame: node.frame, withinParentBounds: relativeNode.bounds, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: width, withHeight: height, padding: padding)
        }
        else // Assume the view is a peer of the relative view
        {
            node.frame = self.calculateLayoutFrame(frame: node.frame, relativeToPeerFrame: relativeNode.frame, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, placement: placement, withWidth: width, withHeight: height, padding: padding)
        }
        
        node.frame = self.roundFrame(frame: node.frame)
        
        return node
    }
    
    // Node to View
    class func layoutNode(#node: ASDisplayNode, relativeToView relativeView: UIView, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withSize size: CGSize, withPadding padding: MJKPadding) -> ASDisplayNode
    {
        return self.layoutNode(node: node, relativeToView: relativeView, placement: placement, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: size.width, withHeight: size.height, withPadding: padding)
    }
    
    class func layoutNode(#node: ASDisplayNode, relativeToView relativeView: UIView, placement: MJKPlace, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withWidth width: CGFloat, withHeight height: CGFloat, withPadding padding: MJKPadding) -> ASDisplayNode
    {
        if let nonNilNodeSuperview = node.view.superview
        {
            if (placement == MJKPlace.Within)
            {
                relativeView.addSubview(node.view)
            }
            else if let nonNilRelativeViewSuperview = relativeView.superview
            {
                nonNilRelativeViewSuperview.addSubview(node.view)
            }
        }
        
        var nodeFrame = node.frame
        
        nodeFrame.size.width = width
        nodeFrame.size.height = height
        
        // Update the view with the correct size
        node.frame = nodeFrame
        
        // Is the view a child of the relative View
        if  (node.view.superview === relativeView)
        {
            node.frame = self.calculateLayoutFrame(frame: node.frame, withinParentBounds: relativeView.bounds, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, withWidth: width, withHeight: height, padding: padding)
        }
        else // Assume the view is a peer of the relative view
        {
            node.frame = self.calculateLayoutFrame(frame: node.frame, relativeToPeerFrame: relativeView.frame, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment, placement: placement, withWidth: width, withHeight: height, padding: padding)
        }
        
        node.frame = self.roundFrame(frame: node.frame)
        
        return node
    }
    
    // MARK: Private Methods
    private class func calculateLayoutFrame(#frame: CGRect, withinParentBounds parentBounds: CGRect, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, withWidth width: CGFloat, withHeight height: CGFloat, padding: MJKPadding) -> CGRect
    {
        var layoutFrame = frame
        
        // Horizontal Alignment
        switch (horizontalAlignment)
        {
        case .Left:
            layoutFrame.origin.x = padding.left
            
        case .Right:
            layoutFrame.origin.x = parentBounds.size.width - width - padding.right
            
        case .ExactLeft:
            layoutFrame.origin.x = 0
            
        case .ExactRight:
            layoutFrame.origin.x = parentBounds.size.width - width
            
        case .HCenter:
            layoutFrame.origin.x = (parentBounds.size.width / 2.0 - width / 2.0) + padding.left - padding.right
            
        case .ExactHCenter:
            layoutFrame.origin.x = (parentBounds.size.width / 2.0 - width / 2.0)
            
        default:
            layoutFrame.origin.x = layoutFrame.origin.x
        }
        
        // Vertical Alignment
        switch (verticalAlignment)
        {
        case .VCenter:
            layoutFrame.origin.y = (parentBounds.size.height / 2.0 - height / 2.0) + padding.top - padding.bottom
            
        case .ExactVCenter:
            layoutFrame.origin.y = (parentBounds.size.height / 2.0 - height / 2.0)

        case .Top:
            layoutFrame.origin.y = padding.top
            
        case .Bottom:
            layoutFrame.origin.y = parentBounds.size.height - height - padding.bottom
            
        case .ExactTop:
            layoutFrame.origin.y = 0
            
        case .ExactBottom:
            layoutFrame.origin.y = parentBounds.size.height - height
            
        default:
            layoutFrame.origin.y = layoutFrame.origin.y
        }
        
        return layoutFrame
    }
    
    private class func calculateLayoutFrame(#frame: CGRect, relativeToPeerFrame relativeFrame: CGRect, horizontalAlignment: MJKHAlign, verticalAlignment: MJKVAlign, placement: MJKPlace, withWidth width: CGFloat, withHeight height: CGFloat, padding: MJKPadding) -> CGRect
    {
        var layoutFrame = frame
        
        // Placement
        switch (placement)
        {
        case .OnLeft:
            layoutFrame.origin.x = relativeFrame.origin.x - width - padding.right
            
        case .OnRight:
            layoutFrame.origin.x = relativeFrame.origin.x + relativeFrame.size.width + padding.left
            
        case .Above:
            layoutFrame.origin.y = relativeFrame.origin.y - height - padding.bottom
            
        case .Below:
            layoutFrame.origin.y = relativeFrame.origin.y + relativeFrame.size.height + padding.top
            
        default:
            layoutFrame.origin.x = relativeFrame.origin.x
        }
        
        // Horizontal Alignment
        switch (horizontalAlignment)
        {
        case .Left:
            layoutFrame.origin.x = relativeFrame.origin.x + padding.left
            
        case .Right:
            layoutFrame.origin.x = relativeFrame.origin.x + relativeFrame.size.width - width - padding.right
            
        case .ExactLeft:
            layoutFrame.origin.x = relativeFrame.origin.x
            
        case .ExactRight:
            layoutFrame.origin.x = relativeFrame.origin.x + relativeFrame.size.width - width
            
        case .HCenter:
            layoutFrame.origin.x = (relativeFrame.origin.x + relativeFrame.size.width / 2.0 - width / 2.0) + padding.left - padding.right
            
        case .ExactHCenter:
            layoutFrame.origin.x = (relativeFrame.origin.x + relativeFrame.size.width / 2.0 - width / 2.0)
            
        default:
            layoutFrame.origin.x = layoutFrame.origin.x
        }
        
        // Vertical Alignment
        switch (verticalAlignment)
        {
        case .VCenter:
            layoutFrame.origin.y = (relativeFrame.origin.y + relativeFrame.size.height / 2.0 - height / 2.0) + padding.left - padding.bottom
            
        case .ExactVCenter:
            layoutFrame.origin.y = (relativeFrame.origin.y + relativeFrame.size.height / 2.0 - height / 2.0)
            
        case .Top:
            layoutFrame.origin.y = relativeFrame.origin.y + padding.top
            
        case .Bottom:
            layoutFrame.origin.y = relativeFrame.origin.y + relativeFrame.size.height - height - padding.bottom
            
        case .ExactTop:
            layoutFrame.origin.y = relativeFrame.origin.y
            
        case .ExactBottom:
            layoutFrame.origin.y = relativeFrame.origin.y + relativeFrame.size.height - height
            
        default:
            layoutFrame.origin.y = layoutFrame.origin.y
        }
        
        return layoutFrame;
    }
    
    // Round off the coordinate and size to ensure picel perfect rendering
    class private func roundFrame(#frame: CGRect) -> CGRect
    {
        var layoutFrame = frame
        
        layoutFrame.origin.x = CGFloat(roundf(Float(frame.origin.x)))
        layoutFrame.origin.y = CGFloat(roundf(Float(frame.origin.y)))
        layoutFrame.size.width = CGFloat(roundf(Float(frame.size.width)))
        layoutFrame.size.height = CGFloat(roundf(Float(frame.size.height)))
        
        return layoutFrame
    }
}