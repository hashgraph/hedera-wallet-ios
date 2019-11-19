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

protocol QRPreviewTableCellDelegate : class {
    func qrPreviewTableCellDidCancel(_ cell:QRPreviewTableCell)
}

class QRPreviewTableCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var qrImageView : UIImageView!
    
    weak var delegate: QRPreviewTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        captionLabel.text = ""
        HGCStyle.regularCaptionLabel(self.captionLabel)
    }
    
    @IBAction func onCancelButtonTap() {
        self.delegate?.qrPreviewTableCellDidCancel(self)
    }
    
    func setString(_ str:String) {
        var qrCode = QRCode.init(str)
        qrCode?.size = CGSize.init(width: qrImageView.frame.size.width, height: qrImageView.frame.size.height);
        self.qrImageView.image = qrCode?.image
        Logger.instance.log(message: str, event: .d)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
