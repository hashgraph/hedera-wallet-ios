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
import MessageUI
import ContactsUI

class TxnRequestComposer: UITableViewController {

    private static let rowIndexTo = 0
    private static let rowIndexAmount = 1
    private static let rowIndexOptions = 2
    private static let rowIndexNotes = 3
    private static let rowIndexRequest = 4
    
    var toAccount : HGCAccount?
    var fromContact : ContactVO?
    
    var amount : Int64? = 0
    var isQROptionSelected = false
    var hasNotes = false
    var notes : String = ""
    var notifRequested = false
    var isNewSelected = false

    static func getInstance() -> TxnRequestComposer {
        return TxnRequestComposer.init(style: .plain)//Globals.mainStoryboard().instantiateViewController(withIdentifier: "txnRequestComposer") as! TxnRequestComposer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "accountAddressTableCell")
        self.tableView.register(UINib.init(nibName: "AddressOptionsTableCell", bundle: nil), forCellReuseIdentifier: "AddressOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: nil), forCellReuseIdentifier: "AmountTableViewCell")
        self.tableView.register(UINib.init(nibName: "ActionButtonTableCell", bundle: nil), forCellReuseIdentifier: "ActionButtonTableCell")
        self.tableView.register(UINib.init(nibName: "TXNOptionsTableCell", bundle: nil), forCellReuseIdentifier: "TXNOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        self.tableView.register(UINib.init(nibName: "ContactInputTableCell", bundle: nil), forCellReuseIdentifier: "ContactInputTableCell")
        self.tableView.register(UINib.init(nibName: "QRPreviewTableCell", bundle: nil), forCellReuseIdentifier: "QRPreviewTableCell")
        self.tableView.register(UINib.init(nibName: "RequestOptionsTableCell", bundle: nil), forCellReuseIdentifier: "RequestOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "MyAddressTableCell", bundle: nil), forCellReuseIdentifier: "MyAddressTableCell")
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.title = NSLocalizedString("REQUEST", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.navigationItem.hidesBackButton = true
        
        self.notifRequested = AppSettings.getPrefReceiveConfirmation()
        
        if self.toAccount == nil {
            self.toAccount = HGCWallet.masterWallet()?.allAccounts().first
        }
        
        self.reloadUI()
    }

    
    func reloadUI() {
        self.tableView.reloadData()
    }
    
    func requestUrl(forQR:Bool) -> String? {
        if let accountID = self.toAccount?.accountID() {
            var txnRequestBuilder = TransferRequestParams.init(account: accountID, name: AppSettings.getAppUserName(), amount: self.amount)
            
            if  self.hasNotes && !self.notes.isEmpty {
                txnRequestBuilder.note = self.notes.trim()
            }
            txnRequestBuilder.notify = self.notifRequested
            return forQR ? txnRequestBuilder.asQRCode() : txnRequestBuilder.asURL(false).absoluteString
        }
        return nil
    }
    
    @IBAction func onChangeAccountButtonTap() {
        let vc = AccountListViewController.getInstance()
        vc.pickeMode = true
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func pickFromPhoneBook() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactNicknameKey
                ,CNContactEmailAddressesKey,CNContactPhoneNumbersKey]
        contactPicker.predicateForEnablingContact = NSPredicate(format: "(emailAddresses.@count > 0) OR (phoneNumbers.@count > 0)")
//        let predicate1 = NSPredicate(format: "(emailAddresses.@count > 0) AND (phoneNumbers.@count == 0)")
//        let predicate2 = NSPredicate(format: "(emailAddresses.@count == 0) AND (phoneNumbers.@count > 0)")
//        contactPicker.predicateForSelectionOfContact = NSCompoundPredicate.init(orPredicateWithSubpredicates: [predicate1, predicate2])
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func onSendButtonTap() {
        if let requestUrl = self.requestUrl(forQR: false) {
            if let url = URL.init(string: requestUrl) {
                let vc = UIActivityViewController.init(activityItems: [TXNRequestShareItem.init(url: url)], applicationActivities: nil)
                self.present(vc, animated: true, completion: {
                    
                })
            }
        } else {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Account is not linked", comment: ""), message: nil)
        }
    }
}

extension TxnRequestComposer : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension TxnRequestComposer : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension TxnRequestComposer : AccountPickerDelegate {
    func accountPickerDidPickAccount(_ picker: AccountListViewController, accont: HGCAccount) {
        self.navigationController?.popToViewController(self, animated: true)
        self.toAccount = accont
        self.reloadUI()
    }
}

extension TxnRequestComposer  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  self.isQROptionSelected {
            return 2
        }
        return 5
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !self.hasNotes && indexPath.row == TxnRequestComposer.rowIndexNotes {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case TxnRequestComposer.rowIndexTo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAddressTableCell", for: indexPath) as! MyAddressTableCell
            cell.delegate = self
            cell.captionLabel.text = NSLocalizedString("TO", comment: "")
            cell.setAccount(self.toAccount!)
            return cell
            
        case TxnRequestComposer.rowIndexAmount:
            if self.isQROptionSelected {
                let cell = tableView.dequeueReusableCell(withIdentifier: "QRPreviewTableCell", for: indexPath) as! QRPreviewTableCell
                cell.delegate = self
                cell.setString(self.requestUrl(forQR: true)!)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell", for: indexPath) as! AmountTableViewCell
                cell.delegate = self
                cell.hgcTextField.text = self.amount!.toHBar().description
                cell.usdTextField.text = CurrencyConverter.shared.convertTo$value(self.amount!).description
                return cell
            }
            
        case TxnRequestComposer.rowIndexOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TXNOptionsTableCell", for: indexPath) as! TXNOptionsTableCell
            cell.delegate = self
            cell.notesSwitch.setOn(self.hasNotes, animated: false)
            cell.notificationSwitch.setOn(self.notifRequested, animated: false)
            return cell
            
        case TxnRequestComposer.rowIndexNotes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            cell.delegate = self
            cell.textView.text = self.notes
            return cell
            
        case TxnRequestComposer.rowIndexRequest:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestOptionsTableCell", for: indexPath) as! RequestOptionsTableCell
            cell.delegate = self
            cell.setTitle(NSLocalizedString("QR", comment: ""), atIndex: 0)
            cell.setTitle(NSLocalizedString("SEND", comment: ""), atIndex: 1)
            //cell.setTitle("SEND", atIndex: 2)
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
            
            return cell
        }
    }
}

extension TxnRequestComposer : ContactInputTableCellDelegate {
    func contactInputTableCellDidChange(_ cell: ContactInputTableCell, text: String) {
        
        if Globals.isValidPhone(value: (text.trim())) {
            self.fromContact = ContactVO.init(phone: text.trim(), name: nil)
            
        } else if Globals.isValidEmail(testStr: (text.trim())) {
            self.fromContact = ContactVO.init(email: text.trim(), name: nil)
            
        } else {
            self.fromContact  = nil
        }
        
        self.tableView.reloadData()
    }
}

extension TxnRequestComposer : QRPreviewTableCellDelegate {
    func qrPreviewTableCellDidCancel(_ cell: QRPreviewTableCell) {
        self.isQROptionSelected = false
        self.tableView.reloadData()
    }
}

extension TxnRequestComposer : AddressOptionsTableCellDelegate {
    func optionsTableViewCellDidTapatIndex(_ cell: AddressOptionsTableCell, index: Int) {
        switch index {
        case 0:
            self.isNewSelected = false
        case 1:
            self.isNewSelected = true
        case 2:
            self.pickFromPhoneBook()
            self.isNewSelected = false
        default:
            break
        }
        self.tableView.reloadData()
    }
}

extension TxnRequestComposer : AmountTableViewCellDelegate {
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, nanaoCoins: Int64) {
        self.amount = nanaoCoins
    }
    
    func amountTableViewCellDidEndEditing(_ cell: AmountTableViewCell) { }
    
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, textField: UITextField, text: String) { }
}

