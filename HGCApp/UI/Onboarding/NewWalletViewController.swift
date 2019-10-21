//
//  NewWalletViewController.swift
//  HGCApp
//
//  Created by Surendra  on 17/12/17.
//  Copyright © 2017 HGC. All rights reserved.
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
            self.seed = HGCSeed.init(entropy: SecureAppSettings.default.getSeed()!)
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

