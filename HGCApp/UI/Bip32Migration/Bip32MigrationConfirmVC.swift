//
//  Bip32MigrationConfirmVC.swift
//  HGCApp
//
//  Created by Surendra on 06/06/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class Bip32MigrationConfirmVC: UIViewController {

    @IBOutlet weak var messageLabel : UILabel!
    var newEntropy:HGCSeed!
    weak var delegate:Bip32MigrationDelegate!
    
    static func getInstance(newEntropy:HGCSeed, delegate:Bip32MigrationDelegate!) -> Bip32MigrationConfirmVC {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "bip32MigrationConfirmVC") as! Bip32MigrationConfirmVC
        vc.newEntropy = newEntropy
        vc.delegate = delegate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()
        startMigration()
    }
    
    func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    func startMigration() {
        let op = MigrateToBip32Operation.init(oldKey:delegate.oldKey, newKey:EDBip32KeyChain.init(hgcSeed: newEntropy!).key(at: 0) , accountID: delegate.accountID)
        op.completionBlock = {
            DispatchQueue.main.async {
                switch op.mStatus {
                case .success:
                    Globals.showGenericAlert(title: NSLocalizedString("BIP32_MIGRATION_SUCCESS_ALERT_TITLE", comment: ""), message: String(format: NSLocalizedString("BIP32_MIGRATION_SUCCESS_ALERT_BODY", comment: ""), self.delegate.accountID.stringRepresentation()), handler: { (action) in
                        self.delegate.bip32MigrationSuccessful(self.newEntropy, op.accountID)
                    })
                case .failedNetwork, .failedVerfiyKeyUpdate, .failedConsensus, .failedUpdate:
                    self.pushErrorPage()
                break
               
                }
            }
        }
        BaseOperation.operationQueue.addOperation(op)
    }
    
    func pushErrorPage() {
        let vc = Bip32MigrationErrorVC.getInstance(newEntropy: newEntropy, delegate: delegate)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
