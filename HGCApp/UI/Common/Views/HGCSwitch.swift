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

class HGCSwitch: UIControl {
    
    private let controlHeight : CGFloat = 40.0
    
    var isOn = false
    
    private let box = HGCBoxView.init()
    private let dot = UIView.init()
    private let label = UILabel.init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.addSubview(self.label)
        self.addSubview(self.box)
        self.addSubview(self.dot)
        
        self.box.setupUI()
        HGCStyle.regularCaptionLabel(self.label)
        
        self.setOn(false, animated: false)
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
    }
    
    func setOn(_ on:Bool, animated:Bool) {
        self.dot.backgroundColor = on ? UIColor.darkGray : UIColor.clear
        isOn = on
    }
    
    func setText(_ text:String) {
        self.label.text = text
        self.invalidateIntrinsicContentSize()
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize.init(width: self.label.intrinsicContentSize.width + controlHeight - 10.0, height: controlHeight)
        return size
    }
    
    @objc func handleTap() {
        setOn(!self.isOn, animated: true)
        self.sendActions(for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let boxHeight = 20
        self.box.frame = CGRect.init(x: 0, y: 10, width: boxHeight, height: boxHeight)
        self.dot.frame = self.box.frame.insetBy(dx: 4, dy: 4)
        self.label.sizeToFit()
        self.label.center = CGPoint.init(x: controlHeight/2.0, y: controlHeight/2.0)
        self.label.frame.origin.x = self.box.frame.maxX + 5
    }
}
