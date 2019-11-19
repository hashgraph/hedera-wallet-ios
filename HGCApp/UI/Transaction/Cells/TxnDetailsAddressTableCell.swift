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

protocol TxnDetailsAddressTableCellDelegate : class {
    func txnAddressTableViewCellDidTapCopyButton(_ cell:TxnDetailsAddressTableCell)
    func txnAddressTableViewCellDidChange(_ cell:TxnDetailsAddressTableCell, name:String)
}

class TxnDetailsAddressTableCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var keyLabel : HGCLabel!
    @IBOutlet weak var nameLabel : UITextField!
    @IBOutlet weak var copyButton : UIButton!
    
    var allowEditing = false
    
    weak var delegate: TxnDetailsAddressTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.nameLabel.placeholder = NSLocalizedString("Placeholder_Name_TextField", comment: "")
        self.copyButton.isHidden = true
        self.copyButton.addTarget(self, action: #selector(self.onCopyButtonTap), for: .touchUpInside)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onCopyButtonTap() {
        self.delegate?.txnAddressTableViewCellDidTapCopyButton(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.allowEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newStr = textField.text?.replace(string: string, inRange: range)
        self.delegate?.txnAddressTableViewCellDidChange(self, name: newStr!)
        return true
    }
}
