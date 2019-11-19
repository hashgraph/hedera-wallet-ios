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

class OverviewViewController: UIViewController {
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var noTxnLabel : UILabel!
    
    @IBOutlet weak var accountDetailContainer : UIView!
    @IBOutlet weak var accountDetailContainerHeight : NSLayoutConstraint!
    @IBOutlet weak var accountDetailToggle : UIView!
    @IBOutlet weak var toggleButton : UIButton!
    @IBOutlet weak var accountDetailToggleHeight : NSLayoutConstraint!
    var accountDetailView: AccountDetailView!
    
    private var pageVC : UIPageViewController!
    private var walletViews = [WalletView]()
    
    @IBOutlet weak var txnLoadingIndicator : UIActivityIndicatorView?

    @IBOutlet weak var pageControl : UIPageControl!
    private var accounts = [HGCAccount]()
    private var transactions = [TransactionVO]()
    
    static func getInstance() -> OverviewViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "overviewViewController") as! OverviewViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? UIPageViewController {
            self.pageVC = destVC
            self.pageVC.delegate = self
            self.pageVC.dataSource = self
        }
    }
    
    func isAllAccountSelected() -> Bool {
        if self.shouldAddAllAccounts() {
            if let vcs = pageVC.viewControllers {
                if let walletView = vcs.first as? WalletView {
                    return walletView.account == nil
                }
            }
        }
        return false
    }
    
    func shouldAddAllAccounts() -> Bool {
        if self.accounts.count > 1 {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .onAccountUpdate, object: nil, queue: OperationQueue.main) {[weak self] (notif) in
                  self?.onAccountUpdate()
        }
                      
        NotificationCenter.default.addObserver(forName: .onTransactionsUpdate, object: nil, queue: OperationQueue.main) {[weak self] (notif) in
            self?.onTransactionsUpdate()
        }
        
        NotificationCenter.default.addObserver(forName: .onTransactionsServiceStateChanged, object: nil, queue: OperationQueue.main) {[weak self] (notif) in
            self?.onTransactionServiceStateUpdate()
        }
        
        self.noTxnLabel.font = Font.lightFontSmall()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorColor = Color.tableLineSeperatorColor()
        self.accountDetailToggle.backgroundColor = Color.tableLineSeperatorColor()
        self.accountDetailView = AccountDetailView.getInstance(overviewMode: true)
        self.accountDetailContainer.addContentView(self.accountDetailView)
        self.txnLoadingIndicator?.isHidden = !TransactionService.defaultService.isRunning()
        self.reloadAccounts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onAccountChange(false)
    }
    
    func reloadAccounts() {
        guard let wallet = HGCWallet.masterWallet() else {
            return
        }
        self.accounts = wallet.allAccounts()
        self.walletViews = []
        if self.shouldAddAllAccounts() {
            let vc = WalletView.getInstance(nil)
            vc.delegate = self
            self.walletViews.append(vc)
        }
        for account in self.accounts {
            let vc = WalletView.getInstance(account)
            vc.delegate = self
            self.walletViews.append(vc)
        }
        self.pageControl.numberOfPages = self.shouldAddAllAccounts() ?  self.accounts.count+1 : self.accounts.count
        self.pageControl.currentPage = 0
        self.pageVC.setViewControllers([self.pageAtIndex(0)!], direction: .forward, animated: false, completion: nil)
        self.onAccountChange(false)
        self.showDetailConatiner(false, animated: false)
    }
    
    @objc func onNewAccountCreated() {
        self.reloadAccounts()
    }
    
    func onAccountChange(_ animated:Bool) {
        if let vcs = pageVC.viewControllers {
            if let walletView = vcs.first as? WalletView {
                if let account = walletView.account {
                     self.transactions = account.getAllTxn()
                    self.showDetailToggle(true, animated: animated)
                    self.title = account.name! + " ..." + account.publicKeyString().substringFromEnd(length: 6)
                    
                } else {
                    self.transactions = HGCRecord.allTxn(nil, CoreDataManager.shared.mainContext) ?? []
                    self.showDetailToggle(false, animated: animated)
                    self.title = "All Accounts"
                }
               self.pageControl.currentPage = Int(self.indexOfWalletView(walletView)!)
                self.tableView.reloadData()
                self.noTxnLabel.isHidden = self.transactions.count == 0 ? false : true
            }
        }
    }
    
    @objc func onAccountUpdate() {
        self.onAccountChange(false)
    }
    
    @objc func onTransactionsUpdate() {
        self.onAccountChange(false)
    }
    
    @objc func onTransactionServiceStateUpdate() {
        if  self.txnLoadingIndicator != nil {
            self.txnLoadingIndicator?.isHidden = !TransactionService.defaultService.isRunning()
        }
    }
    
    
    func pageAtIndex(_ index:Int) -> WalletView? {
        if (index > -1 && self.walletViews.count > index) {
            return self.walletViews[index]
        }
        return nil
    }
    
    func indexOfWalletView(_ paramWalletView:WalletView) -> Int? {
        var index = 0 as Int?
        for vc in self.walletViews {
            if vc == paramWalletView {
                return index
            }
            index = index! + 1
        }
        return nil
    }
    
    @IBAction func onExpandAccountButtonTap() {
        self.showDetailConatiner(!self.isDetailContainerExpanded(), animated: true)
    }
    
    func showDetailConatiner(_ expand:Bool, animated:Bool) {
        if isDetailContainerExpanded() && expand { return }
        
        self.accountDetailContainerHeight.constant = expand ? 1000 : 0
        self.toggleButton .setTitle("" , for: .normal)
        self.toggleButton.setImage(UIImage.init(named: expand ? "icon-arrow-up" : "icon-arrow-down"), for: .normal)
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.accountDetailContainer.superview?.setNeedsLayout()
                self.accountDetailContainer.superview?.layoutIfNeeded()
            })
        }
        
        if expand {
            if let vcs = pageVC.viewControllers {
                if let walletView = vcs.first as? WalletView {
                    if let account = walletView.account {
                        self.accountDetailView.setAccount(account)
                    }
                }
            }
        } else {
            self.view.endEditing(true)
        }
    }
    
    func isDetailContainerExpanded() -> Bool {
        return self.accountDetailContainerHeight.constant == 0 ? false : true
    }
    
    func showDetailToggle(_ expand:Bool, animated:Bool) {
        if isDetailToggleExpanded() && expand { return }
        
        self.accountDetailToggleHeight.constant = expand ? 20 : 0
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.accountDetailToggle.superview?.setNeedsLayout()
                self.accountDetailToggle.superview?.layoutIfNeeded()
            })
        }
    }
    
    func isDetailToggleExpanded() -> Bool {
        return self.accountDetailToggleHeight.constant == 0 ? false : true
    }
    
    deinit {
        print("OverviewViewController deinit")
    }
}

