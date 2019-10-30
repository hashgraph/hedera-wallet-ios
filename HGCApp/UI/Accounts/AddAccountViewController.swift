//
//  AddAccountViewController.swift
//  HGCApp
//
//  Created by Surendra  on 28/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController {
   
    @IBOutlet weak var nickNameTextField : UITextField!
    @IBOutlet weak var nickNameCaptionLabel : UILabel!
    @IBOutlet weak var accountIdTextField : UITextField!
    @IBOutlet weak var accountIdCaptionLabel : UILabel!

    @IBOutlet weak var addAccountViewContainer : UIView!
    @IBOutlet weak var deleteButton : UIButton?
    
    var viewModel:AddAccountViewModel!
    
    static func getInstance(viewModel:AddAccountViewModel) -> AddAccountViewController {
        let vc =  Globals.mainStoryboard().instantiateViewController(withIdentifier: "addAccountViewController") as! AddAccountViewController
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addAccountViewContainer.backgroundColor = Color.pageBackgroundColor()
        HGCStyle.regularCaptionLabel(self.nickNameCaptionLabel)
        HGCStyle.regularCaptionLabel(self.accountIdCaptionLabel)
        
        nickNameCaptionLabel.text = NSLocalizedString("ACCOUNT NAME", comment: "")
        nickNameTextField.placeholder = NSLocalizedString("Placeholder_Name_TextField", comment: "")
        nickNameTextField.text = viewModel.nickName
        
        accountIdCaptionLabel.text = NSLocalizedString("ACCOUNT ID", comment: "")
        accountIdTextField.placeholder = NSLocalizedString("ACCOUNTID_PLACEHOLDER", comment: "")
        accountIdTextField.text = viewModel.accountIDString
        
        self.title = viewModel.pageTitle
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(AddAccountViewController.onCloseButtonTap))
        deleteButton?.isHidden = viewModel.hideDeleteButton
    }
    
    @IBAction func onDoneButtonTap() {
        viewModel.nickName = self.nickNameTextField.text?.trim() ?? ""
        viewModel.accountIDString = self.accountIdTextField.text?.trim() ?? ""
        do {
            try viewModel.onDoneButtonTap()
            
        } catch {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Error", comment: ""), message: "\(error)")
        }
    }
    
    @IBAction func onDeleteButtonTap() {
        viewModel.onDeleteButtonTap()
    }
    
    @objc func onCloseButtonTap() {
        viewModel.onCancelButtonTap()
    }
}

extension AddAccountViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return false
      }
}
