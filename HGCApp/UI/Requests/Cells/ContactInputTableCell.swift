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

protocol ContactInputTableCellDelegate : class {
    func contactInputTableCellDidChange(_ cell:ContactInputTableCell, text:String)
}

class ContactInputTableCell: UITableViewCell , UITextFieldDelegate {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var textField : UITextField!
    weak var delegate: ContactInputTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.contactInputTableCellDidChange(self, text: textField.text!)
        textField.resignFirstResponder()
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
