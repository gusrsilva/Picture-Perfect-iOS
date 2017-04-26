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
            updateLable(to: "😁")
        } else {
            updateLable(to: "👌")
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
    
    func updateLable(to newLabel: String) {
        UIView.transition(with: self.titleLabel!, duration: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.setTitle(newLabel, for: .normal)
        }, completion: nil)
    }

}
