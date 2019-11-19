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

class HGCStyle: NSObject {
    
    static func regularCaptionLabel (_ label : UILabel) {
        label.textColor = Color.secondaryTextColor()
        label.font = Font.regularFontMedium()
    }
    
    static func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = Color.navBarBackgroundColor();
        UINavigationBar.appearance().tintColor = Color.primaryTextColor();
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().isTranslucent = false;
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : Color.primaryTextColor(), NSAttributedString.Key.font : Font.regularFontVeryLarge()]
    }
}

class Color {
    
    static func negativeColor() -> UIColor {
        return Color.colorWithHex("F15A31", alpha: 1.0)!;
    }
    
    static func positiveColor() -> UIColor {
        return Color.colorWithHex("0EE78E", alpha: 1.0)!;
    }
    
    static func tintColor() -> UIColor {
        return Color.colorWithHex("00AEEF", alpha: 1.0)!;
    }
    
    static func sideMenuBackgroundColor() -> UIColor {
        return UIColor.init(white: 0.15, alpha: 1.0)
    }
    
    static func veryDarkTextColor() -> UIColor {
        return Color.colorWithHex("4D4D4F", alpha: 1.0)!;
    }
    
    static func pageBackgroundColor() -> UIColor {
        return Color.colorWithHex("FAFAFB", alpha: 1.0)!;
    }
    
    static func navBarBackgroundColor() -> UIColor {
        return UIColor.white;
    }
    
    static func titleBarBackgroundColor() -> UIColor {
        return self.pageBackgroundColor();
    }
    
    static func tabBackgroundColor() -> UIColor {
        return Color.colorWithHex("F7F7F8", alpha: 1.0)!;
    }
    
    static func statusBarBackgroundColor() -> UIColor {
        return self.tabBackgroundColor();
    }
    
    static func primaryTextColor() -> UIColor {
        return Color.colorWithHex("3D3D3F", alpha: 1.0)!;
    }
    
    static func secondaryTextColor() -> UIColor {
        return Color.colorWithHex("8D8F92", alpha: 1.0)!;
    }
    
    static func selectedTintColor() -> UIColor {
        return self.tintColor()
    }
    
    static func tableLineSeperatorColor() -> UIColor {
        return Color.colorWithHex("F1F1F2", alpha: 1.0)!;
    }
    
    static func boxBorderColor() -> UIColor {
        return Color.colorWithHex("E5E5E5", alpha: 1.0)!;
    }
    
    static func primaryButtonTextColor() -> UIColor {
        return self.positiveColor()
    }
    
    static func destructiveButtonTextColor() -> UIColor {
        return self.negativeColor()
    }
    
    static func defaultButtonTextColor() -> UIColor {
        return Color.colorWithHex("77787B", alpha: 1.0)!;
    }
    
    static func solidButtonBackgroundColor() -> UIColor {
        return Color.colorWithHex("77787B", alpha: 1.0)!;
    }
    
    static func solidButtonBackgroundDisabledColor() -> UIColor {
        return self.solidButtonBackgroundColor().withAlphaComponent(0.5)
    }
    
    static func colorWithHex(_ hexStr: String, alpha : Float) -> UIColor? {
        var hex = hexStr
        if (hex.isEmpty) { return nil };
        
        if (hex.hasPrefix("#")) {
            hex.remove(at: hex.startIndex)
        }
        
        if ((hex.count) != 6) {
            return Color.tintColor();
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: hex).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class Font {
    
    
    static func regularFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "StyreneA-Regular", size: size)!
    }
    
    static func lightFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "StyreneA-Light", size: size)!
    }
    
    static func thinFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "StyreneA-Thin", size: size)!
    }
    
    static func hgcRegularFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "HederaH-Regular", size: size)!
    }
    
    static func hgcLightFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "HederaH-Light", size: size)!
    }
    
    static func regularFontVerySmall() -> UIFont {
        return self.regularFont(10.0)
    }
    
    static func regularFontSmall() -> UIFont {
        return self.regularFont(11.0)
    }
    
    static func regularFontMedium() -> UIFont {
        return self.regularFont(12.0)
    }
    
    static func regularFontLarge() -> UIFont {
        return self.regularFont(13.0)
    }
    
    static func regularFontVeryLarge() -> UIFont {
        return self.regularFont(14.0)
    }
    
    static func lightFontVerySmall() -> UIFont {
        return self.lightFont(10.0)
    }
    
    static func lightFontSmall() -> UIFont {
        return self.lightFont(11.0)
    }
    
    static func lightFontMedium() -> UIFont {
        return self.lightFont(12.0)
    }
    
    static func lightFontLarge() -> UIFont {
        return self.lightFont(13.0)
    }
    
    static func lightFontVeryLarge() -> UIFont {
        return self.lightFont(14.0)
    }
    
    static func hgcAmountFontVeryBig() -> UIFont {
        return self.regularFont(36.0)
    }
    
    static func usdAmountFontVeryBig() -> UIFont {
        return self.regularFont(17.0)
    }
    
    static func hgcFontVeryBig() -> UIFont {
        return self.hgcRegularFont(17.0)
    }
}
