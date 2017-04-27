//
//  CameraButton.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/26/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class CameraButton: MaterialButton {
    
    var pulseLayer: CAShapeLayer!
    var lastUpdated = Date.init()
    let LABEL_CHANGE_THRESHOLD: Double = 1.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if pulseLayer == nil {
            pulseLayer = CAShapeLayer()
            pulseLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0.5*bounds.size.width).cgPath
            pulseLayer.fillColor = UIColor.white.cgColor
            pulseLayer.opacity = 0.0
            layer.insertSublayer(pulseLayer, at: 2)
        }
    }
    
    func animatePress(detectionActive: Bool, onComplete: ((Void) -> Swift.Void)? = nil) {
        ripple(detectionActive: detectionActive)
        shrinkAndGrow(onComplete: onComplete)
        pulse(detectionActive: detectionActive)
        if(detectionActive) {
            updateLable(to: "🐵", overrideTimeCheck: true)
        } else {
            updateLable(to: "🙈", overrideTimeCheck: true)
        }
    }
    
    func ripple(detectionActive: Bool) {
        
        let animation = CABasicAnimation(keyPath: "transform")
        
        if(detectionActive) {
            animation.fromValue = CATransform3DMakeScale(0.0, 0.0, 1.0)
            animation.toValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.rippleLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        } else {
            animation.toValue = CATransform3DMakeScale(0.0, 0.0, 1.0)
            animation.fromValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.rippleLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        }
        animation.repeatCount = 1
        animation.duration = 0.2
        
        rippleLayer.add(animation, forKey: "transform")
    }
    
    func pulse(detectionActive: Bool) {
        if(detectionActive) {
            let animation = CABasicAnimation(keyPath: "opacity")

            animation.fromValue = 0.0
            animation.toValue = 0.9
            
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.duration = 0.4
            
            pulseLayer.add(animation, forKey: "opacity")
        } else {
            pulseLayer.removeAllAnimations()
        }
    }
    
    func updateLable(to newLabel: String, overrideTimeCheck: Bool = false) {
        let diff: Double = -lastUpdated.timeIntervalSinceNow
        if(overrideTimeCheck || diff > LABEL_CHANGE_THRESHOLD) {
            if self.title(for: .normal) == newLabel {
                return
            }
            lastUpdated = Date.init()
            DispatchQueue.main.async {
                UIView.transition(with: self.titleLabel!, duration: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.setTitle(newLabel, for: .normal)
                }, completion: nil)
            }
        }
        
    }

}
