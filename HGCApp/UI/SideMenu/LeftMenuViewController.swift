//
//  LeftMenuViewController.swift
//  HGCApp
//
//  Created by Surendra  on 26/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//


import UIKit
import MessageUI

protocol  LeftMenuViewControllerDelegate : class{
    func openSync()
    func openAbout()
    func pushPage(_ page:UIViewController)
    func switchPage(_ page:UIViewController)
}

fileprivate class MenuSection {
    let title:String
    let items:[Menu]
    init(title:String, items:[Menu]) {
        self.title = title
        self.items = items
    }
}

fileprivate class Menu {
    var title:String
    let name:String
    init(title:String, name:String) {
        self.title = title
        self.name = name
    }
    static func defaultAcc() -> Menu {
        return Menu.init(title: NSLocalizedString("Default Account", comment: ""), name: "defaultAcc")
    }
    
    static func accViewer() -> Menu {
           return Menu.init(title: NSLocalizedString("Account Viewer", comment: ""), name: "accViewer")
       }
    
    static func createAcc() -> Menu {
        return Menu.init(title: NSLocalizedString("Create Account", comment: ""), name: "createAcc")
    }
    
    static func backup() -> Menu {
        return Menu.init(title: NSLocalizedString("Recovery Phrase", comment: ""), name: "BACKUP")
    }
    
    static func requests() -> Menu {
        return Menu.init(title: NSLocalizedString("Requests", comment: ""), name: "Requests")
    }
    
    static func sync() -> Menu {
        return Menu.init(title: NSLocalizedString("Get Records", comment: ""), name: "getRecords")
    }
    
    static func nodes() -> Menu {
        return Menu.init(title: NSLocalizedString("Nodes", comment: ""), name: "NODES")
    }
    
    static func quit() -> Menu {
        return Menu.init(title: NSLocalizedString("QUIT", comment: ""), name: "QUIT")
    }
    
    static func logs() -> Menu {
        return Menu.init(title: NSLocalizedString("LOGS", comment: ""), name: "LOGS")
    }
    
    static func payToExchange() -> Menu {
        return Menu.init(title: NSLocalizedString("Pay to Third Party", comment: ""), name: "Pay to exchange")
    }
    
    static func clearCache() -> Menu {
        return Menu.init(title: NSLocalizedString("CLEAR CACHE", comment: ""), name: "clearCache")
    }
    
    static func updateKey() -> Menu {
        return Menu.init(title: NSLocalizedString("UPDATE KEY", comment: ""), name: "updateKey")
    }
    
    static func profile() -> Menu {
        return Menu.init(title: NSLocalizedString("Profile", comment: ""), name: "profile")
    }
    
    static func appInfo() -> Menu {
        return Menu.init(title: NSLocalizedString("App Information", comment: ""), name: "appInfo")
    }
    
}

