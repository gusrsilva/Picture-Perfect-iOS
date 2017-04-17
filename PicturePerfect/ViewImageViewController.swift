//
//  ViewImageViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/16/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController {

    @IBOutlet weak var savedBanner: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var imageToPreview: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = imageToPreview {
            previewImageView.image = image
            previewImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            print("image is nil!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animatePress(forButton button: UIButton, onComplete: ((Void) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            button.transform = CGAffineTransform.identity
                            if let onComplete = onComplete {
                                onComplete()
                            }
                        }
                        
        })
    }
    
    func showSavedBanner() {
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.savedBanner.frame.origin.y = 0
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                            self.savedBanner.frame.origin.y = -80
                        }, completion: nil)
                        
        })
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "previewToCamera", sender: self)
    }

    @IBAction func saveToCameraRoll(_ sender: UIButton) {
        animatePress(forButton: sender) { _ in
            if let image = self.imageToPreview {
                self.showSavedBanner()
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
               print("Can't save to camera roll image is nil!")
            }
        }
    }
}
