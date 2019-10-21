//
//  RestoreAccountIDViewController.swift
//  HGCApp
//
//  Created by Surendra on 25/01/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit
import ActiveLabel
import MBProgressHUD

class RestoreAccountIDViewController: UIViewController {

    private var seed:HGCSeed!
    private var keyDerivation:KeyDerivation?

    @IBOutlet weak var messageLabel : ActiveLabel!
    @IBOutlet weak var textField : HGCTextField!

    static func getInstance(_ seed : HGCSeed, _ keyDerivation:KeyDerivation?) -> RestoreAccountIDViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "restoreAccountIDViewController") as! RestoreAccountIDViewController
        vc.seed = seed
        vc.keyDerivation = keyDerivation
        vc.title = NSLocalizedString("Enter Account ID", comment: "")
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.textField.placeholder = NSLocalizedString("ACCOUNTID_PLACEHOLDER", comment: "")
        textField.keyboardType = .default
        messageLabel.textColor = Color.primaryTextColor()
        messageLabel.font = Font.regularFontLarge()
        let customType = ActiveType.custom(pattern: "\\shedera portal\\b") //Looks for "supports"
        messageLabel.enabledTypes = [customType]
        messageLabel.text = NSLocalizedString("ACCOUNTID_RESTORE_MESSAGE", comment: "")
        messageLabel.customColor[customType] = Color.tintColor()
        messageLabel.customSelectedColor[customType] = Color.primaryTextColor()
        messageLabel.handleCustomTap(for: customType) {_ in
            if let url = URL(string: portalFAQRestoreAccount) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            }
        }
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDoneButtonTap() {
        if let accountID = HGCAccountID.init(from: self.textField.text?.trim()) {
            if let kd = keyDerivation {
                askForMigration(kd: kd)
            } else {
    
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                let op = DetectWalletOperation.init(entropy: seed, accountID: accountID)
                op.completionBlock = {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(hud)
                        if let kd = op.keyDerivation {
                            self.askForMigration(kd: kd)
                        } else {
                            Globals.showGenericErrorAlert(title: "Cannot restore wallet", message: op.errorMessage)
                        }
                    }
                }
                BaseOperation.operationQueue.addOperation(op)
            }
            
            
        } else {
            Globals.showGenericErrorAlert(title: "", message: NSLocalizedString("Invalid account ID", comment: ""))
        }
    }
    
    func askForMigration(kd:KeyDerivation) {
        if kd == .hgc {
            let vc = Bip32MigrationPromptVC.getInstance(delegate: self)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            onRestoreSuccess(kd, seed)
        }
    }
    
    func onRestoreSuccess(_ kd:KeyDerivation, _ hgcSeed:HGCSeed) {
        let accountID = HGCAccountID.init(from: self.textField.text?.trim())
        Globals.showGenericAlert(title: NSLocalizedString("Wallet restored successfully", comment: ""), message: "")
        let vc = PINSetupViewController.getInstance(kd, hgcSeed, accountID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RestoreAccountIDViewController : Bip32MigrationDelegate {
    func bip32MigrationRetry(_ vc: UIViewController) {
        vc.navigationController?.popToRootViewController(animated: true)
    }
    
    var oldKey: HGCKeyPairProtocol {
        return EDKeyChain.init(hgcSeed: seed).key(at: 0)
    }
    
    var accountID: HGCAccountID {
        return HGCAccountID.init(from: self.textField.text?.trim())!
    }
    
    func bip32MigrationAborted() {
        onRestoreSuccess(.hgc, seed)
    }
    
    func bip32MigrationSuccessful(_ newSeed: HGCSeed, _ accountID: HGCAccountID) {
        AppSettings.setNeedsToShownBip39Mnemonic()
        onRestoreSuccess(.bip32, newSeed)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