class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!;
    @IBOutlet weak var menuButton : UIButton!;
    var accounts:[HGCAccount] = []
    
    private var sections : [MenuSection] = [MenuSection.init(title: NSLocalizedString("Accounts", comment: ""), items: [Menu.defaultAcc(), Menu.accViewer()]),
                                            MenuSection.init(title: NSLocalizedString("Activity", comment: ""),items: [Menu.requests(), Menu.createAcc()]),
                                            MenuSection.init(title: NSLocalizedString("Security", comment: ""), items: [Menu.backup(),
                                                                                                                        Menu.updateKey()]),
                                            MenuSection.init(title: NSLocalizedString("Network", comment: ""), items: [Menu.nodes(), Menu.sync()]),
                                            MenuSection.init(title: NSLocalizedString("About", comment: ""), items: [Menu.profile(), Menu.appInfo()])]
    
    weak var delegate : LeftMenuViewControllerDelegate?

    static func getInstance() -> LeftMenuViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "leftMenuViewController") as! LeftMenuViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuButton.setImage(UIImage.init(named: "icon-menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.menuButton.tintColor = UIColor.lightGray
        self.tableView.backgroundColor = .clear
        self.tableView.tableFooterView = UIView.init()
        
        let g = UILongPressGestureRecognizer.init(target: self, action: #selector(LeftMenuViewController.onLongPress(_:)))
        g.minimumPressDuration = 3
        self.tableView.addGestureRecognizer(g)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menu0 = sections[0].items.filter { (m) -> Bool in
            return m.name == Menu.defaultAcc().name
            }.first
        
        if let accName = HGCWallet.masterWallet()?.allAccounts().first?.name {
            menu0?.title = accName
        }
        self.tableView.reloadData()
    }
    
    @IBAction func onMenuButtonTap() {
        AppDelegate.getInstance().slideMenuController()?.hideRightView(animated: true, completionHandler: {
            
        })
    }
    
    func goToPayExchange() {
        let alert = UIAlertController.alert(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("PAY_EXCHANGE_MESSAGE", comment: ""))
        alert.addConfirmButton(title: NSLocalizedString("Agree", comment: "")) { (action) in
            let model = TransferViewModel.init(fromAccount: HGCWallet.masterWallet()!.allAccounts().first!, thirdParty: true)
            let vc = PayViewController.getInstance(model: model)
            vc.navigationItem.hidesBackButton = true
            self.delegate?.pushPage(vc)
        }
        alert.addDismissButton(title: NSLocalizedString("Decline", comment: ""), nil)
        alert.showAlert()
    }
    
    func emailLogs() {
        if !MFMailComposeViewController.canSendMail() {
            Globals.showGenericErrorAlert(title: "Cannot send email", message: "")
            return
        }
        let s = Logger.instance.logs.joined(separator: "\n")
        let emailComposer = MFMailComposeViewController.init()
        emailComposer.setMessageBody(s, isHTML: false)
        emailComposer.mailComposeDelegate = self
        self.present(emailComposer, animated: true) {
            
        }
    }
    
    func clearCache() {
        if let accounts = HGCWallet.masterWallet()?.allAccounts() {
            for account in accounts {
                account.clearData()
            }
            
            Globals.showGenericAlert(title: "Cache cleared", message: "")
        }
    }

    @objc func onLongPress(_ tap:UILongPressGestureRecognizer) {
        if tap.state == .began {
            let alert = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction.init(title: "Email Logs", style: .default, handler: { (action) in
                self.emailLogs()
            }))
            alert.addAction(UIAlertAction.init(title: "Clear Cache", style: .default, handler: { (action) in
                self.clearCache()
            }))
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: { (action) in
                
            }))
            alert.showAlert()
        }
        
    }

//MARK:- TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = sections[indexPath.section].items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true);
        AppDelegate.getInstance().slideMenuController()?.hideRightView(animated: true, completionHandler: {
            switch menu.name {
            case Menu.defaultAcc().name:
                let vc = AccountDetailsViewController.getInstance(HGCWallet.masterWallet()!.allAccounts().first!)
                self.delegate?.pushPage(vc)
                
            case Menu.accViewer().name:
                let vc = AccountViewerViewController.getInstance()
                self.delegate?.pushPage(vc)
            
            case Menu.requests().name:
                let vc = RequestListViewController.getInstance()
                self.delegate?.pushPage(vc)
                
            case Menu.backup().name:
                let vc = NewWalletViewController.getInstance(HGCWallet.masterWallet()!.signatureOption())
                vc.title = NSLocalizedString("Backup your wallet", comment: "")
                self.delegate?.pushPage(vc)
                
            case Menu.sync().name:
                self.delegate?.openSync()
                
            case Menu.nodes().name:
                let vc = NodesTableViewController.getInstance()
                vc.navigationItem.hidesBackButton = true
                self.delegate?.pushPage(vc)
            
            case Menu.payToExchange().name:
                self.goToPayExchange()
                
            case Menu.profile().name:
                let vc = SettingsTableViewController.getInstance()
                vc.navigationItem.hidesBackButton = true
                self.delegate?.pushPage(vc)
            case Menu.createAcc().name:
                let vc = CreateAccountViewController.getInstance(CreateAccountViewModel.init(fromAccount: WalletHelper.defaultPayerAccount()!))
                vc.navigationItem.hidesBackButton = true
                self.delegate?.pushPage(vc)
            case Menu.appInfo().name:
                let vc = AboutViewController.getInstance()
                vc.navigationItem.hidesBackButton = true
                self.delegate?.pushPage(vc)
            case Menu.updateKey().name:
                if WalletHelper.accountID() != nil {
                    AppDelegate.getInstance().switchToUpdateKey()

                } else {
                    Globals.showGenericAlert(title: NSLocalizedString("Account is not linked", comment: ""), message: "")
                }
            default: break
                
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leftMenuCell", for: indexPath) as! LeftMenuCell;
        let menu = self.sections[indexPath.section].items[indexPath.row]
        cell.menuTitle.text = menu.title;
        cell.menuImageView.image = nil
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.gray
        }
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
}

extension LeftMenuViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true) {
            
        }
    }
}