extension OverviewViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let walletView = viewController as? WalletView {
            if let index = self.indexOfWalletView(walletView) {
                return self.pageAtIndex(index - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let walletView = viewController as? WalletView {
            if let index = self.indexOfWalletView(walletView) {
                return self.pageAtIndex(index + 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.onAccountChange(true)
            self.showDetailConatiner(false, animated: true)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.showDetailConatiner(false, animated: true)
    }
}

extension OverviewViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "txnCell", for: indexPath) as! TransactionTableCell
        let txn = self.transactions[indexPath.row]
        cell.setTxn(txn)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let txn = self.transactions[indexPath.row]
        let vc = TransactionDetailsViewController.getInstance(txn)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension OverviewViewController : WalletViewDelegate {
    func walletViewDidTapOnPay(_ walletView: WalletView) {
        let model = TransferViewModel.init(fromAccount: walletView.account ?? HGCWallet.masterWallet()!.allAccounts().first!)
        let vc = PayViewController.getInstance(model:model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletViewDidTapOnRequest(_ walletView: WalletView) {
        let vc = TxnRequestComposer.getInstance()
        if let account = walletView.account {
            vc.toAccount = account
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func walletViewDidTapOnCreateAccountRequest(_ walletView: WalletView) {
        if let account = walletView.account {
            let request = CreateAccountRequestParams.init(publicKey: account.publicKeyAddress())
            let vc = QRPreviewController.getInstance(request.asQRCode())
            vc.title = NSLocalizedString("Create Account Request", comment: "")
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
