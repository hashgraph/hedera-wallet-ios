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

class HGTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateUI()
    }
    
    func updateUI() {
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.textColor = Color.primaryTextColor()
        self.font = Font.lightFontLarge()
        self.borderStyle = .none
        
        let paddingViewLeft = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 1))
        self.leftView = paddingViewLeft
        self.leftViewMode = .always
        
        let paddingViewRight = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 1))
        self.rightView = paddingViewRight
        self.rightViewMode = .always
    }
    
}
