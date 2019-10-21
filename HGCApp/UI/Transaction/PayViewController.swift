//
//  PayViewController.swift
//  HGCApp
//
//  Created by Surendra  on 24/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import MBProgressHUD

class PayViewController: UITableViewController {
    
    private static let rowIndexFrom = 0
    private static let rowIndexTo = 1
    private static let rowIndexAmount = 2
    private static let rowIndexOptions = 3
    private static let rowIndexNotes = 4
    private static let rowIndexFee = 5
    private static let rowIndexPay = 6
    
    var model : TransferViewModel!
    
    var qrCell : QRScanTableCell?
    var queue = OperationQueue.init()
    
    static func getInstance(model : TransferViewModel) -> PayViewController {
        let vc = PayViewController.init(style: .plain)
        vc.model = model
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = model.thirdParty ? NSLocalizedString("Pay to Third Party", comment: "") : NSLocalizedString("PAY", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.tableView.register(UINib.init(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "accountAddressTableCell")
        self.tableView.register(UINib.init(nibName: "AddressOptionsTableCell", bundle: nil), forCellReuseIdentifier: "AddressOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: nil), forCellReuseIdentifier: "AmountTableViewCell")
        self.tableView.register(UINib.init(nibName: "QRScanTableCell", bundle: nil), forCellReuseIdentifier: "QRScanTableCell")
        self.tableView.register(UINib.init(nibName: "ActionButtonTableCell", bundle: nil), forCellReuseIdentifier: "ActionButtonTableCell")
        self.tableView.register(UINib.init(nibName: "TXNOptionsTableCell", bundle: nil), forCellReuseIdentifier: "TXNOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        self.tableView.register(UINib.init(nibName: "FeeTableCell", bundle: nil), forCellReuseIdentifier: "FeeTableCell")
         self.tableView.register(UINib.init(nibName: "MyAddressTableCell", bundle: nil), forCellReuseIdentifier: "MyAddressTableCell")
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
        updateFee()
        self.reloadUI()
    }
    
    
    func reloadUI() {
        self.tableView.reloadData()
    }
    
    func updateFee() {
        //let amnt:UInt64 = UInt64(model.amount ?? 0)
        //let txn = APIRequestBuilder.requestForTransfer(fromAccount: model.fromAccount, toAccount: HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0), amount: amnt, notes: model.notes, fee: 0, forThirdParty:model.thirdParty)
        model.fee = AppConfigService.defaultService.fee
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onFromAccountChangeButtonTap() {
        let vc = AccountListViewController.getInstance()
        vc.pickeMode = true
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pickExisting() {
        let vc = ContactPicker.getInstance(model.thirdParty)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onToAccountChangeButtonTap() {
        model.toAccountID = ""
        model.toAccountName = ""
        model.toAccountHost = ""
        model.isNewSelected = false
        reloadUI()
    }
    
    func onPayButtonTap() {
        self.view.endEditing(true)
        
        if let error = model.validateParams() {
            Globals.showGenericAlert(title: error, message: "")
            return
        }
        
        if model.thirdParty {
            submitToThirdParty()
        
        } else {
            submitToHederaNode()
        }
    }
    
    func submitToHederaNode() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let param = TransferParam.init(toAccount: model.toAccount!.accountID!, amount: UInt64(model.amount!), notes: model.notes, fee: UInt64(model.fee), forThirdParty: false, toAccountName: model.toAccount?.name)
        let op = TransferOperation.init(fromAccount: model.fromAccount, param: param)
        op.completionBlock = {
            OperationQueue.main.addOperation({
                self.hideHud(hud)
                if let err = op.errorMessage {
                    self.onFail(err, nil)
                } else {
                    self.onTransferSuccess()
                }
            })
        }
        queue.addOperation(op)
    }
    
    func submitToThirdParty() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        sendToThirdParty(host: model.toAccountHost) { (error) in
            self.hideHud(hud)
            if let er = error {
                self.onFail("Error", er)
            } else {
                self.onTransferSuccess()
            }
        }
    }
    
    func sendToThirdParty(host:String, completion:@escaping ((_ error:String?) -> Void)) {
        let hostURL = ExchangeInfo.toHttpURL(host: host)!
        let txnBuilder = model.fromAccount.getTransactionBuilder()
        let param = TransferParam.init(toAccount: model.toAccount!.accountID!, amount: UInt64(model.amount!), notes: model.notes, fee: model.fee, forThirdParty: model.thirdParty)
        let txn = param.getPayload(txnBuilder)
        
        Logger.instance.log(message: "Sending transaction to" + host, event: .i)
        var request = URLRequest.init(url: hostURL)
        request.httpBody = try? txn.serializedData()
        request.timeoutInterval = 15
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if error == nil, let res = urlResponse as? HTTPURLResponse, (res.statusCode >= 200 || res.statusCode < 300) {
                    self.saveThirdPartyTxn(txn)
                    completion(nil)
                } else {
                    if let error = error {
                        Logger.instance.log(message:error.localizedDescription, event: .e)
                        completion(error.localizedDescription)
                    } else {
                        let errorMessage = "Something went wrong"
                        completion (errorMessage)
                    }
                }
            }
            
            
        }
        task.resume()
    }
    
    func saveThirdPartyTxn(_ txn:Proto_Transaction) {
        _ = model.fromAccount.createTransaction(toAccountID: model.toAccount!.accountID!, txn:txn)
        HGCContact.addAlias(name: model.toAccountName, address: model.toAccountID, host: model.toAccountHost)
    }
    
    func onTransferSuccess() {
        if let req = model.request {
            CoreDataManager.shared.mainContext.delete(req)
        }
        Globals.showGenericAlert(title: NSLocalizedString("Transaction submitted successfully", comment: ""), message: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            BalanceService.defaultService.updateBalances()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func onFail(_ title:String, _ message: String?) {
        DispatchQueue.main.async {
            Globals.showGenericErrorAlert(title: title, message: message)
        }
    }
    
    func hideHud(_ hud:MBProgressHUD) {
        DispatchQueue.main.async {
            hud.hide(animated: true)
        }
    }
}

extension PayViewController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if model.thirdParty && [PayViewController.rowIndexNotes, PayViewController.rowIndexOptions].contains(indexPath.row) {
            return 0
        }
        if !model.hasNotes && indexPath.row == PayViewController.rowIndexNotes {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case PayViewController.rowIndexFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAddressTableCell", for: indexPath) as! MyAddressTableCell
            cell.delegate = self
            cell.captionLabel.text = NSLocalizedString("FROM", comment: "")
            cell.setAccount(model.fromAccount)
            return cell
            
        case PayViewController.rowIndexTo:
            if model.isNewSelected {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
                cell.delegate = self
                cell.allowEditing = true
                cell.captionLabel.text = NSLocalizedString("TO", comment: "")
                cell.actionButton.setTitle(NSLocalizedString("CANCEL", comment: ""), for: .normal)
                cell.nameLabel.text = model.toAccountName
                cell.keyLabel.text = model.toAccountID
                cell.hostTextField.text = model.toAccountHost
                cell.hostTextField.superview?.isHidden = !model.thirdParty
                return cell
                
            } else {
                if model.isQROptionSelected {
                    if qrCell == nil {
                        qrCell = tableView.dequeueReusableCell(withIdentifier: "QRScanTableCell", for: indexPath) as? QRScanTableCell
                    }
                    
                    qrCell?.delegate = self
                    qrCell?.scan()
                    return qrCell!
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddressOptionsTableCell", for: indexPath) as! AddressOptionsTableCell
                    cell.delegate = self
                    cell.setTitle(NSLocalizedString("EXISTING", comment: ""), atIndex: 0)
                    cell.setTitle(NSLocalizedString("SCAN QR", comment: ""), atIndex: 2)
                    cell.setTitle(NSLocalizedString("NEW", comment: ""), atIndex: 1)
                    return cell
                }
                
            }
            
        case PayViewController.rowIndexAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell", for: indexPath) as! AmountTableViewCell
            cell.delegate = self
            cell.hgcTextField.text = model.amountHBar
            cell.usdTextField.text = model.amountUSD
            cell.usdTextField.isHidden = model.thirdParty
            return cell
            
        case PayViewController.rowIndexOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TXNOptionsTableCell", for: indexPath) as! TXNOptionsTableCell
            cell.delegate = self
            cell.notesSwitch.setOn(model.hasNotes, animated: false)
            return cell
            
        case PayViewController.rowIndexFee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableCell", for: indexPath) as! FeeTableCell
            cell.feeLabel.setAmount(Int64(model.fee))
            return cell
            
        case PayViewController.rowIndexNotes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            cell.delegate = self
            cell.textView.text = model.notes
            return cell
            
        case PayViewController.rowIndexPay:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonTableCell", for: indexPath) as! ActionButtonTableCell
            cell.delegate = self
            cell.setTitle(NSLocalizedString("PAY", comment: ""))
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
            
            return cell
        }
    }
}

extension PayViewController : AccountPickerDelegate {
    func accountPickerDidPickAccount(_ picker: AccountListViewController, accont: HGCAccount) {
        self.navigationController?.popToViewController(self, animated: true)
        model.fromAccount = accont
        self.reloadUI()
    }
}

extension PayViewController : AmountTableViewCellDelegate {
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, nanaoCoins: Int64) {}
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, textField: UITextField, text: String) {
        if textField == cell.hgcTextField {
            model.amountHBar = text
            model.amountUSD = cell.usdTextField.text ?? ""
        } else {
            model.amountUSD = text
            model.amountHBar = cell.hgcTextField.text ?? ""
        }
    }
    
    func amountTableViewCellDidEndEditing(_ cell: AmountTableViewCell) {
        updateFee()
        self.reloadUI()
    }
}

extension PayViewController : AddressTableViewCellDelegate {
    func addressTableViewCellDidTapCopyButton(_ cell: AddressTableViewCell) {}
    
