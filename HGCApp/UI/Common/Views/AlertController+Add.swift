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

var alertKey : String = "alertKey";

extension UIAlertController {
    
    var alertWindow : UIWindow? {
        set {
            objc_setAssociatedObject(self, &alertKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
        get {
            return objc_getAssociatedObject(self, &alertKey) as! UIWindow?;
        }
    }
}

extension UIAlertController {

    func showAlert() {
        self.alertWindow = UIWindow.init(frame: UIScreen.main.bounds);
        self.alertWindow?.rootViewController = UIViewController.init();
        
        self.alertWindow?.tintColor = UIApplication.shared.delegate?.window??.tintColor;
        let topWindow = UIApplication.shared.windows.last;
        self.alertWindow?.windowLevel = (topWindow?.windowLevel)! + 1;
        
        self.alertWindow?.makeKeyAndVisible();
        self.alertWindow?.rootViewController?.present(self, animated: true, completion: nil);
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        self.alertWindow?.isHidden = true;
        self.alertWindow = nil;
    }
    
    func dismissAlert() {
        weak var weakSelf = self;
        self.alertWindow?.rootViewController?.dismiss(animated: true, completion: { 
            weakSelf?.alertWindow?.isHidden = true;
            weakSelf?.alertWindow = nil;
        })
    }
    
    func isVisibleAlert() -> Bool {
        return self.alertWindow != nil;
    }
    
}


extension UIAlertController {
    class func alert(title:String? = nil, message:String? = nil) -> UIAlertController {
        return UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    }
    
    @discardableResult
    func addDismissButton(title:String? = NSLocalizedString("Dismiss", comment: ""), _ onDismiss:((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        self.addAction(UIAlertAction.init(title: title, style: .cancel, handler: onDismiss))
        return self
    }
    
    @discardableResult
    func addConfirmButton(title:String, _ onConfirm:((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        self.addAction(UIAlertAction.init(title: title, style: .default, handler: onConfirm))
        return self
    }
    
    @discardableResult
    func show(from:UIViewController?) -> UIAlertController {
        from?.present(self, animated: true, completion: nil)
        return self
    }
}
