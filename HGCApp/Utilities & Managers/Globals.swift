//
//  Globals.swift
//  HGCApp
//
//  Created by Surendra  on 23/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import MBProgressHUD
import MessageUI

class Mailer: NSObject, MFMailComposeViewControllerDelegate {
    
    func emailLogs(from:UIViewController) {
        if !MFMailComposeViewController.canSendMail() {
            Globals.showGenericErrorAlert(title: "Cannot send email", message: "")
            return
        }
        let s = Logger.instance.logs.joined(separator: "\n")
        let emailComposer = MFMailComposeViewController.init()
        emailComposer.setMessageBody(s, isHTML: false)
        emailComposer.mailComposeDelegate = self
        from.present(emailComposer, animated: true) {
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            
        }
    }
}

class Globals {
    
    static func showGenericErrorAlert() {
        showGenericErrorAlert(title: "Something went wrong", message: "Please try later.")
    }
    
    static func showGenericErrorAlert(title:String?, message: String?) {
        showGenericErrorAlert(title: title, message: message, cancelButtonTitle: "Dismiss")
    }
    
    static func showGenericAlert(title:String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message:message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: handler))
        alert.showAlert();
    }
    
    static func showGenericErrorAlert(title:String?, message: String?, cancelButtonTitle: String?) {
        let alert = UIAlertController.init(title: title, message:message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction.init(title: cancelButtonTitle, style: UIAlertAction.Style.cancel, handler: nil))
        alert.showAlert();
    }
    
    static func showConfirmationAlert(title:String?, message: String?, cancelButtonTitle: String = NSLocalizedString("No", comment: ""), actionButtonTitle: String = NSLocalizedString("Yes", comment: ""), onConfirm : @escaping () -> Void, onDismiss : (() -> Void)?) {
        let alert = UIAlertController.init(title: title, message:message, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction.init(title: cancelButtonTitle, style: UIAlertAction.Style.cancel, handler: { (action) in
            if let od = onDismiss {
                od()
            }
        }))
        alert.addAction(UIAlertAction.init(title:actionButtonTitle, style: .default, handler: { (action) in
            onConfirm()
        }))
        alert.showAlert();
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func isValidIP(s: String) -> Bool {
        let parts = s.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
    }
    
    static func getBuildVersion() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
    
    static func isValidPhone(value: String) -> Bool {
        /*let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)*/
        return value.count > 3 && self.isNumber(value:value)
    }
    
    static func isNumber(value: String) -> Bool {
        let a = Int64(value)
        return a != nil
    }
    
    static func getUnsignedNum(object: Any?) -> UInt16 {
        if let _objNum = object as? UInt16 {
            return _objNum
        }
        
        if let str = object as? String {
            if let num = UInt16(str.trim()) {
                return num
            }
        }
        
        return 0
    }
    
    static func formatNumber(number: NSNumber) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: number)
        return formattedNumber
    }
    
    static func copyString(_ string:String?) {
        UIPasteboard.general.string = string
    }
    
    static func mainStoryboard() -> UIStoryboard{
        return UIStoryboard.init(name: "Main", bundle: Bundle.main);
    }
    
    static func welcomeStoryboard() -> UIStoryboard{
        return UIStoryboard.init(name: "Welcome", bundle: Bundle.main);
    }
    
    static func developerToolsStoryboard() -> UIStoryboard{
        return UIStoryboard.init(name: "DeveloperTools", bundle: Bundle.main);
    }
    
    static func backBarButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem.init(image: UIImage.init(named: "topbarBack"), style: .plain, target: target, action: action)
    }
    
    static func emptyBackBarButton() -> UIBarButtonItem {
        return UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
    }
    
    static func hideBottomLine(navBar: UIView?) {
        self.findHairlineImageViewUnder(view: navBar)?.isHidden = true
        if let bar = navBar as? UINavigationBar {
            bar.shadowImage = UIImage.init()
        }
    }
    
    static func findHairlineImageViewUnder(view : UIView?) -> UIImageView? {
        if view is UIImageView && (view?.bounds.size.height)! <= CGFloat(1.0) {
            return view as? UIImageView
        }
        for subview in (view?.subviews)! {
            let imgv = self.findHairlineImageViewUnder(view: subview)
            if imgv != nil {
                return imgv
            }
        }
        return nil
    }
    
    static func dateFromString(string: String?) -> Date? {
        if let dateString = string {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm aaa"
            if dateFormatter.date(from: dateString) == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
            }
            let date = dateFormatter.date(from: dateString)
            return date
        }
        return nil
    }
    
    static func formattedDate(date: Date?) -> String? {
        if date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: date!)
        }
        return nil
    }
    
    static func formattedDateTime(date: Date?) -> String? {
        if date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm aaa"
            return dateFormatter.string(from: date!)
        }
        return nil
    }
    
    static func call(phone: String?) {
        if let nuber = phone {
            let url = URL.init(string: ("tel://"+nuber))
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
}

extension String {
    func urlEncode() -> String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func substringFromEnd(length:Int) -> String {
        if self.count < length {
            return self
        }
        return String(self.suffix(length))
    }
    
    func replace(string:String, inRange:NSRange) -> String {
        let nsstr = self as NSString
        let newStr = nsstr.replacingCharacters(in: inRange, with: string)
        return newStr
    }
    
    func hexadecimal() -> Data? {
        let data = Data.init(hex: self)
        guard data.count > 0 else { return nil }
        return data
    }
    
    public func extractTokenAddress() -> String? {
        let lowercasedSample = self.lowercased()
        let hexRegex = "(0x)?[0-9a-f]{40}"
        let regex = try! NSRegularExpression(pattern: hexRegex, options: [])
        let matches = regex.matches(in: lowercasedSample, options: [], range: NSRange(location: 0, length: self.count))
        
        for match in matches {
            return (self as NSString).substring(with: match.range)
        }
        
        return nil
    }
}

extension Data {
    var hex: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func bytes() -> [UInt8] {
        let array = withUnsafeBytes {
            (pointer: UnsafePointer<UInt8>) -> [UInt8] in
            let buffer = UnsafeBufferPointer(start: pointer,
                                             count: self.count)
            return Array<UInt8>(buffer)
        }
        return array
    }
}

extension Date {
    func toString() -> String {
        return timeAgoSinceNow()
    }
}

extension Double {
    
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension MBProgressHUD {
    static func hide(_ hud:MBProgressHUD) {
        DispatchQueue.main.async {
            hud.hide(animated: true)
        }
    }
}


