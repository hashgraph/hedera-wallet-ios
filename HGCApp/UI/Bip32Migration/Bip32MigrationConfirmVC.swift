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
