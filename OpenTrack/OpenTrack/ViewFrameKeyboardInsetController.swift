//
//  ViewFrameKeyboardInsetController.swift
//  MyTraps
//
//  Created by Jacob Rhoda on 5/23/16.
//  Copyright © 2016 Spensa Technologies. All rights reserved.
//

import UIKit

@objc class ViewFrameKeyboardInsetController: NSObject, MTKeyboardInsetController {
    private(set) var observing: Bool = false
    let observedView: UIView
    let anchorView: UIView
    
    private var oldFrame: CGRect?
    
    /// This assumes anchorView is a direct descendant of view.
    required init(view: UIView, anchorView: UIView) {
        observedView = view
        self.anchorView = anchorView
        super.init()
    }
    
    deinit {
        endObserving()
    }
    
    func beginObserving() {
        if observing {
            return
        }
    
        observing = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.dynamicType.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func endObserving() {
        if !observing {
            return
        }
    
        observing = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        oldFrame = self.observedView.frame
        
        handleKeyboardWillTransitionToSize(notification)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.dynamicType.handleKeyboardWillTransitionToSize(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.dynamicType.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo,
            frame = oldFrame,
            animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animateWithDuration(animationDuration, animations: {
                self.observedView.frame = frame
            })
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.dynamicType.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func handleKeyboardWillTransitionToSize(notification: NSNotification) {
        if let info = notification.userInfo,
            kbFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            let yValue = kbFrame.height
            let anchorFrame = anchorView.frame
            let maxAnchorY = observedView.bounds.height - anchorFrame.maxY // window coordinates
            
            var frame = self.observedView.frame
            frame.origin.y = min(0, maxAnchorY - yValue)
            UIView.animateWithDuration(animationDuration, animations: { 
                self.observedView.frame = frame
            })
        }
    }
}

protocol MTKeyboardInsetController: class {
    func beginObserving()
    func endObserving()
    func handleKeyboardWillTransitionToSize(notification: NSNotification)
}

