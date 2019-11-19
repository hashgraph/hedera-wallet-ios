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

class QRPreviewController: ContentViewController {
    
    var qrString : String!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var qrLabel : UILabel!

    static func getInstance(_ string: String) -> QRPreviewController {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "qrPreviewController") as! QRPreviewController
        vc.qrString = string
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))

        self.qrLabel.text = qrString
        Logger.instance.log(message: qrString, event: .d)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var qrCode = QRCode.init(qrString)
        qrCode?.size = CGSize.init(width: imageView.frame.size.width, height: imageView.frame.size.height);
        self.imageView.image = qrCode?.image
    }
    
    @IBAction func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
