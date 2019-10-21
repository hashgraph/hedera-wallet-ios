//
//  AccountDetailView.swift
//  HGCApp
//
//  Created by Surendra  on 28/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol AccountDetailViewDelegate: class {
    //func accountDetailView(_ view:AccountDetailView didT)
    
}

class AccountDetailView: UIView, UITextFieldDelegate {
    weak var delegate : AccountDetailViewDelegate?
    
    @IBOutlet weak var publicKeyLabel : UILabel!
    @IBOutlet weak var privateKeyLabel : UILabel?
    @IBOutlet weak var nickNameTextField : UITextField!
    @IBOutlet weak var accountIDTextField : UITextField?
    @IBOutlet weak var hiddenSwitch : HGCSwitch?
    
    @IBOutlet weak var publicKeyCaptionLabel : UILabel!
    @IBOutlet weak var privateKeyCaptionLabel : UILabel?
    @IBOutlet weak var nameCaptionLabel : UILabel!
    @IBOutlet weak var accountIDCaptionLabel : UILabel?

    @IBOutlet var showPrivateKeyButton : UIButton!
    @IBOutlet var buttonStackView : UIStackView!

    @IBOutlet weak var privateKeyView : UIView?
    @IBOutlet weak var accountIDView : UIView?
    @IBOutlet weak var hiddenView : UIView?
    
    var showPrivateKey = false
    
    private var account: HGCAccount!
    
    static func getInstance(overviewMode:Bool = false) -> AccountDetailView {
        let view = UINib.init(nibName: "AccountDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AccountDetailView
        view.backgroundColor = Color.pageBackgroundColor()
        if overviewMode {
            view.accountIDView?.removeFromSuperview()
            view.hiddenView?.removeFromSuperview()
        }
        return view
    }
    
    override func awakeFromNib() {
        self.backgroundColor = Color.pageBackgroundColor()
        HGCStyle.regularCaptionLabel(self.publicKeyCaptionLabel)
        HGCStyle.regularCaptionLabel(self.privateKeyCaptionLabel!)
        HGCStyle.regularCaptionLabel(self.nameCaptionLabel)
        HGCStyle.regularCaptionLabel(self.accountIDCaptionLabel!)
        accountIDTextField?.keyboardType = .default
        self.hiddenSwitch?.setText(NSLocalizedString("HIDDEN", comment: ""))
        self.showPrivateKeyButton.setTitleColor(Color.secondaryTextColor(), for: .normal)
        self.showPrivateKeyButton.titleLabel?.font = Font.regularFontMedium()
        NotificationCenter.default.addObserver(self, selector: #selector(AccountDetailView.willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func onSwitchValueChange() {
        self.account.isHidden = !(self.account.isHidden)
        CoreDataManager.shared.saveContext()
        NotificationCenter.default.post(name: .onAccountUpdate, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.nickNameTextField == textField {
            let name = textField.text?.trim()
            if name != nil && !(name?.isEmpty)! {
                self.account.name = name
                CoreDataManager.shared.saveContext()
                NotificationCenter.default.post(name: .onAccountUpdate, object: nil)
            }
            
        } else if self.accountIDTextField == textField {
            if let accID = HGCAccountID.init(from: textField.text?.trim()) {
                if let exisitingAccID = self.account.accountID() {
                    if exisitingAccID != accID {
                        account.clearData()
                    }
                }
                self.account.updateAccountID(accID)
                CoreDataManager.shared.saveContext()
            } else {
                Globals.showGenericErrorAlert(title: NSLocalizedString("Invalid account ID", comment: ""), message: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func onDisplayPrivateKeyButtonTap() {
        if !self.showPrivateKey {
            let alert = UIAlertController.init(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("PRIVATE_KEY_DISPLAY_WARNING", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) in
                AppDelegate.authManager.onComplete = self.onAuthComplete
                AppDelegate.authManager.authenticate(AppDelegate.authManager.currentAuthType(), animated: true)
            }))
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil))
            alert.showAlert()
        } else {
            self.showPrivateKey = false
            self.reloadPrivateKey()
        }
    }
    
    @IBAction func onCopyButtonTap() {
        Globals.copyString(self.account.publicKeyString())
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message: NSLocalizedString("Your public key is copied successfully.", comment: ""))
    }
    
    @IBAction func onCopyAccountInfoButtonTap() {
        Globals.copyString(account.toJSONString(includePrivateKey: showPrivateKey))
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message: NSLocalizedString("Your account info is copied successfully.", comment: ""))
    }
    
    @IBAction func onCopyPrivateKeyButtonTap() {
        Globals.copyString(self.account.privateKeyString())
    }
    
    func setAccount(_ account:HGCAccount) {
        self.account = account
        self.showPrivateKey = false
        self.nickNameTextField.text = account.name ?? NSLocalizedString("Unknown", comment: "")
        if let accID = account.accountID() {
            self.accountIDTextField?.text = accID.stringRepresentation()
        }
        self.publicKeyLabel.text = account.publicKeyString()
        self.hiddenSwitch?.setOn(account.isHidden, animated: false)
        self.reloadPrivateKey()
    }
    
    func reloadPrivateKey() {
        self.privateKeyLabel?.text = self.showPrivateKey ? account.privateKeyString() : "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        
        //self.buttonStackView.removeArrangedSubview(self.copyPrivateKeyButton)
        self.buttonStackView.removeArrangedSubview(self.showPrivateKeyButton)
        //self.copyPrivateKeyButton.isHidden = !self.showPrivateKey
        
        if self.showPrivateKey {
            self.buttonStackView.addArrangedSubview(self.showPrivateKeyButton)
           // self.buttonStackView.addArrangedSubview(self.copyPrivateKeyButton)
            self.showPrivateKeyButton.setTitle(" \(NSLocalizedString("HIDE", comment: "")) ", for: .normal)
        } else {
            self.buttonStackView.addArrangedSubview(self.showPrivateKeyButton)
            self.showPrivateKeyButton.setTitle(" \(NSLocalizedString("DISPLAY", comment: "")) ", for: .normal)
        }
    }
    
    func onAuthComplete(success:Bool) {
        if success {
            self.showPrivateKey = true
            self.reloadPrivateKey()
        }
        AppDelegate.authManager.onComplete = nil
    }
    
    @objc func willResignActiveNotification() {
        self.showPrivateKey = false
        self.reloadPrivateKey()
    }
    
    deinit {
        AppDelegate.authManager.onComplete = nil
        NotificationCenter.default.removeObserver(self)
    }
}
