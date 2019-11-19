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

class HGCTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.borderStyle = .none
        self.layer.borderColor = Color.boxBorderColor().cgColor
        self.layer.borderWidth = 1
        self.textColor = Color.primaryTextColor()
        self.font = Font.lightFontLarge()
        self.leftViewMode = .always
        self.rightViewMode = .always
        let toolBar = HGCKeyboardToolBar.toolBarWithResponder(self)
        self.inputAccessoryView = toolBar
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 100, height: 34)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if rect.origin.x == 0 {
            rect.origin.x = 10
            rect.size.width = rect.size.width - 10
        }
        if  rect.maxX ==  bounds.width {
            rect.size.width = rect.size.width - 10
        }
        return rect
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds:bounds)
    }
}
