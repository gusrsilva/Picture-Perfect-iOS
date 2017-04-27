//
//  ViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/12/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate {
    
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!

    var videoDataOutput = AVCaptureVideoDataOutput()
    var videoDataOutputQueue: DispatchQueue?
    var imageSet: Bool = false
    
    var cameraPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.front // TODO: Update when switching is added
    var deviceOrientation: UIDeviceOrientation = UIDeviceOrientation.portrait   // TODO: Allow rotation?
    
    var detectionActive: Bool = false
    
    
    var takenImage = UIImage()
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    let photoOutput = AVCapturePhotoOutput()
    
    var cameraButtonShowingY: CGFloat = CGFloat()
    var cameraButtonHiddenY: CGFloat = CGFloat()
    var flipButtonShowingY: CGFloat = CGFloat()
    var flipButtonHiddenY: CGFloat = CGFloat()
    var optionsButtonShowingY: CGFloat = CGFloat()
    var optionsButtonHiddenY: CGFloat = CGFloat()
    
    var willAppearHandled = false
    var didAppearHandled = false
    
    var sensitivity: Int = 1
    var sensThreshCounter: Int = 0

    
    @IBOutlet weak var previewHolder: UIView!
    
    @IBOutlet weak var cameraButton: CameraButton!
    @IBOutlet weak var moreOptionsButton: MaterialButton!
    @IBOutlet weak var flipCameraButton: MaterialButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.delegate = self
        
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        updateCameraSelection()
        setupVideoProcessing()
        setupCameraPreview()
        
        initButtonAnimationParams()

    }
    
    func initButtonAnimationParams() {
        cameraButtonShowingY = self.cameraButton.frame.origin.y
        cameraButtonHiddenY = cameraButtonShowingY + 200
        flipButtonShowingY = self.flipCameraButton.frame.origin.y
        flipButtonHiddenY = flipButtonHiddenY + 800
        optionsButtonShowingY = self.moreOptionsButton.frame.origin.y
        optionsButtonHiddenY = optionsButtonShowingY + 1600
    }
    
    override func viewWillAppear(_ animated: Bool) {
        willAppearHandled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.captureSession.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        didAppearHandled = true
        slideButtonsIn()
        sensitivity = getSensitivity()
        sensThreshCounter = 0
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if(!willAppearHandled) {
            self.viewWillAppear(animated)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if(!didAppearHandled) {
            self.viewDidAppear(animated)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSensitivity() -> Int {
        let floatSens = UserDefaults.standard.float(forKey: SENSITIVITY_KEY)
        return  10 - Int(floatSens*10)
    }

    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            takenImage = UIImage(data: photoData!)!
            animatePhotoTaken()
            animatedSegue(withIdentifier: "cameraToPreview")

        } else {
            print("photoSampleBufferIsNull!")
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if(!detectionActive) {
            return
        }
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciimage = CIImage(cvImageBuffer: imageBuffer)
            let orientation = getCIDetectorImageOrientation(from: self.deviceOrientation, self.cameraPosition)
            let features = detector.features(in: ciimage, options: [CIDetectorEyeBlink: true, CIDetectorSmile: true, CIDetectorImageOrientation: orientation]) as! [CIFaceFeature]
            for f in features {
                if(f.hasSmile && !f.leftEyeClosed && !f.rightEyeClosed) {
                    if(sensThreshCounter >= sensitivity) {
                        takePhoto()
                    } else {
                        sensThreshCounter += 1
                    }
                } else {
                    updateCameraButtonHint(face: f)
                    sensThreshCounter -= 1
                    if(sensThreshCounter < 0) {
                        sensThreshCounter = 0
                    }
                }
            }
            if(features.count == 0) {
                updateCameraButtonHint(face: nil)
            }
            
        } else {
            print("Error with buffer!")
        }
        
    }
    
    func updateCameraButtonHint(face: CIFaceFeature? = nil) {
        var newLabel = "👻"
        if let f = face {
            if(f.leftEyeClosed || f.rightEyeClosed) {
                newLabel = "😵"
            } else if(f.hasSmile && (f.leftEyeClosed || f.rightEyeClosed)) {
                newLabel = "😜"
            } else if(!f.hasSmile) {
                newLabel = "☹️"
            } else {
                newLabel = "😁"
            }
        }
        cameraButton.updateLable(to: newLabel)
    }
    
    func takePhoto() {
        detectionActive = false
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func getCIDetectorImageOrientation(from deviceOrientation: UIDeviceOrientation, _ cameraPos: AVCaptureDevicePosition ) -> Int {
        
        var exifOrientation = 0
        let isUsingFrontFacingCamera: Bool = cameraPos == AVCaptureDevicePosition.front
        switch (deviceOrientation) {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = 8;
            break;
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera) {
                exifOrientation = 3;
            }
            else {
                exifOrientation = 1;
            }
            break;
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera) {
                exifOrientation = 1;
            }
            else {
                exifOrientation = 3;
            }
            break;
        default:
            exifOrientation = 6;
            break;
        }
        return exifOrientation
    }
    
    
    func setupVideoProcessing() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value:kCVPixelFormatType_32BGRA)]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        if(self.captureSession.canAddOutput(self.videoDataOutput)) {
            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
            self.captureSession.addOutput(self.videoDataOutput)
        }
        else {
            print("Failed to setup video output!")
        }
    }
    
    func setupCameraPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = view.layer.frame
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewHolder.layer.masksToBounds = true
        self.previewHolder.layer.addSublayer(self.previewLayer!)
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
//        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        self.captureSession.startRunning()
    }
    
    func updateCameraSelection() {
        
        self.captureSession.beginConfiguration()
        let oldInputs = self.captureSession.inputs
        if let inputs = oldInputs as? [AVCaptureInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        if let input = getCamera(forPositon: cameraPosition) {
            // Succeeded, set input and update connection states
            self.captureSession.addInput(input)
            
        } else {
            // Failed, restore old inputs
            if let oldInputs = oldInputs as? [AVCaptureInput] {
                for input in oldInputs {
                    self.captureSession.addInput(input)
                }
            }
        }
        if(self.captureSession.canAddOutput(photoOutput)) {
            self.captureSession.addOutput(photoOutput)
        }
        self.captureSession.commitConfiguration()
        
    }
    
    func getCamera(forPositon devicePosition:AVCaptureDevicePosition) -> AVCaptureDeviceInput? {
        if let deviceDiscoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                             mediaType: AVMediaTypeVideo,
                                                                             position: AVCaptureDevicePosition.unspecified) {
            
            // Iterate through available devices until we find the user's
            for device in deviceDiscoverySession.devices {
                // only use device if it supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    if (device.position == devicePosition) {
                        captureDevice = device
                        if let input: AVCaptureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
                            if (self.captureSession.canAddInput(input)) {
                                return input
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func animatePhotoTaken() {
        UIView.animate(withDuration: 0.2,
                       animations: {
//                        self.previewHolder.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.previewHolder.alpha = 0.5
                        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
//                            self.previewHolder.transform = CGAffineTransform.identity
                            self.previewHolder.alpha = 1.0
                        }
                        
        })
    }
    
    func slideButtonsIn() {
        self.cameraButton.frame.origin.y = self.cameraButtonHiddenY
        self.flipCameraButton.frame.origin.y = self.flipButtonHiddenY
        self.moreOptionsButton.frame.origin.y = self.optionsButtonHiddenY
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.cameraButton.frame.origin.y = self.cameraButtonShowingY
            self.flipCameraButton.frame.origin.y = self.flipButtonShowingY
            self.moreOptionsButton.frame.origin.y = self.optionsButtonShowingY
        }) { _ in
        }
    }
    
    func slideButtonsOut(onComplete: ((Void) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.cameraButton.frame.origin.y = self.cameraButtonHiddenY
            self.flipCameraButton.frame.origin.y = self.flipButtonHiddenY
            self.moreOptionsButton.frame.origin.y = self.optionsButtonHiddenY
        }) { _ in
            if let onComplete = onComplete {
                onComplete()
            }
        }
    }
    
    @IBAction func moreOptionsPressed(_ sender: MaterialButton) {
        sender.animatePress()
        animatedSegue(withIdentifier: "cameraToSettings")
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: CameraButton) {
        detectionActive = !detectionActive
        sender.animatePress(detectionActive: detectionActive)
    }
    
    @IBAction func flipCameraButtonPressed(_ sender: MaterialButton) {
        if(self.cameraPosition == AVCaptureDevicePosition.front) {
            self.cameraPosition = AVCaptureDevicePosition.back
        } else {
            self.cameraPosition = AVCaptureDevicePosition.front
        }
        sender.animatePress(onComplete: {self.updateCameraSelection()})

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewImageViewController {
            destination.imageToPreview = takenImage
        }
    }
    
    func animatedSegue(withIdentifier identifier: String) {
        DispatchQueue.main.async {
            self.slideButtonsOut { _ in
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }
}

