//
//  ViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/12/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit
import GoogleMobileVision

class ViewController: UIViewController {
    
    var faceDetector: GMVDetector?
    
    // The captured image
    var selectedImage = UIImage()
    
    // manages real time capture activity from input devices to create output media (photo/video)
    let captureSession = AVCaptureSession()
    
    // the device we are capturing media from (i.e. front camera of an iPhone 7)
    var captureDevice : AVCaptureDevice?
    
    // view that will let us preview what is being captured from the captureSession
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // Object used to capture a single photo from our capture device
    let photoOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        NSDictionary *options = @{
//            GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll),
//            GMVDetectorFaceClassificationType : @(GMVDetectorFaceClassificationAll),
//            GMVDetectorFaceTrackingEnabled : @(NO)
//        };
//        self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: [GMVDetectorFaceTrackingEnabled : true])
        
        
        captureNewSession(devicePostion: AVCaptureDevicePosition.front)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureNewSession(devicePostion: AVCaptureDevicePosition) {
        
        // remove all the inputs and stop running the session so we can
        // flip the camera (use another DeviceInput)
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        captureSession.stopRunning()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let deviceDiscoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                             mediaType: AVMediaTypeVideo,
                                                                             position: AVCaptureDevicePosition.unspecified) {
            
            // Iterate through available devices until we find the user's
            for device in deviceDiscoverySession.devices {
                // only use device if it supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    if (device.position == devicePostion) {
                        captureDevice = device
                        if captureDevice != nil {
                            do {
                                // students need to add this line
                                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                                
                                if captureSession.canAddOutput(photoOutput) {
                                    captureSession.addOutput(photoOutput)
                                }
                            }
                            catch {
                                print("error: \(error.localizedDescription)")
                            }
                            
                            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                                view.layer.addSublayer(previewLayer)
                                previewLayer.frame = view.layer.frame
                                
                                // students need to add this line
                                captureSession.startRunning()
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: AVCapturePhotoCaptureDelegate

    /// Provides the delegate a captured image in a processed format (such as JPEG).
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            // students need to add write this part
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            selectedImage = UIImage(data: photoData!)!
//            toggleUI(isInPreviewMode: true)
        }
    }


}

