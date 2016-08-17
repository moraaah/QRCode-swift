//
//  ViewController.swift
//  QRCode
//
//  Created by Lidear on 16/6/20.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {

    var scanRectView: UIView!
    var device: AVCaptureDevice!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureMetadataOutput!
    var session: AVCaptureSession!
    var preview: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action:#selector(saoyisao) )
        
    }

    func saoyisao() {
        do {
            self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            self.input = try AVCaptureDeviceInput(device: device)
            self.output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            self.session = AVCaptureSession()
            if UIScreen.mainScreen().bounds.size.height < 500 {
                self.session.sessionPreset = AVCaptureSessionPreset640x480
            } else {
                self.session.sessionPreset = AVCaptureSessionPresetHigh
            }
            self.session.addInput(self.input)
            self.session.addOutput(self.output)
            self.output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            //计算中间可探测区域
            let windowSize:CGSize = UIScreen.mainScreen().bounds.size
            let scanSize:CGSize = CGSizeMake(windowSize.width*3/4, windowSize.height*3/4)
            var scanRect:CGRect = CGRectMake((windowSize.width - scanSize.width)/2, (windowSize.height - scanSize.height)/2, scanSize.width, scanSize.height)
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRectMake(scanRect.origin.y/windowSize.height, scanRect.origin.x/windowSize.width, scanRect.size.height/windowSize.height, scanRect.size.width/windowSize.width)
            //设置可探测区域
            self.output.rectOfInterest = scanRect
            self.preview = AVCaptureVideoPreviewLayer(session: self.session)
            self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.preview.frame = UIScreen.mainScreen().bounds
            self.view.layer.insertSublayer(self.preview, atIndex: 0)
            //添加中间的探测区域绿框
            self.scanRectView = UIView()
            self.view.addSubview(self.scanRectView)
            self.scanRectView.frame = CGRectMake(0, 0, scanSize.width, scanSize.height)
            self.scanRectView.center = CGPointMake(CGRectGetMidX(UIScreen.mainScreen().bounds), CGRectGetMidY(UIScreen.mainScreen().bounds))
            self.scanRectView.layer.borderColor = UIColor.greenColor().CGColor
            self.scanRectView.layer.borderWidth = 1
            //开始捕获
            self.session.startRunning()
            
        } catch _ as NSError {
            let alert = UIAlertView(title: "提醒", message: "请在iphone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机", delegate: self, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var stringValue: String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            if stringValue != nil {
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
//        let alert = UIAlertView(title: "二维码", message: stringValue, delegate: self, cancelButtonTitle: "确定")
//        alert.show()
    }
    
//    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
//        self.session.startRunning()
//    }
    

}

