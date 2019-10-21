//
//  FeeTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 18/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class FeeTableCell: UITableViewCell {

    @IBOutlet weak var feeLabel : HGCAmountLabel!
    @IBOutlet weak var feeCaptionLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        HGCStyle.regularCaptionLabel(self.feeCaptionLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()  
    }
}
