//
//  InfoTableCellTableViewCell.swift
//  HGCApp
//
//  Created by Surendra on 13/09/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class InfoTableCell: UITableViewCell {
    
    @IBOutlet weak var messageLable : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageLable.textColor = Color.secondaryTextColor()
        messageLable.font = Font.regularFontMedium()
        messageLable.textAlignment = .left
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
}
