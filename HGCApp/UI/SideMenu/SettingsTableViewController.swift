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

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

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
