//
//  ViewFrameKeyboardInsetController.swift
//  MyTraps
//
//  Created by Cole Herzog on 5/23/16.
//  Copyright © 2016 Spensa Technologies. All rights reserved.
//

import UIKit

@objc class ViewFrameKeyboardInsetController: NSObject, MTKeyboardInsetController {
    fileprivate(set) var observing: Bool = false
    let observedView: UIView
    let anchorView: UIView
    
    fileprivate var oldFrame: CGRect?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func endObserving() {
        if !observing {
            return
        }
    
        observing = false
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        oldFrame = self.observedView.frame
        
        handleKeyboardWillTransitionToSize(notification)
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).handleKeyboardWillTransitionToSize(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let info = notification.userInfo,
            let frame = oldFrame,
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animate(withDuration: animationDuration, animations: {
                self.observedView.frame = frame
            })
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func handleKeyboardWillTransitionToSize(_ notification: Notification) {
        if let info = notification.userInfo,
            let kbFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            let yValue = kbFrame.height
            let anchorFrame = anchorView.frame
            let maxAnchorY = observedView.bounds.height - anchorFrame.maxY // window coordinates
            
            var frame = self.observedView.frame
            frame.origin.y = min(0, maxAnchorY - yValue)
            UIView.animate(withDuration: animationDuration, animations: { 
                self.observedView.frame = frame
            })
        }
    }
}

protocol MTKeyboardInsetController: class {
    func beginObserving()
    func endObserving()
    func handleKeyboardWillTransitionToSize(_ notification: Notification)
}

