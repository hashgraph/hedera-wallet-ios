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

class LocalizableButton: UIButton {
    
    @IBInspectable var localizedKey: String? {
        didSet {
            guard let key = localizedKey, !key.trim().isEmpty else { return }
            setTitle(NSLocalizedString(key, comment: ""), for: .normal)
        }
    }
}

class HGCButton: LocalizableButton {
    @IBInspectable var autoWidth: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.lightGray, for: .disabled)
        self.layer.cornerRadius = 23
        self.layer.borderColor = Color.defaultButtonTextColor().cgColor
        self.layer.borderWidth = 2
        self.titleLabel?.font = Font.regularFontLarge()
        self.reloadUI()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize.init(width: autoWidth ? (size.width + 20) : 100, height: 46)
    }
    
    func reloadUI() {
        self.setTitleColor(Color.defaultButtonTextColor(), for: .normal)
    }
}

class HGCButtonPrimary: HGCButton {
    override func reloadUI() {
        super.reloadUI()
        self.setTitleColor(Color.primaryButtonTextColor(), for: .normal)
    }
}

class HGCButtonDestructive: HGCButton {
    override func reloadUI() {
        super.reloadUI()
        self.setTitleColor(Color.destructiveButtonTextColor(), for: .normal)
    }
}

class HGCTabButton: LocalizableButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Color.tabBackgroundColor()
        self.imageEdgeInsets = UIEdgeInsets.init(top: -20, left: 40, bottom: 0, right: 0)
        self.titleEdgeInsets = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 10)
        
        self.setTabSelected(false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect.init(x: 0, y: 10, width: self.frame.size.width, height: 20)
        self.titleLabel?.font = Font.regularFontSmall()
        self.titleLabel?.frame = CGRect.init(x: 0, y: (self.imageView?.frame.maxY)!+5, width: self.frame.size.width, height: 20)
        self.titleLabel?.textAlignment = .center
        
        self.imageView?.contentMode = .center
    }
    
    func setTabSelected(_ selected:Bool) {
        self.isSelected = selected
        self.imageView?.tintColor = selected ? Color.selectedTintColor() : Color.primaryTextColor()
        self.setTitleColor(selected ? Color.selectedTintColor() : Color.primaryTextColor(), for: .normal)
    }
}

class HGCSolidButton: LocalizableButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Color.solidButtonBackgroundColor()
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 15
        self.titleLabel?.font = Font.regularFontVerySmall()
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? Color.solidButtonBackgroundColor() : Color.solidButtonBackgroundDisabledColor()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 100, height: 30)
    }
}
