//
//  ScanViewController.swift
//  HGCApp
//
//  Created by Surendra  on 23/07/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

protocol ScanViewControllerDelegate : class {
    func scanViewControllerDidCancel(_ vc:ScanViewController)
    func scanViewControllerDidScan(_ vc:ScanViewController, results: [String])
}

class ScanViewController: UIViewController {

    var message:String?

    @IBOutlet weak var scanView : UIView!
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var errorLabel : UILabel!
    
    var scanner: MTBBarcodeScanner?
    weak var delegate : ScanViewControllerDelegate?
    
    static func getInstance() -> ScanViewController {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "scanViewController") as! ScanViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.errorLabel.font = Font.regularFont(12.0)
        self.errorLabel.textColor = UIColor.red
        scanner = MTBBarcodeScanner(previewView: self.scanView)
        
        if let m = message {
            self.captionLabel.text = m
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.scan()
    }
    
    func stopScan() {
        self.scanner?.stopScanning()
    }
    
    func scan() {
        self.errorLabel.isHidden = true
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            var results = [String]()
                            for code in codes {
                                let stringValue = code.stringValue!
                                #if DEBUG
                                Logger.instance.log(message: stringValue, event: .d)
                                #endif
                                results.append(stringValue)
                            }
                            if !results.isEmpty {
                                self.delegate?.scanViewControllerDidScan(self, results: results)
                            }
                        }
                    })
                } catch {
                    self.stopWithMessage(NSLocalizedString("Unable to start scanning", comment: ""))
                }
            } else {
                self.stopWithMessage(NSLocalizedString("Don't have camera permissions", comment: ""))
            }
        })
    }
    
    @IBAction func handleTapOnCancel() {
        self.stopScan()
        self.delegate?.scanViewControllerDidCancel(self)
    }
    
    func stopWithMessage(_ message:String?) {
        self.errorLabel.isHidden = false
        self.errorLabel.text = message
        self.stopScan()
    }

}
