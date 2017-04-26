//
//  FadeSegue.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/26/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    override func perform() {
        
        let window = UIApplication.shared.keyWindow!
        
        destination.view.alpha = 0.0
        window.insertSubview(destination.view, belowSubview: source.view)
        
        DispatchQueue.main.async {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.source.view.alpha = 0.0
            self.destination.view.alpha = 1.0
        }) { (finished) -> Void in
            self.source.view.alpha = 1.0
            self.source.present(self.destination, animated: false, completion: nil)
        }
        }
    }

}
