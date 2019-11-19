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

class PINSetupViewController: UIViewController {

    @IBOutlet weak var biometricIDButton : UIButton!
    private var sigantureAlgorith : SignatureOption!
    private var seed:HGCSeed!
    private var accountID: HGCAccountID?
    private var keyDerivation:KeyDerivation!
    
    static func getInstance(_ keyDerivation:KeyDerivation, _ seed:HGCSeed, _ accID:HGCAccountID? = nil) -> PINSetupViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "pinSetupViewController") as! PINSetupViewController
        vc.keyDerivation = keyDerivation
        vc.seed = seed
        vc.accountID = accID
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        if AppDelegate.authManager.isFaceIdAvailable() {
            self.biometricIDButton.setTitle(NSLocalizedString("ENABLE FACEID LOGIN", comment: ""), for: .normal)
        } else {
            self.biometricIDButton.setTitle(NSLocalizedString("ENABLE FINGERPRINT LOGIN", comment: ""), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onTouchIDButtonTap() {
        AppDelegate.authManager.onComplete = self.onAuthComplete
        AppDelegate.authManager.setupBiometricAuth(animated: true)
    }
    
    func onAuthComplete(success:Bool) {
        if success {
            if WalletHelper.onboard(keyDerivation: keyDerivation, seed: seed, accID: accountID) {
                NotificationCenter.default.post(name: WalletHelper.onboardDidSuccess, object: nil)
            }
        } else {
            
        }
    }
    
    @IBAction func onSetupPINButtonTap() {
        AppDelegate.authManager.onComplete = self.onAuthComplete
        AppDelegate.authManager.setupPIN()
    }
    
    deinit {
        AppDelegate.authManager.onComplete = nil
    }

}
