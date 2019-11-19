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

protocol NotesTableViewCellDelegate : class {
    func notesTableViewCellDidChange(_ cell:NotesTableViewCell, text:String)
    func notesTableViewCellShouldUpdateNewText(_ cell:NotesTableViewCell, text:String) -> Bool
}

class NotesTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var textView : UITextView!
    weak var delegate: NotesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.captionLabel.text = NSLocalizedString("NOTE", comment: "")
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.textView.font = Font.regularFontMedium()
        self.textView.textColor = Color.primaryTextColor()
        let toolBar = HGCKeyboardToolBar.toolBarWithResponder(self.textView)
        self.textView.inputAccessoryView = toolBar
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.notesTableViewCellDidChange(self, text: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textViewStr = textView.text! as NSString
        let newStr = textViewStr.replacingCharacters(in: range, with: text)
        let shouldUpdate = self.delegate?.notesTableViewCellShouldUpdateNewText(self, text: newStr) ?? true
        return shouldUpdate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
