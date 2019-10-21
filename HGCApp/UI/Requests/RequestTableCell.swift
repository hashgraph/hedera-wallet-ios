//
//  RequestTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 06/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
protocol RequestTableCellDelegate : class {
    func requestTableCellDidTapOnPayButton(_ cell: RequestTableCell)
}
class RequestTableCell: UITableViewCell {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var hgcValueLabel : HGCAmountLabel!
    @IBOutlet weak var usdValueLabel : UILabel!
    @IBOutlet weak var dateTimeLabel : UILabel!
    @IBOutlet weak var notesCaptionLabel : UILabel!
    @IBOutlet weak var notesLabel : UILabel!

    weak var delegate : RequestTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateTimeLabel.textColor = Color.secondaryTextColor()
        self.nameLabel.textColor = Color.primaryTextColor()
        self.addressLabel.textColor = Color.secondaryTextColor()
        self.hgcValueLabel.textColor = Color.primaryTextColor()
        self.usdValueLabel.textColor = Color.secondaryTextColor()
        self.notesLabel.textColor = Color.secondaryTextColor()

        self.usdValueLabel.font = Font.lightFontLarge()
        self.addressLabel.font = Font.lightFontLarge()
        self.nameLabel.font = Font.lightFontVeryLarge()
        self.dateTimeLabel.font = Font.lightFontSmall()
        self.hgcValueLabel.font = Font.regularFontVeryLarge()
        self.notesLabel.font = Font.lightFontLarge()
        
        HGCStyle.regularCaptionLabel(self.notesCaptionLabel)
    }
    
    func setRequest(_ request: HGCRequest) {
        let accountName = request.fromName ?? NSLocalizedString("Unknown", comment: "")
        self.nameLabel.text = "\(NSLocalizedString("From", comment: "")) " + accountName
        self.addressLabel.text = NSLocalizedString("Ending in ...", comment: "") + (request.fromAddress?.substringFromEnd(length: 6))!
        let nanoCoins = request.amount
        if nanoCoins > 0 {
            self.hgcValueLabel.setAmount(nanoCoins.toHBar(), short:true)
            self.usdValueLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).formatUSD()
        } else {
            self.hgcValueLabel.attributedText = nil
            self.hgcValueLabel.text = nil
            self.usdValueLabel.text = ""
        }
        
        if request.note != nil && !(request.note?.isEmpty)! {
            self.notesCaptionLabel.text = NSLocalizedString("NOTES", comment: "")
            self.notesLabel.text = request.note
            
        } else {
            self.notesCaptionLabel.text = ""
            self.notesLabel.text = ""
        }
        
        if let date = request.importTime as Date? {
            dateTimeLabel.text = date.toString()
        } else {
            dateTimeLabel.text = ""
        }
    }
    
    @IBAction func onPayButtonTap() {
        self.delegate?.requestTableCellDidTapOnPayButton(self)
    }
}