    func addressTableViewCellDidChange(_ cell: AddressTableViewCell, name: String, address: String, host: String) {
        model.toAccountName = name
        model.toAccountID = address
        model.toAccountHost = host
    }
    
    func addressTableViewCellDidTapActionButton(_ cell: AddressTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row == PayViewController.rowIndexFrom {
                self.onFromAccountChangeButtonTap()
                
            } else if indexPath.row == PayViewController.rowIndexTo {
                self.onToAccountChangeButtonTap()
            }
        }
    }
}

extension PayViewController : AddressOptionsTableCellDelegate {
    func optionsTableViewCellDidTapatIndex(_ cell: AddressOptionsTableCell, index: Int) {
        switch index {
        case 0:
            self.pickExisting()
            
        case 1:
            model.isNewSelected = true
            self.reloadUI()
            
        case 2:
            model.isQROptionSelected = true
            self.reloadUI();
        default:
            break
        }
    }
}

extension PayViewController : ActionButtonTableCellDelegate {
    func actionButtonCellDidTapActionButton(_ cell: ActionButtonTableCell) {
        self.onPayButtonTap()
        
    }
}

extension PayViewController : TXNOptionsTableCellDelegate {
    func optionsTableCellDidChangeForNotification(_ cell: TXNOptionsTableCell, value: Bool) {
       
    }
    
