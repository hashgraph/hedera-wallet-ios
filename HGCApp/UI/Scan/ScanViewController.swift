//
//  Copyright 2019 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
