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
