//
//  Bip32MigrationPromptVC.swift
//  HGCApp
//
//  Created by Surendra on 04/06/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

protocol Bip32MigrationDelegate: class {
    var oldKey:HGCKeyPairProtocol { get }
    var accountID:HGCAccountID { get }
    
    func bip32MigrationAborted()
    func bip32MigrationRetry(_ vc:UIViewController)
    func bip32MigrationSuccessful(_ newSeed:HGCSeed, _ accountID:HGCAccountID)
}

class Bip32MigrationPromptVC: UIViewController {

    @IBOutlet weak var messageLabel : UILabel!
    weak var delegate:Bip32MigrationDelegate!
    var forKeyUpdate:Bool = false
    
    static func getInstance(delegate:Bip32MigrationDelegate, forKeyUpdate:Bool = false) -> Bip32MigrationPromptVC {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "bip32MigrationPromptVC") as! Bip32MigrationPromptVC
        vc.delegate = delegate
        vc.forKeyUpdate = forKeyUpdate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()
        if forKeyUpdate {
            messageLabel.text = NSLocalizedString("UPDATE_KEY_PROMPT", comment: "")
        }
        
    }
    
    @IBAction func onNoButtonTap() {
        delegate.bip32MigrationAborted()
    }
    
    @IBAction func onYesButtonTap() {
        self.navigationController?.pushViewController(Bip32MigrationBackupVC.getInstance(delegate: delegate), animated: true)
    }
}
