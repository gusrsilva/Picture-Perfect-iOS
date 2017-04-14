//
//  ViewController.swift
//  PicturePerfect
//
//  Created by Gus Silva on 4/12/17.
//  Copyright © 2017 Gus Silva. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileVision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var faceDetector: GMVDetector?
    var videoDataOutput = AVCaptureVideoDataOutput()
    var videoDataOutputQueue: DispatchQueue?
    var imageSet: Bool = false
    
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
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var previewHolder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium
        
        updateCameraSelection()
        setupVideoProcessing()
        setupCameraPreview()
        // TODO: Add GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all to options
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: [GMVDetectorFaceTrackingEnabled: true, GMVDetectorFaceMinSize: 0.3])
        self.imageView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            // students need to add write this part
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            selectedImage = UIImage(data: photoData!)!
            //            toggleUI(isInPreviewMode: true)
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if let buffer = sampleBuffer {
            //            let image: UIImage = GMVUtility.sampleBufferTo32RGBA(buffer)
            
            let myPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let myCIimage         = CIImage(cvPixelBuffer: myPixelBuffer!)
            let image        = UIImage(ciImage: myCIimage)
            
            let devicePosition: AVCaptureDevicePosition = AVCaptureDevicePosition.front // TODO: Update when switching is added
            let deviceOrientation: UIDeviceOrientation = UIDeviceOrientation.portrait
            let orientation: GMVImageOrientation = GMVUtility.imageOrientation(from: deviceOrientation, with: devicePosition, defaultDeviceOrientation: deviceOrientation)
            let options = [GMVDetectorImageOrientation: orientation]
            if let faces = self.faceDetector?.features(in: image, options: options) {
                if(faces.count > 0) {
                    print("Detected \(faces.count) faces!")
                }
            }
        } else {
            print("Error with buffer!")
        }
        
    }
    
    
    func setupVideoProcessing() {
        //        NSDictionary *rgbOutputSettings = @{
        //            (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
        //        };
        //        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
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
        //        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        //        [self.previewLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        //        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        //        CALayer *rootLayer = [self.placeHolder layer];
        //        [rootLayer setMasksToBounds:YES];
        //        [self.previewLayer setFrame:[rootLayer bounds]];
        //        [rootLayer addSublayer:self.previewLayer];
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = view.layer.frame
        self.previewHolder.layer.masksToBounds = true
        self.previewHolder.layer.addSublayer(self.previewLayer!)
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
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
        let desiredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.front // TODO: Make dynamic
        if let input = getCamera(forPositon: desiredPosition) {
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
    
    
    
}

