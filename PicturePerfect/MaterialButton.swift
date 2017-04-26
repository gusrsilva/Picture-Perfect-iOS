//
//  CameraButton.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/15/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    var shadowLayer: CAShapeLayer!
    var rippleLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0.5*bounds.size.width).cgPath
            shadowLayer.fillColor = backgroundColor?.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 5.0, height: 5.0)
            shadowLayer.shadowOpacity = 0.25
            shadowLayer.shadowRadius = 5
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        if rippleLayer == nil {
            rippleLayer = CAShapeLayer()
            rippleLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0.5*bounds.size.width).cgPath
            rippleLayer.bounds = bounds
            rippleLayer.frame = bounds
            rippleLayer.fillColor = tintColor.cgColor
            rippleLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
            layer.insertSublayer(rippleLayer, at: 1)
        }
    }
    
    func animatePress(onComplete: ((Void) -> Swift.Void)? = nil) {
        ripple()
        shrinkAndGrow(onComplete: onComplete)
    }
    
    func ripple() {
        // Create a blank animation using the keyPath "cornerRadius", the property we want to animate
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = CATransform3DMakeScale(0.2, 0.2, 1.0)
        animation.toValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
        animation.repeatCount = 1
        animation.duration = 0.3
        
        rippleLayer.add(animation, forKey: "transform")
    }
    
    func shrinkAndGrow(onComplete: ((Void) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.transform = CGAffineTransform.identity
                            if let onComplete = onComplete {
                                onComplete()
                            }
                        }
                        
        })
    }
}
