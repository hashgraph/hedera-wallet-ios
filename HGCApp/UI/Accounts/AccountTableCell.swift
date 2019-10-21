//
//  AccountTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AccountTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var hgcBalanceLabel : UILabel!
    @IBOutlet weak var usdBalanceLabel : UILabel!
    @IBOutlet weak var lastTxnLabel : UILabel!
    @IBOutlet weak var hgcLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = Font.lightFontVeryLarge()
        self.titleLabel.textColor = Color.primaryTextColor()
        
        self.addressLabel.font = Font.lightFontLarge()
        self.addressLabel.textColor = Color.secondaryTextColor()
        
        self.hgcBalanceLabel.font = Font.lightFontVeryLarge()
        self.hgcBalanceLabel.textColor = Color.primaryTextColor()
        
        self.usdBalanceLabel.font = Font.lightFontLarge()
        self.usdBalanceLabel.textColor = Color.secondaryTextColor()
        
        self.lastTxnLabel.font = Font.lightFontSmall()
        self.lastTxnLabel.textColor = Color.secondaryTextColor()
        
        self.hgcLabel.font = self.hgcBalanceLabel.font
        self.hgcLabel.text = kHGCCurrencySymbol
        self.hgcLabel.textColor = self.hgcBalanceLabel.textColor
    }
    
    func setAccount(_ account:HGCAccount) {
        self.titleLabel.text = NSLocalizedString("Unknown", comment: "")
        if let name = account.name, !name.isEmpty {
            self.titleLabel.text = name
        }
        self.addressLabel.text = account.accountID()?.stringRepresentation()
        let nanoCoins = account.balance
        self.hgcBalanceLabel.text = nanoCoins.toHBar().formatHGCShort()
        self.usdBalanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).formatUSD()
        self.lastTxnLabel.text = ""
        if account.accountTypeE != .external, let lastTxn = account.getAllTxn().first {
            var dateStr = ""
            if let date = lastTxn.createdDate {
                dateStr = date.toString()
            }
            self.lastTxnLabel.text = "\(NSLocalizedString("Last transaction", comment: "")) " + dateStr
        }
    }

}
