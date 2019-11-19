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

class BackupWalletViewController: UIViewController , UITextViewDelegate {

    @IBOutlet weak var backupPhraseTextView : UITextView!
    @IBOutlet weak var messageLabel : UILabel!
    
    private var phrase : String?
    var sigantureOption : SignatureOption!
    
    static func getInstance(_ sigantureAlgorith : SignatureOption) -> BackupWalletViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "backupWalletViewController") as! BackupWalletViewController
        vc.sigantureOption = sigantureAlgorith
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.backupPhraseTextView.text = "casual echo flesh tribal run react crunch cure pair sum skip fled castle floor crunch deputy run react castle fled cruise ethnic"
        
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        
        self.title = NSLocalizedString("Restore Wallet Account", comment: "")
        self.backupPhraseTextView.textColor = Color.primaryTextColor()
        self.backupPhraseTextView.font = Font.regularFontLarge()
        let toolBar = HGCKeyboardToolBar.toolBarWithResponder(self.backupPhraseTextView)
        self.backupPhraseTextView.inputAccessoryView = toolBar
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontLarge()
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onRestoreButtonTap() {
        if let text = self.backupPhraseTextView.text {
            let words = text.trim().components(separatedBy: CharacterSet.init(charactersIn: "\n\t "))
            var cleanWords = [String]()
            for word in words {
                if word.trim().count > 0 {
                    cleanWords.append(word.trim())
                }
            }
            var optionalSeed: HGCSeed? = nil
            var keyDerivation:KeyDerivation? = nil
            if let seed  = HGCSeed.init(words: cleanWords) {
                optionalSeed = seed
                keyDerivation = .hgc
            } else if let seed  = HGCSeed.init(bip39Words: words) {
                optionalSeed = seed
            }
            
            if let seed = optionalSeed {
                let vc = RestoreAccountIDViewController.getInstance(seed, keyDerivation)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                Globals.showGenericAlert(title: NSLocalizedString("Recovery phrase is not valid", comment: ""), message: "")
            }
        }
    }
}
