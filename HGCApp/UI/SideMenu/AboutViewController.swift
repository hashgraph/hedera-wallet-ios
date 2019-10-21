//
//  AboutViewController.swift
//  HGCApp
//
//  Created by Surendra  on 18/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var appNameLabel : UILabel!;
    @IBOutlet weak var appVersionLabel : UILabel!;
    @IBOutlet weak var appBuildLabel : UILabel!;
    
    static func getInstance() -> AboutViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "aboutViewController") as! AboutViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("ABOUT", comment: "")
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.appNameLabel.textColor = Color.primaryTextColor()
        self.appVersionLabel.textColor = Color.primaryTextColor()
        self.appBuildLabel.textColor = Color.primaryTextColor()
        
        self.appNameLabel.font = Font.regularFont(17.0)
        self.appVersionLabel.font = Font.regularFontMedium()
        self.appBuildLabel.font = Font.lightFontMedium()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersionLabel.text = "\(NSLocalizedString("Version", comment: "")) " + version
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.appBuildLabel.text = "\(NSLocalizedString("Build", comment: "")) " + version
        }
        
    }
    
    @IBAction func onTermsOfUseTap() {
        let vc = UserAgreementViewController.getInstance()
        vc.hideAcceptButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPrivacyPolicyTap() {
        if let url = URL(string: privacyPolicy) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
