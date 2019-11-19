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

class TransactionDetailsViewController: UITableViewController {

    private static let rowIndexAmount = 0
    private static let rowIndexFrom = 1
    private static let rowIndexTo = 2
    private static let rowIndexNotes = 3
    private static let rowIndexFee = 4
    
    private var transaction : TransactionVO!
    
    static func getInstance(_ txn: TransactionVO) -> TransactionDetailsViewController {
        let vc = TransactionDetailsViewController.init(style: .plain)//Globals.mainStoryboard().instantiateViewController(withIdentifier: "transactionDetailsViewController") as! TransactionDetailsViewController
        vc.transaction = txn
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = NSLocalizedString("TRANSACTION DETAILS", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.tableView.register(UINib.init(nibName: "TxnDetailsAddressTableCell", bundle: nil), forCellReuseIdentifier: "TxnDetailsAddressTableCell")
        self.tableView.register(UINib.init(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        self.tableView.register(UINib.init(nibName: "BalanceTableCell", bundle: nil), forCellReuseIdentifier: "BalanceTableCell")
        self.tableView.register(UINib.init(nibName: "FeeTableCell", bundle: nil), forCellReuseIdentifier: "FeeTableCell")
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
//        if let data = self.transaction.txnID.hexadecimal() {
//            if let txnID = try? Proto_TransactionID(serializedData: data) {
//                let q = OperationQueue.init()
//                let op = TxnStatusOperation.init(txnID: txnID)
//                q.addOperation(op)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func isMyAccount(_ address: String) -> Bool {
        if let wallet = HGCWallet.masterWallet() {
            for account in wallet.allAccounts() {
                if account.publicKeyString() == address {
                    return true
                }
            }
        }
        
        return false
    }
    
    @IBAction func onFromCopyButtonTap() {
        Globals.copyString(self.transaction.fromAccountID)
    }
    
    @IBAction func onToCopyButtonTap() {
        Globals.copyString(self.transaction.toAccountID)
    }
    
    @IBAction func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TransactionDetailsViewController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == TransactionDetailsViewController.rowIndexTo && self.transaction.fromAccountID == nil {
            return 0.0
        } else if indexPath.row == TransactionDetailsViewController.rowIndexFrom && self.transaction.fromAccountID == nil {
            return 0.0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case TransactionDetailsViewController.rowIndexFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxnDetailsAddressTableCell", for: indexPath) as! TxnDetailsAddressTableCell
            cell.delegate = self
            
            cell.captionLabel.text = NSLocalizedString("FROM", comment: "")
            cell.copyButton.isHidden = false
            var fromName : String? = nil
            cell.keyLabel.text = " "
            cell.nameLabel.text = ""
            if let fromAddress = transaction.fromAccountID {
                cell.allowEditing = !self.isMyAccount(fromAddress)
                if let name = HGCContact.alias(fromAddress) {
                    fromName = name
                }
                cell.nameLabel.text = fromName
                cell.keyLabel.text = fromAddress
            }
    
            return cell
            
        case TransactionDetailsViewController.rowIndexTo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxnDetailsAddressTableCell", for: indexPath) as! TxnDetailsAddressTableCell
            cell.delegate = self
            cell.copyButton.isHidden = false
            cell.captionLabel.text = "TO"
            cell.keyLabel.text = " "
            cell.nameLabel.text = ""
            var toName : String? = nil
            if let toAddress = transaction.toAccountID {
                cell.allowEditing = !self.isMyAccount(toAddress)
                if let name = HGCContact.alias(toAddress) {
                    toName = name
                }
                
                cell.nameLabel.text = toName
                cell.keyLabel.text = toAddress
            }
            
            return cell
            
        case TransactionDetailsViewController.rowIndexAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceTableCell", for: indexPath) as! BalanceTableCell
            cell.setCoins(transaction.displayAmount())
            cell.dateTimeLabel.text = ""
            if let date = transaction.createdDate {
                cell.dateTimeLabel.text = date.toString()
                
            }
            let status : String
            switch transaction.consensus {
            case .success:
                status = NSLocalizedString("TXN_STATUS_SUCCESS", comment: "")
            case .failed:
                status = NSLocalizedString("TXN_STATUS_FAILED", comment: "")
            case .unknown:
                status = NSLocalizedString("TXN_STATUS_UNKNOWN", comment: "")
            }
            
            cell.dateTimeLabel.text = transaction.txnIDUserString() + "\n" + cell.dateTimeLabel.text! + "  status: \(status)"
            cell.setTextColor(transaction.isDebit() ? Color.positiveColor() : Color.negativeColor())
            return cell
            
        case TransactionDetailsViewController.rowIndexNotes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            cell.delegate = self
            cell.textView.text = self.transaction.note
            cell.textView.isEditable = false
            return cell
            
        case TransactionDetailsViewController.rowIndexFee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableCell", for: indexPath) as! FeeTableCell
            cell.feeLabel.setAmount(transaction.feeCharged.toHBar())
            cell.feeCaptionLabel.text = NSLocalizedString("FEE", comment: "")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
            
            return cell
        }
    }
}

extension TransactionDetailsViewController : TxnDetailsAddressTableCellDelegate {
    
    func txnAddressTableViewCellDidTapCopyButton(_ cell: TxnDetailsAddressTableCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row == TransactionDetailsViewController.rowIndexFrom {
                self.onFromCopyButtonTap()
                
            } else if indexPath.row == TransactionDetailsViewController.rowIndexTo {
                self.onToCopyButtonTap()
            }
        }
    }
    
    func txnAddressTableViewCellDidChange(_ cell: TxnDetailsAddressTableCell, name: String) {
        if !name.trim().isEmpty {
            _ = HGCContact.addAlias(name: name, address: cell.keyLabel.text!)
        }
    }
}

extension TransactionDetailsViewController : NotesTableViewCellDelegate {
    func notesTableViewCellShouldUpdateNewText(_ cell: NotesTableViewCell, text: String) -> Bool {
        return text.utf8.count <= 100
    }
    
    func notesTableViewCellDidChange(_ cell: NotesTableViewCell, text: String) {
        //self.transaction.note = text
        CoreDataManager.shared.saveContext()
    }
}
