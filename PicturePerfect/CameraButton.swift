//
//  CameraButton.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/15/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class CameraButton: UIButton {

    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0.5*bounds.size.width).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 5.0, height: 5.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 5
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }

}