    func optionsTableCellDidChangeForNotes(_ cell: TXNOptionsTableCell, value: Bool) {
        model.hasNotes = value
        self.reloadUI()
    }
}

extension PayViewController : QRScanTableCellDelegate {
    func scanTableCellDidCancel(_ cell: QRScanTableCell) {
        model.isQROptionSelected = false
        self.reloadUI()
    }
    
    func scanTableCellDidScan(_ cell: QRScanTableCell, results: [String]) {
        do {
            try model.parseQR(results)
            model.isNewSelected = true
        } catch {
            Globals.showGenericAlert(title:error as? String, message: nil)
        }

        cell.stopScan()
        model.isQROptionSelected = false
        self.reloadUI()
    }
}

extension PayViewController : NotesTableViewCellDelegate {
    func notesTableViewCellShouldUpdateNewText(_ cell: NotesTableViewCell, text: String) -> Bool {
        return text.utf8.count <= maxAllowedMemoLength
    }
    
    func notesTableViewCellDidChange(_ cell: NotesTableViewCell, text: String) {
        model.notes = text
    }
}

extension PayViewController : ContactPickerDelegate {
    func contactPickerDidPickAccount(_ picker: ContactPicker, account: HGCAccount) {
        model.toAccountID = account.accountID()?.stringRepresentation() ?? ""
        model.toAccountName = account.name ?? ""
        model.isNewSelected = true
        self.reloadUI()
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func contactPickerDidPickContact(_ picker: ContactPicker, contact: HGCContact) {
        model.toAccountID = contact.publicKeyID ?? ""
        model.toAccountName = contact.name ?? ""
        if let host = contact.host {
            model.toAccountHost = host
        }
        
        model.isNewSelected = true
        self.reloadUI()
        self.navigationController?.popToViewController(self, animated: true)
    }
}

extension PayViewController : MyAddressTableCellDelegate {
    func myAddressTableCellDidTapOnActionButton(_ cell: MyAddressTableCell) {
        self.onFromAccountChangeButtonTap()
    }
}
