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

class BalanceTableCell: UITableViewCell {

    @IBOutlet weak var hgcBalanceLabel : UILabel!
    @IBOutlet weak var usdBalanceLabel : UILabel!
    @IBOutlet weak var hgcCurrencyLabel : UILabel!
    @IBOutlet weak var dateTimeLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hgcBalanceLabel.textColor = Color.primaryTextColor()
        self.hgcBalanceLabel.font = Font.hgcAmountFontVeryBig()
        self.usdBalanceLabel.textColor = Color.primaryTextColor()
        self.usdBalanceLabel.font = Font.usdAmountFontVeryBig()
        self.hgcCurrencyLabel.font = Font.regularFont(17.0)
        self.hgcCurrencyLabel.text = kHGCCurrencySymbol
        self.dateTimeLabel.font = Font.lightFontSmall()
        self.dateTimeLabel.textColor = Color.secondaryTextColor()
    }
    
    func setCoins(_ nanoCoins:UInt64) {
        self.hgcBalanceLabel.text = nanoCoins.toHBar().formatHGCShort()
        self.usdBalanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).formatUSD()
    }
    
    func setTextColor(_ color:UIColor) {
        self.hgcBalanceLabel.textColor = color
        self.hgcCurrencyLabel.textColor = color
        self.usdBalanceLabel.textColor = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
}
