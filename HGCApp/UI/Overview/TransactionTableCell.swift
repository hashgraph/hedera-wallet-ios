//
//  TransactionTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 22/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class TransactionTableCell: UITableViewCell {
    
    @IBOutlet weak var dateTimeLabel : UILabel!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var coinAmountLabel : HGCAmountLabel!
    @IBOutlet weak var amountLabel : UILabel!
    @IBOutlet weak var tagView : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateTimeLabel.textColor = Color.secondaryTextColor()
        self.nameLabel.textColor = Color.primaryTextColor()
        self.addressLabel.textColor = Color.secondaryTextColor()
        self.coinAmountLabel.textColor = Color.primaryTextColor()
        self.amountLabel.textColor = Color.secondaryTextColor()
        
        self.dateTimeLabel.font = Font.lightFontMedium()
        self.nameLabel.font = Font.lightFontVeryLarge()
        self.coinAmountLabel.font = Font.regularFontVeryLarge()
        self.addressLabel.font = Font.lightFontLarge()
        self.amountLabel.font = Font.lightFontLarge()        
    }
    
    func setTxn(_ txn:TransactionVO) {
        self.nameLabel.text = ""
        self.addressLabel.text = ""
        self.dateTimeLabel.text = ""
        self.tagView.backgroundColor = txn.isDebit() ? Color.positiveColor() : Color.negativeColor()
        
        let amount = txn.displayAmount()
        
        var prefix = NSLocalizedString("To", comment: "")
        var accountName : String? = nil
        if let address = txn.isDebit() ? txn.fromAccountID : txn.toAccountID {
            if txn.isDebit() {
                prefix = NSLocalizedString("From", comment: "")
            }
            if accountName == nil {
                accountName = HGCContact.alias(address)
            }
            if accountName == nil || accountName == "" {
                accountName = NSLocalizedString("UNKNOWN", comment: "")
            }
            self.nameLabel.text = prefix + " " + accountName!
            self.addressLabel.text = NSLocalizedString("ENDING IN ...", comment: "") + (address.substringFromEnd(length: 6))
        }
        
        self.coinAmountLabel.setAmount(amount.toHBar(), short: true)
        self.amountLabel.text = CurrencyConverter.shared.convertTo$value(amount).formatUSD()
        if let date = txn.createdDate {
            self.dateTimeLabel.text = date.toString()
        } else {
            self.dateTimeLabel.text = ""
        }
    }
}
