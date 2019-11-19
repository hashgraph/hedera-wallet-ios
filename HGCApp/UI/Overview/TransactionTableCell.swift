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
        let address : String? = txn.isDebit() ? txn.fromAccountID : txn.toAccountID
        if txn.isDebit() {
            prefix = NSLocalizedString("From", comment: "")
        }
        if accountName == nil && address != nil {
            accountName = HGCContact.alias(address!)
        }
        if accountName == nil || accountName == "" {
            accountName = NSLocalizedString("UNKNOWN", comment: "")
        }
        
        self.nameLabel.text = prefix + " " + accountName!
        self.addressLabel.text = address ?? " "
        
        self.coinAmountLabel.setAmount(amount.toHBar(), short: true)
        self.amountLabel.text = CurrencyConverter.shared.convertTo$value(amount).formatUSD()
        if let date = txn.createdDate {
            self.dateTimeLabel.text = date.toString()
        } else {
            self.dateTimeLabel.text = ""
        }
    }
}
