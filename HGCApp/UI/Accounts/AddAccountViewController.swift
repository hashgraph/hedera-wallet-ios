//
//  AddAccountViewController.swift
//  HGCApp
//
//  Created by Surendra  on 28/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import CoreData

protocol AddAccountViewModelDelegate : class {
    func onDoneButtonTap(_ vm:AddAccountViewModel)
    func onDeleteButtonTap(_ vm:AddAccountViewModel)
    func onCancelButtonTap(_ vm:AddAccountViewModel)
}

class AddAccountViewModel {
    weak var delegate:AddAccountViewModelDelegate?
    var accountIDString = ""
    var nickName = ""
    var account:HGCAccount?
    var context:NSManagedObjectContext = CoreDataManager.shared.mainContext
    
    var editMode:Bool {
        return account != nil
    }
    
    var pageTitle: String {
        return editMode ?  NSLocalizedString("EDIT ACCOUNT", comment: "") : NSLocalizedString("ADD ACCOUNT", comment: "")
    }
    
    var hideDeleteButton:Bool {
        return !editMode
    }
    
    init(delegate:AddAccountViewModelDelegate) {
        self.delegate = delegate
    }
    
    init(account:HGCAccount, delegate:AddAccountViewModelDelegate) {
        nickName = account.name ?? ""
        accountIDString = account.accountID()?.stringRepresentation() ?? ""
        self.account = account
        self.delegate = delegate
    }
    
    var accountID:HGCAccountID? {
        return HGCAccountID.init(from: accountIDString)
    }
    
    func onDoneButtonTap() throws {
        guard let accId = accountID else {
            throw NSLocalizedString("Please enter a valid account ID", comment: "")
        }
        if let account = account {
            account.updateAccountID(accId)
            account.name = nickName
            CoreDataManager.save(context: account.managedObjectContext!)
        } else {
            account = HGCWallet.masterWallet()?.createNewExternalAccount(accountID: accId, name: nickName, context)
            CoreDataManager.save(context: context)
        }
        delegate?.onDoneButtonTap(self)
    }
    
    func onDeleteButtonTap() {
        if let account = account {
            context.delete(account)
            CoreDataManager.save(context: context)
        }
        delegate?.onDoneButtonTap(self)
    }
    
    func onCancelButtonTap() {
        delegate?.onCancelButtonTap(self)
    }
}

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
