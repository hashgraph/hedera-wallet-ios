//
//  BalanceTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 14/12/17.
//  Copyright © 2017 HGC. All rights reserved.
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
