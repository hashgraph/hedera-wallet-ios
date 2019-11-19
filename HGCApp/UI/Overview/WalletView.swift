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

protocol WalletViewDelegate: class {
    func walletViewDidTapOnPay(_ walletView:WalletView)
    func walletViewDidTapOnRequest(_ walletView:WalletView)
    func walletViewDidTapOnCreateAccountRequest(_ walletView:WalletView)
}

class WalletView: UIViewController {
    @IBOutlet weak var coinBalanceLabel : UILabel!
    @IBOutlet weak var balanceLabel : UILabel!
    @IBOutlet weak var currencyLabel : UILabel!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    @IBOutlet weak var lastUpdatedAt : UILabel!
    @IBOutlet weak var requestButton : UIButton!
    @IBOutlet weak var payButton : UIButton!
    @IBOutlet weak var requestAccountIDButton : UIButton!


    weak var delegate: WalletViewDelegate?
    
    var account : HGCAccount?
    
    static func getInstance(_ account:HGCAccount?) -> WalletView {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "walletView") as! WalletView
        vc.account = account
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAccountUpdate), name: .onAccountUpdate, object: nil)
        NotificationCenter.default.addObserver(forName: .onBalanceUpdate, object: nil, queue: OperationQueue.main) { (notif) in
            self.onAccountUpdate()
        }
        NotificationCenter.default.addObserver(forName: .onBalanceServiceStateChanged, object: nil, queue: OperationQueue.main) { (notif) in
            self.onAccountUpdate()
        }
        
        coinBalanceLabel.isUserInteractionEnabled = true
        coinBalanceLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(WalletView.onBalanceLableTap)))
        
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.coinBalanceLabel.textColor = Color.primaryTextColor()
        self.coinBalanceLabel.font = Font.hgcAmountFontVeryBig()
        self.balanceLabel.textColor = Color.primaryTextColor()
        self.balanceLabel.font = Font.usdAmountFontVeryBig()
        self.currencyLabel.font = Font.regularFont(17.0)
        self.currencyLabel.text = kHGCCurrencySymbol
        self.lastUpdatedAt.textColor = Color.secondaryTextColor()
        self.lastUpdatedAt.font = Font.lightFontVerySmall()
        reloadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUI()
    }
    
    private func reloadUI() {
        var nanoCoins : Int64!
        if let acc = account {
            nanoCoins = acc.balance
        }
        
        self.coinBalanceLabel.text = nanoCoins.toHBar().formatHGCShort()
        self.balanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).formatUSD()
        loadingIndicator?.isHidden = !BalanceService.defaultService.isRunning()
        if let date = account?.lastBalanceCheck {
            self.lastUpdatedAt.text = String(format: NSLocalizedString("LAST_UPDATED_", comment: ""), date.toString())
        } else {
            self.lastUpdatedAt.text = ""
        }
        
        let hasAccountSetup = account?.accountID() != nil
        payButton.isHidden = !hasAccountSetup
        requestButton.isHidden = !hasAccountSetup
        requestAccountIDButton.isHidden = hasAccountSetup
    }
    
    @objc private func onBalanceLableTap() {
        var nanoCoins : Int64 = 0
        if let acc = account {
            nanoCoins = acc.balance
        }
        Globals.showGenericAlert(title: NSLocalizedString("HBAR", comment: ""), message: nanoCoins.toHBar().formatHGC())
    }
    
    @objc private func onAccountUpdate() {
        reloadUI()
    }
    
    @IBAction func onRequestButtonTap() {
        self.delegate?.walletViewDidTapOnRequest(self)
    }
    
    @IBAction func onPayButtonTap() {
        self.delegate?.walletViewDidTapOnPay(self)
    }
    
    @IBAction func onRequestAccountIDButtonTap() {
        self.delegate?.walletViewDidTapOnCreateAccountRequest(self)
    }
}
