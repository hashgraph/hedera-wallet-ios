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

class HGCKeyboardToolBar: UIToolbar {
    
    weak var reponderObj : UIResponder?
    
    static func toolBarWithResponder(_ r: UIResponder ) -> HGCKeyboardToolBar {
        
        let bar = HGCKeyboardToolBar.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        bar.reponderObj = r
        bar.setup()
        return bar
    }
    
    private func setup() {
        let flexi = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(title: "Dismiss", style: .plain, target: self, action: #selector(self.onDoneTap))
        self.items = [flexi,doneButton]
    }
    
    @objc func onDoneTap() {
        reponderObj?.resignFirstResponder()
    }
    
}
