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

protocol AddressOptionsTableCellDelegate : class {
    func optionsTableViewCellDidTapatIndex(_ cell:AddressOptionsTableCell, index:Int)
}

class AddressOptionsTableCell: UITableViewCell {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var button1 : UIButton?
    @IBOutlet weak var button2 : UIButton?
    @IBOutlet weak var button3 : UIButton?
    
    weak var delegate: AddressOptionsTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    func setTitle(_ title:String, atIndex:Int) {
        switch atIndex {
        case 0:
            button1?.setTitle(title, for: .normal)
        case 1:
            button2?.setTitle(title, for: .normal)
        case 2:
            button3?.setTitle(title, for: .normal)
        default:
            break
        }
    }
    
    func removeButtonAtIndex(index:UInt8) {
        self.button2?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @IBAction func handleTapOnButton(_ sender:UIButton) {
        self.delegate?.optionsTableViewCellDidTapatIndex(self, index: sender.tag)
    }
}
