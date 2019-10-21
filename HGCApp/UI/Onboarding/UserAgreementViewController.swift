//
//  UserAgreementViewController.swift
//  HGCApp
//
//  Created by Surendra  on 24/10/17.
//  Copyright © 2017 HGC. All rights reserved.
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
