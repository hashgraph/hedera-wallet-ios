//
//  SettingsTableViewController.swift
//  HGCApp
//
//  Created by Surendra  on 17/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var masterResetButton: HGCButton!
    @IBOutlet weak var nameCaptionLabel : UILabel!;
    @IBOutlet weak var feeCaptionLabel : UILabel!;

    @IBOutlet weak var securityCaptionLabel : UILabel!;
    @IBOutlet weak var pinButton : UIButton!;
    @IBOutlet var biometricButton : UIButton!;

    @IBOutlet weak var nameTextField : UITextField!;
    @IBOutlet weak var feeTextField : UITextField!;

    func applyHGCAmountFieldStyle(){
        let labelHgc = UILabel.init()
        labelHgc.textColor = feeTextField.textColor
        labelHgc.font = feeTextField.font
        labelHgc.text = " " + kHGCCurrencySymbol + "  "
        labelHgc.sizeToFit()
        labelHgc.frame.size.width = labelHgc.frame.size.width+10
        labelHgc.textAlignment = .center
        feeTextField.leftView = labelHgc
        feeTextField.leftViewMode = .always
        feeTextField.placeholder = "0.0"
        feeTextField.keyboardType = .default
    }

    
    static func getInstance() -> SettingsTableViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "settingsTableViewController") as! SettingsTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("PROFILE", comment: "")
        self.navigationItem.hidesBackButton = true
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
        HGCStyle.regularCaptionLabel(self.nameCaptionLabel)
        HGCStyle.regularCaptionLabel(self.feeCaptionLabel)
        HGCStyle.regularCaptionLabel(self.securityCaptionLabel)

        nameTextField.text = AppSettings.getAppUserName()
        nameTextField.placeholder = NSLocalizedString("Name account locally", comment: "")
        nameTextField.addTarget(self, action: #selector(SettingsTableViewController.onNameTextFieldValueChanged), for: UIControl.Event.editingDidEnd)
        feeTextField.text = AppConfigService.defaultService.fee.toHBar().formatForInputField()
        feeTextField.keyboardType = .default
        feeTextField.addTarget(self, action: #selector(SettingsTableViewController.onFeeTextFieldValueChanged), for: UIControl.Event.editingDidEnd)
        
        reloadSecurityUI()
        applyHGCAmountFieldStyle()
    }
    
    func reloadSecurityUI() {
        pinButton.setTitle( AppDelegate.authManager.currentAuthType() == .PIN ? NSLocalizedString("Change PIN", comment: "") : NSLocalizedString("Enable PIN", comment: ""), for: .normal)
        biometricButton.setTitle((AppDelegate.authManager.isFaceIdAvailable() ? NSLocalizedString("Enable FaceID", comment: "") : NSLocalizedString("Enable Fingerprint ID", comment: "")), for: .normal)
        biometricButton.isHidden = AppDelegate.authManager.currentAuthType() == .biometric
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.pageBackgroundColor()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView = UIView.init()
            header.backgroundView?.backgroundColor = Color.pageBackgroundColor()
            header.textLabel?.textColor = Color.primaryTextColor()
            header.textLabel?.font = Font.regularFontLarge()
        }
    }

    @IBAction func onTapResetButton(_ sender: Any) {
        let onReset = {
            do {
                try WalletHelper.resetWallet()
                AppDelegate.getInstance().switchToWelcome()

            } catch  {
                Globals.showGenericAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("There were some issues while doing wallet reset. We recommend deleting the wallet and install it again.", comment: "")) { (action) in
                    WalletHelper.quit()
                }
            }

        }
        
        Globals.showConfirmationAlert(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("You are about to perform a Master Reset on your wallet, this will remove all keys and account from this device, this will not change anything on the Network. Please save all your recovery words before this step.", comment: ""), onConfirm: {
            onReset()
            
        }, onDismiss: nil)
    }

    @IBAction func onChangePinButtonTap() {
        AppDelegate.authManager.onComplete = self.onAuthComplete
        AppDelegate.authManager.setupPIN()
    }
    
    @IBAction func onEnableBiometricButtonTap() {
        if AppDelegate.authManager.currentAuthType() != .biometric {
            AppDelegate.authManager.onComplete = self.onAuthComplete
            AppDelegate.authManager.setupBiometricAuth(animated: true)
        } else {
            Globals.showGenericErrorAlert(title: "", message:(AppDelegate.authManager.isFaceIdAvailable() ? NSLocalizedString("You already have FaceID enabled", comment: "") : NSLocalizedString("You already have Fingerprint ID enabled", comment: "")))
        }
    }
    
    func onAuthComplete(success:Bool) {
        reloadSecurityUI()
    }
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
    }
    
    @objc func onFeeTextFieldValueChanged() {
        if let s = feeTextField.text?.trim(), let fee = Double(s) {
            AppSettings.setDefaultFee(UInt64(fee.toTinyBar()))
        } else {
            Globals.showGenericAlert(title: NSLocalizedString("Couldn't save default max fee", comment: ""), message: NSLocalizedString("INVALID_FEE_MESSAGE", comment: ""))
        }
    }
    
    @objc func onNameTextFieldValueChanged() {
        AppSettings.setAppUserName(nameTextField.text!.trim())
    }
    
    
}
