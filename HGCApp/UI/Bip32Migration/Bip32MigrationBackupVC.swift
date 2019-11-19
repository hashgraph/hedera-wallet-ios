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

class Bip32MigrationBackupVC: UIViewController {
    @IBOutlet weak var backupPhraseLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var accountIDTextFiled:UITextField!
    @IBOutlet weak var accountIDCaptionLabel : UILabel!

    weak var delegate:Bip32MigrationDelegate!

    var newEntropy:HGCSeed!
    static func getInstance(delegate:Bip32MigrationDelegate) -> Bip32MigrationBackupVC {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "bip32MigrationBackupVC") as! Bip32MigrationBackupVC
        vc.delegate = delegate
        vc.newEntropy = HGCSeed.init(entropy: CryptoUtils.secureRandomBytes(length: 32))!
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.backupPhraseLabel.textColor = Color.primaryTextColor()
        self.backupPhraseLabel.font = Font.regularFontLarge()
        HGCStyle.regularCaptionLabel(accountIDCaptionLabel)
        accountIDTextFiled.keyboardType = .default
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()
        
        let words = newEntropy.toBIP39Words()!.joined(separator: "    ")
       
        backupPhraseLabel.text = words + "\n\n" + "Account ID: " + delegate.accountID.stringRepresentation()
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCopyButtonTap() {
        let words = newEntropy.toBIP39Words()!
        let s = words.joined(separator: " ")
        Globals.copyString(s)
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message:NSLocalizedString("Recovery phrase is copied successfully.", comment: ""))
    }
    
    @IBAction func onConfirmButtonTap() {
        if let enteredAccountID = HGCAccountID.init(from: accountIDTextFiled.text) {
            let accID = delegate.accountID
            if accID == enteredAccountID {
                let vc = Bip32MigrationConfirmVC.getInstance(newEntropy: newEntropy, delegate: delegate)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                Globals.showGenericErrorAlert(title: "", message: "Account ID did not match")
            }
        } else {
            Globals.showGenericErrorAlert(title: "", message: "Please enter a valid Account ID")
        }
    }

}
