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

protocol TXNOptionsTableCellDelegate : class {
    func optionsTableCellDidChangeForNotification(_ cell:TXNOptionsTableCell, value:Bool)
    func optionsTableCellDidChangeForNotes(_ cell:TXNOptionsTableCell, value:Bool)
}

class TXNOptionsTableCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch : HGCSwitch!
    @IBOutlet weak var notesSwitch : HGCSwitch!
    
    weak var delegate : TXNOptionsTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        notificationSwitch.setText("REQUEST NOTIFICATION")
        notesSwitch.setText(NSLocalizedString("ADD NOTE", comment: ""))
        
        self.notificationSwitch.addTarget(self, action: #selector(self.onNotificationValueChanged), for: .valueChanged)
        self.notesSwitch.addTarget(self, action: #selector(self.onNotesValueChanged), for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onNotificationValueChanged() {
        self.delegate?.optionsTableCellDidChangeForNotification(self, value: self.notificationSwitch.isOn)
    }
    
    @objc func onNotesValueChanged() {
        self.delegate?.optionsTableCellDidChangeForNotes(self, value: self.notesSwitch.isOn)
    }
}
