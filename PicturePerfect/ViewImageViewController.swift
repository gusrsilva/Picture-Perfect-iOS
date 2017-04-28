//
//  ViewImageViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/16/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit
import imglyKit

class ViewImageViewController: UIViewController, PhotoEditViewControllerDelegate, CAAnimationDelegate {

    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var buttonsHolder: UIVisualEffectView!
    
    @IBOutlet weak var checkboxHolder: UIView!
    @IBOutlet weak var savedToast: UIVisualEffectView!
    @IBOutlet weak var savedToastMessage: UILabel!
    
    var imageSaved: Bool = false
    var imageToPreview: UIImage?
    var buttonsShowingY: CGFloat = CGFloat()
    var buttonsHiddenY: CGFloat = CGFloat()
    var checkMarkPathLayer = CAShapeLayer()
    var pathAnimation = CABasicAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = imageToPreview {
            previewImageView.image = image
        } else {
            print("image is nil!")
        }
        initButtonAnimationParams()
        initSavedToast()
    }
    
    func initSavedToast() {
        savedToast.clipsToBounds = true
        savedToast.layer.cornerRadius = 12
        savedToast.alpha = 0.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: checkboxHolder.bounds.maxY * 2 / 3))
        path.addLine(to: CGPoint(x: checkboxHolder.bounds.maxX / 3, y: checkboxHolder.bounds.maxY))
        path.addLine(to: CGPoint(x: checkboxHolder.bounds.maxX, y: 0))
        
        checkMarkPathLayer = CAShapeLayer()
        checkMarkPathLayer.frame = checkboxHolder.bounds
        checkMarkPathLayer.path = path.cgPath
        checkMarkPathLayer.strokeColor = UIColor.red.cgColor
        checkMarkPathLayer.fillColor = nil
        checkMarkPathLayer.lineWidth = 2
        checkMarkPathLayer.lineJoin = kCALineJoinBevel
        
        pathAnimation = CABasicAnimation(keyPath:"strokeEnd")
        pathAnimation.duration = 0.3
        pathAnimation.fromValue = NSNumber(floatLiteral: 0)
        pathAnimation.toValue = NSNumber(floatLiteral: 1)
        pathAnimation.delegate = self

    }
    
    func showSavedToast() {
        checkboxHolder.layer.addSublayer(checkMarkPathLayer)
        checkMarkPathLayer.removeAllAnimations()
        savedToast.alpha = 1.0
        checkMarkPathLayer.add(pathAnimation, forKey:"strokeEnd")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.savedToast.alpha = 0.0
            self.checkMarkPathLayer.removeFromSuperlayer()
        }
    }
    
    func initButtonAnimationParams() {
        buttonsShowingY = self.buttonsHolder.frame.origin.y
        buttonsHiddenY = buttonsShowingY + 300
    }
    
    override func viewWillAppear(_ animated: Bool) {
        slideButtonsIn()  // TODO: Add back
        if let image = imageToPreview {
            if(UserDefaults.standard.bool(forKey: AUTO_SAVE_KEY)) {
                savedToastMessage.text = "Autosaved"
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveAttemptCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func slideButtonsIn() {
        self.buttonsHolder.frame.origin.y = buttonsHiddenY
        
        UIView.animate(withDuration: 0.4, delay: 0.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.buttonsHolder.frame.origin.y = self.buttonsShowingY
        }) { _ in
        }
    }
    
    func slideButtonsOut(onComplete: ((Void) -> Swift.Void)?) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.buttonsHolder.frame.origin.y = self.buttonsHiddenY
        }) { _ in
            if let onComplete = onComplete {
                onComplete()
            }
        }
    }
    
    func saveAttemptCompleted(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            imageSaved = true
            showSavedToast()
        }
    }
    
    @IBAction func backPressed(_ sender: MaterialButton) {
        sender.animatePress()
        slideButtonsOut { _ in
            self.performSegue(withIdentifier: "previewToCamera", sender: self)
        }
    }

    @IBAction func saveToCameraRoll(_ sender: MaterialButton) {
        sender.animatePress { _ in
            if(self.imageSaved) {
                self.showSavedToast()
            }
            else if let image = self.imageToPreview {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveAttemptCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                print("Can't save to camera roll image is nil!")
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: MaterialButton) {
        sender.animatePress { _ in
            if let image = self.imageToPreview {
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func editButtonPressed(_ sender: FlatMaterialButton) {
        sender.animatePress()
        let photoEditViewController = PhotoEditViewController(photo: imageToPreview!)
        photoEditViewController.delegate = self
        
        let toolbarController = ToolbarController()
        toolbarController.push(photoEditViewController, animated: false)
        
        present(toolbarController, animated: true, completion: nil)
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        imageToPreview = image
        previewImageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    
}
