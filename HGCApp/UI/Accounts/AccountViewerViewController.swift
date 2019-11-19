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
import MBProgressHUD

class AccountViewerViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    private var accounts  = [HGCAccount]()
        
    static func getInstance() -> AccountViewerViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "accountViewerViewController") as! AccountViewerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Account Viewer", comment: "")
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorColor = Color.tableLineSeperatorColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-add"), style: .plain, target: self, action: #selector(onAddButtonTap))
        self.navigationItem.hidesBackButton = true
        
        updateAccounts()
        fetchBalances(accounts: accounts)
    }
    
    func updateAccounts() {
        accounts = HGCWallet.masterWallet()?.allAccounts(accountType: .external, false) ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func onAddButtonTap() {
        let vm = AddAccountViewModel.init(delegate: self)
        let vc = AddAccountViewController.getInstance(viewModel: vm)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchBalances(accounts:[HGCAccount]) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let op = UpdateBalanceOperation(accounts: accounts)
        op.completionBlock = {
            OperationQueue.main.addOperation {[weak self] in
                hud.hide(animated: true)
                if let errorMsg = op.errorMessage {
                    Globals.showGenericErrorAlert(title: "Failed to update balance", message: errorMsg)
                }
                self?.tableView.reloadData()
            }
        }
        BaseOperation.operationQueue.addOperation(op)
    }
}

extension AccountViewerViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountTableCell", for: indexPath) as! AccountTableCell
        cell.setAccount(self.accounts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = AddAccountViewModel.init(account: accounts[indexPath.row], delegate: self)
        let vc = AddAccountViewController.getInstance(viewModel: vm)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AccountViewerViewController : AddAccountViewModelDelegate {
    func onDoneButtonTap(_ vm: AddAccountViewModel) {
        navigationController?.popToViewController(self, animated: true)
        updateAccounts()
        if let account = vm.account {
            fetchBalances(accounts: [account])
        }
    }
    
    func onDeleteButtonTap(_ vc: AddAccountViewModel) {
        navigationController?.popToViewController(self, animated: true)
        updateAccounts()
    }
    
    func onCancelButtonTap(_ vc: AddAccountViewModel) {
        navigationController?.popToViewController(self, animated: true)
    }
}
