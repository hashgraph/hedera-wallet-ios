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

class LocalizableLabel: UILabel {
    
    @IBInspectable var localizedKey: String? {
        didSet {
            guard let key = localizedKey, !key.trim().isEmpty else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }
}

class HGCLabel: LocalizableLabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.layer.borderColor = Color.boxBorderColor().cgColor
        self.layer.borderWidth = 1
        self.textColor = Color.primaryTextColor()
        self.font = Font.lightFontMedium()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = self.sizeThatFits(CGSize.init(width: self.frame.size.width-20, height: CGFloat(MAXFLOAT)))
        return CGSize.init(width: 100, height: size.height+10)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 10, dy: 5))
    }
}

class HGCAmountLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = Color.primaryTextColor()
        self.font = Font.regularFontMedium()
    }
    
    func setAmount(_ amountStr : String) {
//        let currency = kHGCCurrencySymbol
//        let cAttribute = [NSAttributedStringKey.foregroundColor: self.textColor, NSAttributedStringKey.font : self.font] as [NSAttributedStringKey : Any]
//        let cAttrString = NSAttributedString(string: currency, attributes: cAttribute)
//        
//        let attribute = [NSAttributedStringKey.foregroundColor: self.textColor, NSAttributedStringKey.font : Font.regularFont(self.font.pointSize)] as [NSAttributedStringKey : Any]
//        let attrString = NSAttributedString(string: amountStr, attributes: attribute)
//        
//        let s = NSMutableAttributedString.init(attributedString: cAttrString)
//        s.append(attrString)
        self.text = amountStr + " " + kHGCCurrencySymbol
    }
    
    func setAmount(_ nanoCoins:Int64) {
        setAmount(nanoCoins.toHBar().formatHGC())
    }
    
    func setAmount(_ coins:Double, short:Bool = false) {
        setAmount(short ? coins.formatHGCShort() : coins.formatHGC())
    }
}
