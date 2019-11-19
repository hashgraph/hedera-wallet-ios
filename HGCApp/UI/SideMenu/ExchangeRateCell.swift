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

class ExchangeRateCell: UITableViewCell {

    @IBOutlet weak var lastLabel : UILabel!
    @IBOutlet weak var bidLabel : UILabel!
    @IBOutlet weak var askLabel : UILabel!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dateLabel.textColor = Color.secondaryTextColor()
        self.dateLabel.font = Font.lightFontVerySmall()
        
        self.nameLabel.textColor = Color.primaryTextColor()
        self.nameLabel.font = Font.regularFontVeryLarge()
        
        self.lastLabel.textColor = Color.secondaryTextColor()
        self.lastLabel.font = Font.regularFontMedium()
        
        self.askLabel.textColor = Color.secondaryTextColor()
        self.askLabel.font = Font.regularFontMedium()
        
        self.bidLabel.textColor = Color.secondaryTextColor()
        self.bidLabel.font = Font.regularFontMedium()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(info:ExchangeRateInfo) {
        nameLabel.text = info.exchangeName
        lastLabel.text = "Last: " + (info.last?.description ?? "--")
        bidLabel.text = "Bid: " + (info.bid?.description ?? "--")
        askLabel.text = "Ask: " + (info.ask?.description ?? "--")
        dateLabel.text = "Last updated at: " + (info.lastUpdatedDate?.toString() ?? "--")
    }

}
