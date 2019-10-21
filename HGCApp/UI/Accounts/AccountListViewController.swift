//
//  AccountListViewController.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol AccountPickerDelegate : class {
    func accountPickerDidPickAccount(_ picker:AccountListViewController, accont: HGCAccount)
}

class AccountListViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var addButton : UIButton!
    weak var delegate: AccountPickerDelegate?

    private var accounts  = [HGCAccount]()
    
    var pickeMode  = false
    
    static func getInstance() -> AccountListViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "accountListViewController") as! AccountListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorColor = Color.tableLineSeperatorColor()
        if !self.pickeMode {
            //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-add"), style: .plain, target: self, action: #selector(onAddButtonTap))
        }
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.accounts = HGCWallet.masterWallet()?.allAccounts() ?? []
        if self.pickeMode {
            self.title = "Please select an account"
        } else {
            self.title = self.accounts.count.description +  " ACTIVE " + (self.accounts.count == 1 ? "ACCOUNT" : "ACCOUNTS")

        }
        self.tableView.reloadData()
    }
    
}

extension AccountListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountTableCell", for: indexPath) as! AccountTableCell
        cell.setAccount(self.accounts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = self.accounts[indexPath.row]
        if self.pickeMode {
            self.delegate?.accountPickerDidPickAccount(self, accont: account)
            
        } else {
            let vc = AccountDetailsViewController.getInstance(account)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
