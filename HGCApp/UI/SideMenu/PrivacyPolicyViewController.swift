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

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var textView : UITextView!

    static func getInstance() -> PrivacyPolicyViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "privacyPolicyViewController") as! PrivacyPolicyViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("PRIVACY POLICY", comment: "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        let string = try! String.init(contentsOf: Bundle.main.url(forResource: "privacy", withExtension: "txt")!)
        self.textView.text = string
       
        
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
