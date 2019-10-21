//
//  AmountTableViewCell.swift
//  HGCApp
//
//  Created by Surendra  on 10/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol AmountTableViewCellDelegate : class {
    func amountTableViewCellDidChange(_ cell:AmountTableViewCell, nanaoCoins:Int64)
    func amountTableViewCellDidEndEditing(_ cell:AmountTableViewCell)
    func amountTableViewCellDidChange(_ cell:AmountTableViewCell, textField:UITextField, text:String)
}

class AmountTableViewCell: UITableViewCell , UITextFieldDelegate{

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var hgcTextField : UITextField!
    @IBOutlet weak var usdTextField : UITextField!
    
    weak var delegate: AmountTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let labelUSD = UILabel.init()
        labelUSD.textColor = usdTextField.textColor
        labelUSD.font = usdTextField.font
        labelUSD.text = " $  "
        labelUSD.sizeToFit()
        labelUSD.frame.size.width = labelUSD.frame.size.width+10
        labelUSD.textAlignment = .center
        usdTextField.leftView = labelUSD
        usdTextField.placeholder = "0.0"
        usdTextField.keyboardType = .default
        
        let labelHGC = UILabel.init()
        labelHGC.textColor = hgcTextField.textColor
        labelHGC.font = hgcTextField.font
        labelHGC.text = " " + kHGCCurrencySymbol + "  "
        labelHGC.sizeToFit()
        labelHGC.frame.size.width = labelHGC.frame.size.width+10
        labelHGC.textAlignment = .center
        hgcTextField.leftView = labelHGC
        hgcTextField.placeholder = "0.0"
        hgcTextField.keyboardType = .default
        
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let amount = Double((textField.text?.trim())!)
        if amount == nil || amount == 0.0 {
            textField.text = ""
        }
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            if self.hgcTextField == textField {
//                let hgcCoins = Double((self.hgcTextField.text?.trim())!) ?? 0.0
//                self.usdTextField.text = CurrencyConverter.shared.convertTo$value(coins: hgcCoins).description
//
//            } else if self.usdTextField == textField {
//                let usd = Double((self.usdTextField.text?.trim())!) ?? 0.0
//                self.hgcTextField.text = CurrencyConverter.shared.convertToHGCCoins(usd).description
//
//            }
//
//            var nanoCoins : Int64 = 0
//            if self.hgcTextField == textField {
//                let hgcCoins = Double((self.hgcTextField.text?.trim())!) ?? 0.0
//                nanoCoins = hgcCoins.toNanoCoins()
//
//            } else if self.usdTextField == textField {
//                let usd = Double((self.usdTextField.text?.trim())!) ?? 0.0
//                nanoCoins = CurrencyConverter.shared.convertToHGCNanoCoins(usd)
//            }
//            self.delegate?.amountTableViewCellDidChange(self, nanaoCoins: nanoCoins)
//        }
//
//        return true
//    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldStr = textField.text! as NSString
        var newStr = textFieldStr.replacingCharacters(in: range, with: string)
        if newStr.trim().isEmpty {
            newStr = "0.0"
        }
        if let amount = Double(newStr) {
            if amount > 999999999.0 {
                return false
            }
            if self.hgcTextField == textField {
                let hgcCoins = amount
                self.usdTextField.text = CurrencyConverter.shared.convertTo$value(hBar: hgcCoins).toString()
                
            } else if self.usdTextField == textField {
                let usd = amount
                self.hgcTextField.text = CurrencyConverter.shared.convertToHBar(usd).toString()
                
            }
            
            var nanoCoins : Int64 = 0
            if self.hgcTextField == textField {
                let hgcCoins = amount
                nanoCoins = hgcCoins.toTinyBar()
                
            } else if self.usdTextField == textField {
                let usd = amount
                nanoCoins = CurrencyConverter.shared.convertToTinyBar(usd)
            }
            self.delegate?.amountTableViewCellDidChange(self, nanaoCoins: nanoCoins)
            self.delegate?.amountTableViewCellDidChange(self, textField: textField, text: newStr)
            return true
        }
        
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.amountTableViewCellDidEndEditing(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
}
