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
                        UIView.animate(withDuration: 0.1, animations: {
                            button.transform = CGAffineTransform.identity
                        }, completion: { _ in
                            if let onComplete = onComplete {
                                onComplete()
                            }
                        })
                        
        })
    }
    
    func showSavedBanner() {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.savedBanner.frame.origin.y = 0
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                            self.savedBanner.frame.origin.y = -80
                        }, completion: nil)
                        
        })
    }
    
    func saveAttemptCompleted(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            showSavedBanner()
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "previewToCamera", sender: self)
    }

    @IBAction func saveToCameraRoll(_ sender: UIButton) {
        animatePress(forButton: sender) { _ in
            if let image = self.imageToPreview {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveAttemptCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                print("Can't save to camera roll image is nil!")
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        animatePress(forButton: sender) { _ in
            if let image = self.imageToPreview {
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
