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

class WalletSetupOptionsViewController: UIViewController {

    static func getInstance() -> WalletSetupOptionsViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "walletSetupOptionsViewController") as! WalletSetupOptionsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//    func askForSignatureOptions(_ onComplete:@escaping ((_ option:SignatureOption)->Void)) {
//        let alert = UIAlertController.init(title: "Signature Algorithm", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction.init(title: "ED25519", style: .default, handler: { (action) in
//            onComplete(SignatureOption.ED25519)
//        }))
//        alert.addAction(UIAlertAction.init(title: "ECDSA", style: .default, handler: { (action) in
//            onComplete(SignatureOption.ECDSA)
//        }))
//
//        alert.addAction(UIAlertAction.init(title: "RSA", style: .default, handler: { (action) in
//            onComplete(SignatureOption.RSA)
//        }))
//
//        alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: { (action) in
//
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func onNewButtonTap() {
        let vc = UserAgreementViewController.getInstance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onRestoreButtonTap() {
        let vc = UserAgreementViewController.getInstance()
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = BackupWalletViewController.getInstance(SignatureOption.ED25519)
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onAboutTap() {
        let vc = AboutViewController.getInstance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
