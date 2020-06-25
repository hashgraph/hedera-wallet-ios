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
import MessageUI

class NewWalletViewController: UIViewController {

    @IBOutlet weak var doneButton : UIButton!
    @IBOutlet weak var backupPhraseLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    private var sigantureAlgorith : SignatureOption!

    private var words : [String]!
    private var seed : HGCSeed!
    
    static func getInstance(_ sigantureAlgorith : SignatureOption) -> NewWalletViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "newWalletViewController") as! NewWalletViewController
        vc.sigantureAlgorith = sigantureAlgorith
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.backupPhraseLabel.textColor = Color.primaryTextColor()
        self.backupPhraseLabel.font = Font.regularFontLarge()
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()
        
        if WalletHelper.isOnboarded() {
            // [RAS FIXME]
            guard let seed = SecureAppSettings.default.getSeed() else {
                 Globals.showGenericErrorAlert(title: NSLocalizedString("Please attempt to recover your Hedera Account using the recovery phrases.", comment: ""), message: "",
                                               cancelButtonTitle: "Ok")
                onCloseButtonTap()
                return
            }
            self.seed = HGCSeed.init(entropy: seed)
            self.doneButton.removeFromSuperview();
            
        } else {
            self.seed = CryptoUtils.randomSeed()
        }
        
        words = self.seed.toBIP39Words()
        backupPhraseLabel.text = words.joined(separator: "    ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppSettings.setHasShownBip39Mnemonic()
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onCopyButtonTap() {
        let s = words.joined(separator: " ")
        Globals.copyString(s)
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message:NSLocalizedString("Recovery phrase is copied successfully.", comment: ""))
    }
    
    @IBAction func onDoneButtonTap() {
        let vc = PINSetupViewController.getInstance(.bip32, seed)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

