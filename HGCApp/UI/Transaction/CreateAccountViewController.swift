//
//  CreateAccountViewController.swift
//  HGCApp
//
//  Created by Surendra on 27/07/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreateAccountViewModel {
    var fromAccount : HGCAccount
    var accountName:String = ""
    var publicKeyString:String = ""
    var fee : UInt64 = 0
    var amountHBar : String = "1.0"
    var isNewSelected = false
    var notes:String = ""
    
    init(fromAccount:HGCAccount) {
        self.fromAccount = fromAccount
    }

    var publicKey:HGCPublickKeyAddress? {
        return HGCPublickKeyAddress.init(from: publicKeyString)
    }

    var amount:Int64? {
        get {
            if let hBar = Double(amountHBar) {
                return hBar.toTinyBar()
            }
            return nil
        }
        set {
            if let val = newValue {
                self.amountHBar = val.toHBar().formatHGCShort()
            } else {
                self.amountHBar = ""
            }
        }
    }


    func parseQR(_ results:[String]) throws {
        var requestParams : CreateAccountRequestParams? = nil
        for code in results {
            if let parser = CreateAccountRequestParams.init(qrCode: code) {
                requestParams = parser
                break;
            }
        }

        if let params = requestParams {
            accountName = ""
            publicKeyString = params.publicKey.stringRepresentation()
            if (params.initialAmount != nil && params.initialAmount! > 0) {
                amount = params.initialAmount
            }

        } else {
            throw NSLocalizedString("Invalid QR Code", comment: "")
        }
    }

    func validateParams() -> String? {
        var error : String?

        if fromAccount.accountID() == nil {
            error = NSLocalizedString("From account is not lnked", comment: "")

        } else if publicKey == nil {
            error = NSLocalizedString("Invalid public key", comment: "")

        } else if amount == nil || amount! <= 0 {
            error = NSLocalizedString("Invalid amount", comment: "")

        }
        return error
    }
}

class CreateAccountViewController: UITableViewController {

    private static let rowIndexFrom = 0
    private static let rowIndexTo = 1
    private static let rowIndexNotes = 2
    private static let rowIndexAmount = 3
    private static let rowIndexFee = 4
    private static let rowIndexInfo = 5
    private static let rowIndexPay = 6

    var model : CreateAccountViewModel!
    var queue = OperationQueue.init()

