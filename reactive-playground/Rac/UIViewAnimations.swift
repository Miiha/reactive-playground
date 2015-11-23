//
//  LayerAnimations.swift
//  Reactive Playground
//
//  Created by Michael Kao on 13/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import Foundation
import UIKit
import pop

extension UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 10, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 10, self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
    
    func animateColor(color: UIColor) {
        let duration = 0.5
        let initialColor = self.backgroundColor
        UIView.animateWithDuration(duration, animations: { () -> Void in
                self.backgroundColor = color
            }) { (complete) -> Void in
                UIView.animateWithDuration(duration) { () in
                    self.backgroundColor = initialColor
                }
            }
    }
}