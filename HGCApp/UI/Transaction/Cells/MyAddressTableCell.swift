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

protocol MyAddressTableCellDelegate : class{
    func myAddressTableCellDidTapOnActionButton(_ cell:MyAddressTableCell)
}

class MyAddressTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var hgcBalanceLabel : UILabel!
    @IBOutlet weak var usdBalanceLabel : UILabel!
    @IBOutlet weak var lastTxnLabel : UILabel!
    @IBOutlet weak var captionLabel : UILabel!

    @IBOutlet weak var actionButton : UIButton!
    weak var delegate : MyAddressTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = Font.lightFontVeryLarge()
        self.titleLabel.textColor = Color.primaryTextColor()
        
        self.addressLabel.font = Font.lightFontLarge()
        self.addressLabel.textColor = Color.secondaryTextColor()
        
        self.hgcBalanceLabel.font = Font.lightFontLarge()
        self.hgcBalanceLabel.textColor = Color.primaryTextColor()
        
        self.usdBalanceLabel.font = Font.lightFontMedium()
        self.usdBalanceLabel.textColor = Color.secondaryTextColor()
        
        self.lastTxnLabel.font = Font.regularFontSmall()
        self.lastTxnLabel.textColor = Color.secondaryTextColor()
        
        HGCStyle.regularCaptionLabel(self.captionLabel)
        
        self.actionButton.addTarget(self, action: #selector(self.onActionButtonTap), for: .touchUpInside)
        self.actionButton.setTitle(NSLocalizedString("CHANGE", comment: ""), for: .normal)
        self.actionButton.setTitleColor(Color.selectedTintColor(), for: .normal)
        self.actionButton.titleLabel?.font = Font.regularFontMedium()
    }
    
    @objc func onActionButtonTap() {
        self.delegate?.myAddressTableCellDidTapOnActionButton(self)
    }
    
    func setAccount(_ account:HGCAccount) {
        let accountName = account.name ?? NSLocalizedString("Unknown", comment: "")
        self.titleLabel.text = accountName
        if let acc = account.accountID() {
            self.addressLabel.text = acc.stringRepresentation()
        } else {
            self.addressLabel.text = NSLocalizedString("Ending in ...", comment: "")+account.publicKeyString().substringFromEnd(length: 6)
        }
        
        let nanoCoins = account.balance
        self.hgcBalanceLabel.text = nanoCoins.toHBar().formatHGCShort()
        self.usdBalanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).formatUSD()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
}
