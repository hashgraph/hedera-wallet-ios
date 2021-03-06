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

protocol PublicKeyInputCellDelegate : class {
    func publicKeyInputCellDidTapActionButton(_ cell:PublicKeyInputCell)
    func publicKeyInputCellDidChange(_ cell:PublicKeyInputCell, publicKey:String)
}

class PublicKeyInputCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var keyTextField : UITextField!
    var actionButton : UIButton!
    weak var delegate: PublicKeyInputCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        HGCStyle.regularCaptionLabel(self.captionLabel)
        
        self.actionButton = UIButton.init()
        self.actionButton.addTarget(self, action: #selector(self.onActionButtonTap), for: .touchUpInside)
        self.actionButton.setTitle(NSLocalizedString("SCAN", comment: "") + " ", for: .normal)
        self.actionButton.setTitleColor(Color.selectedTintColor(), for: .normal)
        self.actionButton.titleLabel?.font = Font.regularFontMedium()
        self.actionButton.sizeToFit()
        self.actionButton.frame.size.width = self.actionButton.frame.size.width+10
        self.keyTextField.rightView = self.actionButton
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onActionButtonTap() {
        self.delegate?.publicKeyInputCellDidTapActionButton(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newStr = textField.text?.replace(string: string, inRange: range)
        self.delegate?.publicKeyInputCellDidChange(self, publicKey: newStr!)
        
        return true
    }
}

