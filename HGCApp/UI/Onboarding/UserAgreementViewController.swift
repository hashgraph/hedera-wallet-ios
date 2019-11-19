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

class UserAgreementViewController: UIViewController {
    @IBOutlet weak var acceptButton : UIButton!
    @IBOutlet weak var textView : UITextView!

    var hideAcceptButton = false
    
    static func getInstance() -> UserAgreementViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "userAgreementViewController") as! UserAgreementViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Terms & Conditions", comment: "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        if self.hideAcceptButton {
            self.acceptButton.isHidden = true
        }
        
        let termsText = try? String.init(contentsOf: Bundle.main.url(forResource: "terms", withExtension: "txt")!)
        self.textView.text = termsText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAccept(){
        let vc = NewWalletViewController.getInstance(SignatureOption.ED25519)
        vc.title = NSLocalizedString("Backup your wallet", comment: "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onFullTerms(){
        if let url = URL(string: termsAndConditions) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
