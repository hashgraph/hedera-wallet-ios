//
//  Copyright 2019-2020 Hedera Hashgraph LLC
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

class RecoveryPhraseWarningViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backupPhraseLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    private var signatureAlgorithm: SignatureOption = .ED25519

    private var words: [String]!
    private var seed: HGCSeed!
    
    static func getInstance(_ signatureAlgorithm: SignatureOption) -> RecoveryPhraseWarningViewController {

        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier:
            "RecoveryPhraseWarningViewController") as! RecoveryPhraseWarningViewController
        vc.signatureAlgorithm = signatureAlgorithm
        return vc
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        view.backgroundColor = Color.pageBackgroundColor()
        backupPhraseLabel.textColor = Color.primaryTextColor()
        backupPhraseLabel.font = Font.regularFontLarge()
        messageLabel.textColor = Color.primaryTextColor()
        messageLabel.font = Font.regularFontVeryLarge()

        guard let rawSeed = SecureAppSettings.default.getSeed() else {
            // TODO: log and bail, or fix construction
            return
        }
        guard let seed = HGCSeed(entropy: rawSeed) else {
            // TODO: log and bail, or fix construction
            return
        }
        guard let words: [String] = {
            if let wallet = HGCWallet.masterWallet() {
                switch wallet.keyDerivationType {
                case .bip32: return seed.toBIP39Words()
                case .hgc: return seed.toWords()
                }
            }
            return .none
        }() else {
            // TODO: log and bail, or fix construction
            return
        }
        self.seed = seed
        self.words = words
        backupPhraseLabel.text = words.joined(separator: "    ")
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onCopyButtonTap() {
        let s = words.joined(separator: " ")
        Globals.copyString(s)
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message:
            NSLocalizedString("Recovery phrase is copied successfully.", comment: ""))
    }
    
    @IBAction func onDoneButtonTap() {
        if let wallet = HGCWallet.masterWallet() {
            wallet.didShowRecoveryPhraseWarning = true
        }
        self.navigationController?.popViewController(animated: true)
    }
}

