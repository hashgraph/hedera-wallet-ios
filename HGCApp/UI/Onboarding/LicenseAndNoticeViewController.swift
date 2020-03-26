//
//  Copyright 2020 Hedera Hashgraph LLC
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

class LicenseAndNoticeViewController: UIViewController {

    weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("License and Notice", comment: "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "icon-close"), style: .plain, target: self,
            action: #selector(onCloseButtonTap))
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        self.view.backgroundColor = Color.pageBackgroundColor()

        let licenseText: String = {
            guard let licenseURL = Bundle.main.url(forResource: "LICENSE", withExtension: nil) else {
                return ""
            }
            return (try? String(contentsOf: licenseURL)) ?? ""
        }()
        let noticeText: String = {
            guard let noticeURL = Bundle.main.url(forResource: "NOTICE", withExtension: nil) else {
                return ""
            }
            return (try? String(contentsOf: noticeURL)) ?? ""
        }()
        let text = (licenseText.isEmpty ? "" : (String(format: "=======\nLICENSE\n=======\n") + licenseText)) +
            (noticeText.isEmpty ? "" : (String(format: "======\nNOTICE\n======\n") + noticeText))
        let view = UITextView(frame: self.view.frame)
        view.text = text
        self.view.addSubview(view)
        textView = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.scrollRangeToVisible(NSMakeRange(0, 0))
    }

    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
