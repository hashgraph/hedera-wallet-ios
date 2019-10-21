//
//  Bip32MigrationErrorVC.swift
//  HGCApp
//
//  Created by Surendra on 17/06/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class Bip32MigrationErrorVC: UIViewController {

    @IBOutlet weak var messageLabel : UILabel!
    weak var delegate:Bip32MigrationDelegate!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var mailer = Mailer.init()
    
    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var retryButton : UIButton!
    @IBOutlet weak var helpButton : UIButton!
    
    var newEntropy:HGCSeed!

    static func getInstance(newEntropy:HGCSeed, delegate:Bip32MigrationDelegate) -> Bip32MigrationErrorVC {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "bip32MigrationErrorVC") as! Bip32MigrationErrorVC
        vc.delegate = delegate
        vc.newEntropy = newEntropy
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()
        startVerifying()
        
    }
    
    func startVerifying() {
        activityIndicator.startAnimating()
        let op = MigrateToBip32Operation.init(oldKey:delegate.oldKey, newKey: EDBip32KeyChain.init(hgcSeed: newEntropy!).key(at: 0), accountID: delegate.accountID, verifyOnly: true)
        op.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                if let strongSelf = self {
                    strongSelf.activityIndicator.stopAnimating()
                    if op.mStatus == .success {
                        Globals.showGenericAlert(title: NSLocalizedString("BIP32_MIGRATION_SUCCESS_ALERT_TITLE", comment: ""), message: String(format: NSLocalizedString("BIP32_MIGRATION_SUCCESS_ALERT_BODY", comment: ""), strongSelf.delegate.accountID.stringRepresentation()), handler: { (action) in
                            self?.delegate.bip32MigrationSuccessful(strongSelf.newEntropy, op.accountID)
                        })
                        
                    } else {
                        strongSelf.cancelButton.isHidden = true
                        strongSelf.retryButton.isHidden = false
                        strongSelf.helpButton.isHidden = false
                        strongSelf.messageLabel.text = "Couldn't verify account update"
                    }
                }
            }
        }
        BaseOperation.operationQueue.addOperation(op)
    }
    
    @IBAction func onCancelButtonTap() {
        delegate.bip32MigrationRetry(self)
    }
    
    @IBAction func onRetryButtonTap() {
        delegate.bip32MigrationRetry(self)
    }
    
    @IBAction func goToHelp() {
        mailer.emailLogs(from: self)
        /*if let url = URL(string: portalFAQRestoreAccount) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }*/
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