    static func getInstance(_ model:CreateAccountViewModel) -> CreateAccountViewController {
        let vc = CreateAccountViewController.init(style: .plain)
        vc.model = model
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = NSLocalizedString("Create Account", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.tableView.register(UINib.init(nibName: "PublicKeyInputCell", bundle: nil), forCellReuseIdentifier: "publicKeyInputCell")
        self.tableView.register(UINib.init(nibName: "AddressOptionsTableCell", bundle: nil), forCellReuseIdentifier: "AddressOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: nil), forCellReuseIdentifier: "AmountTableViewCell")
        self.tableView.register(UINib.init(nibName: "ActionButtonTableCell", bundle: nil), forCellReuseIdentifier: "ActionButtonTableCell")
        self.tableView.register(UINib.init(nibName: "FeeTableCell", bundle: nil), forCellReuseIdentifier: "FeeTableCell")
        self.tableView.register(UINib.init(nibName: "MyAddressTableCell", bundle: nil), forCellReuseIdentifier: "MyAddressTableCell")
        self.tableView.register(UINib.init(nibName: "InfoTableCell", bundle: nil), forCellReuseIdentifier: "InfoTableCell")
        self.tableView.register(UINib.init(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        
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
        model.fee = AppConfigService.defaultService.fee
    }

    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

    func onFromAccountChangeButtonTap() {
        let vc = AccountListViewController.getInstance()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func onPublicKeyChangeButtonTap() {
        model.publicKeyString = ""
        model.accountName = ""
        model.isNewSelected = false
        reloadUI()
    }

    func onPayButtonTap() {
        self.view.endEditing(true)

        if let error = model.validateParams() {
            Globals.showGenericAlert(title: error, message: "")
            return
        }

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let op = CreateAccountOperation.init(params: CreateAccountParams.init(publicKey: model.publicKey!, amount: UInt64(model.amount!), memo:model.notes, fee: model.fee), fromAccount: model.fromAccount)
        op.completionBlock = {
            OperationQueue.main.addOperation({
                self.hideHud(hud)
                if let err = op.errorMessage {
                    self.onFail(err, nil)
                } else {
                    self.onTransactionSuccess(newAccountID: op.accountID!)
                }
            })
        }
        queue.addOperation(op)
    }

    func onTransactionSuccess(newAccountID:HGCAccountID) {
        Globals.showGenericAlert(title: NSLocalizedString("Account created successfully", comment: ""), message: "Your new account ID is: " + newAccountID.stringRepresentation())
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

extension CreateAccountViewController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case CreateAccountViewController.rowIndexFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAddressTableCell", for: indexPath) as! MyAddressTableCell
            cell.delegate = self
            cell.captionLabel.text = NSLocalizedString("FROM", comment: "")
            cell.setAccount(model.fromAccount)
            return cell

        case CreateAccountViewController.rowIndexTo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "publicKeyInputCell", for: indexPath) as! PublicKeyInputCell
            cell.delegate = self
            cell.keyTextField.text = model.publicKeyString
            return cell

        case CreateAccountViewController.rowIndexAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableCell", for: indexPath) as! FeeTableCell
            cell.feeLabel.setAmount(Int64(model.amount!))
            cell.feeCaptionLabel.text = NSLocalizedString("INITIAL AMOUNT", comment: "")
            return cell
            
        case CreateAccountViewController.rowIndexNotes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            cell.delegate = self
            cell.textView.text = model.notes
            return cell

        case CreateAccountViewController.rowIndexFee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableCell", for: indexPath) as! FeeTableCell
            cell.feeLabel.setAmount(Int64(model.fee))
            return cell

        case CreateAccountViewController.rowIndexInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableCell", for: indexPath) as! InfoTableCell
            cell.messageLable.text = NSLocalizedString("Account AutoRenew Period is 3 months", comment: "")
            return cell

        case CreateAccountViewController.rowIndexPay:
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

extension CreateAccountViewController : AccountPickerDelegate {
    func accountPickerDidPickAccount(_ picker: AccountListViewController, accont: HGCAccount) {
        self.navigationController?.popToViewController(self, animated: true)
        model.fromAccount = accont
        self.reloadUI()
    }
}

extension CreateAccountViewController : AmountTableViewCellDelegate {
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, nanaoCoins: Int64) {}
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, textField: UITextField, text: String) {
        if textField == cell.hgcTextField {
            model.amountHBar = text
        } else {
           // model.amountUSD = text
        }
    }

    func amountTableViewCellDidEndEditing(_ cell: AmountTableViewCell) {
        updateFee()
        self.reloadUI()
    }
}

extension CreateAccountViewController : PublicKeyInputCellDelegate {
    func publicKeyInputCellDidTapActionButton(_ cell: PublicKeyInputCell) {
        let vc = ScanViewController.getInstance()
        vc.navigationItem.hidesBackButton = true
        vc.title = NSLocalizedString("Scan QR Code", comment: "")
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func publicKeyInputCellDidChange(_ cell: PublicKeyInputCell, publicKey: String) {
        model.publicKeyString = publicKey
    }
}

extension CreateAccountViewController : ActionButtonTableCellDelegate {
    func actionButtonCellDidTapActionButton(_ cell: ActionButtonTableCell) {
        self.onPayButtonTap()
    }
}

extension CreateAccountViewController : ScanViewControllerDelegate {
    func scanViewControllerDidCancel(_ vc: ScanViewController) {
        self.navigationController?.popViewController(animated: true)
    }

    func scanViewControllerDidScan(_ vc: ScanViewController, results: [String]) {
        do {
            try model.parseQR(results)
            model.isNewSelected = true
            self.navigationController?.popToViewController(self, animated: true)

        } catch {
            Globals.showGenericAlert(title:error as? String, message: nil)
        }
        self.reloadUI()
    }
}

extension CreateAccountViewController : MyAddressTableCellDelegate {
    func myAddressTableCellDidTapOnActionButton(_ cell: MyAddressTableCell) {
        self.onFromAccountChangeButtonTap()
    }
}

extension CreateAccountViewController : NotesTableViewCellDelegate {
    func notesTableViewCellShouldUpdateNewText(_ cell: NotesTableViewCell, text: String) -> Bool {
        return text.utf8.count <= maxAllowedMemoLength
    }
    
    func notesTableViewCellDidChange(_ cell: NotesTableViewCell, text: String) {
        model.notes = text
    }
}
