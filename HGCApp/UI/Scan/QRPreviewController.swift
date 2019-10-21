//
//  QRPreviewController.swift
//  HGCApp
//
//  Created by Surendra  on 05/12/17.
//  Copyright © 2017 HGC. All rights reserved.
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