extension TxnRequestComposer : TXNOptionsTableCellDelegate {
    func optionsTableCellDidChangeForNotification(_ cell: TXNOptionsTableCell, value: Bool) {
        
        
    }
    
    func optionsTableCellDidChangeForNotes(_ cell: TXNOptionsTableCell, value: Bool) {
        self.hasNotes = value
        self.reloadUI()
    }
}

extension TxnRequestComposer : NotesTableViewCellDelegate {
    func notesTableViewCellShouldUpdateNewText(_ cell: NotesTableViewCell, text: String) -> Bool {
        return text.utf8.count <= 100
    }
    
    func notesTableViewCellDidChange(_ cell: NotesTableViewCell, text: String) {
        self.notes = text
    }
}

extension TxnRequestComposer : RequestOptionsTableCellDelegate {
    func requestOptionsTableCellDidTapatIndex(_ cell: RequestOptionsTableCell, index: Int) {
        switch index {
        case 0:
            if self.requestUrl(forQR: true) == nil {
                Globals.showGenericErrorAlert(title: NSLocalizedString("Account is not linked", comment: ""), message: nil)
                
            } else {
                self.isQROptionSelected = true
                self.tableView.reloadData()
            }
            
        case 1:
            self.onSendButtonTap()
            
        default:
            break
        }
    }
}

extension TxnRequestComposer : CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let contactVO = ContactVO.init(email: "", name: contact.nickname)
        if let emailValue : CNLabeledValue = contact.emailAddresses.first {
            contactVO.email = emailValue.value as String
        }
        
        if let phoneValue : CNLabeledValue = contact.phoneNumbers.first {
            contactVO.phone = phoneValue.value.stringValue as String
        }
        
        self.fromContact = contactVO
        self.reloadUI()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
}

extension TxnRequestComposer : MyAddressTableCellDelegate {
    func myAddressTableCellDidTapOnActionButton(_ cell: MyAddressTableCell) {
        self.onChangeAccountButtonTap()
    }
    
    
}
