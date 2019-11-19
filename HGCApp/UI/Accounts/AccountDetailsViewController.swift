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

class AccountDetailsViewController: UIViewController {

    @IBOutlet weak var accountDetailContainer : UIView!
    
    var acountDetailView : AccountDetailView?
    private var account: HGCAccount!

    static func getInstance(_ account: HGCAccount) -> AccountDetailsViewController {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "accountDetailsViewController") as! AccountDetailsViewController
        vc.account = account
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("ACCOUNT DETAILS", comment: "")
        self.accountDetailContainer.backgroundColor = Color.pageBackgroundColor()
        self.accountDetailContainer.superview?.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.hidesBackButton = true
        
        /*let btn1 = UIButton(type: .custom)
        btn1.setTitle(" Tokens ", for: .normal)
        btn1.setTitleColor(Color.defaultButtonTextColor(), for: .normal)
        btn1.titleLabel?.font = Font.regularFontMedium()
        btn1.backgroundColor = UIColor.white
        btn1.layer.borderColor = Color.defaultButtonTextColor().cgColor
        btn1.layer.borderWidth = 0.5
        btn1.layer.cornerRadius = 2
        btn1.clipsToBounds = true
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(onTokenButtonTap), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: btn1)
        */
        
        self.acountDetailView = AccountDetailView.getInstance()
        self.accountDetailContainer.addContentView(self.acountDetailView)
        self.acountDetailView?.setAccount(account)
       

    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = NSLocalizedString("ACCOUNT DETAILS", comment: "")
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
    }
    
    @objc func onCloseButtonTap() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onTokenButtonTap(){
        
    }
    
}
