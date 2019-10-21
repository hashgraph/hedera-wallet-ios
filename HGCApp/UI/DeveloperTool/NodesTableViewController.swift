//
//  NodesTableViewController.swift
//  HGCApp
//
//  Created by Surendra on 21/09/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import MBProgressHUD

class NodesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nodes = [HGCNode]()
    @IBOutlet weak var tableView:UITableView!
 
    static func getInstance() -> NodesTableViewController {
        return Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "nodesTableViewController") as! NodesTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("NODES", comment: "")
        _ = APIAddressBookService.defaultAddressBook;
        if allowEditingNet {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title:NSLocalizedString("Add", comment: ""), style: .plain, target: self, action: #selector(NodesTableViewController.onAddButtonTap)), UIBarButtonItem.init(title:NSLocalizedString("Copy", comment: ""), style: .plain, target: self, action: #selector(NodesTableViewController.onCopyButtonTap))]
        }
        self.tableView.backgroundColor = Color.pageBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nodes = HGCNode.getAllNodes(activeOnly: false, context: CoreDataManager.shared.mainContext)
        self.tableView.reloadData()
    }
    
    @IBAction func onAddButtonTap() {
        let vc = ChangeIPViewController.getInstance(node: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onCopyButtonTap() {
        let string = APIAddressBookService.defaultAddressBook.getAddressBookString()
        Globals.copyString(string)
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message: string)
    }

    @IBAction func onRefreshButtonTap() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        APIAddressBookService.defaultAddressBook.updateAddressBook(context: CoreDataManager.shared.mainContext) { [weak self] (e) in
            if let error = e {
                Globals.showGenericAlert(title: NSLocalizedString("Error", comment: ""), message: error)
            }
            hud.hide(animated: true)
            self?.nodes = HGCNode.getAllNodes(activeOnly: false, context: CoreDataManager.shared.mainContext)
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        let node = nodes[indexPath.row]
        let nodeVO = node.nodeVO()
        cell.textLabel?.text = nodeVO.address()
        cell.detailTextLabel?.text = nodeVO.accountID.stringRepresentation()
        cell.accessoryType = !allowEditingNet ? .none : .disclosureIndicator;
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let node = nodes[indexPath.row]
        cell.textLabel?.textColor = !node.disabled ? UIColor.black : UIColor.gray
        cell.detailTextLabel?.textColor = !node.disabled ? UIColor.black : UIColor.gray
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowEditingNet {
            let vc = ChangeIPViewController.getInstance(node: nodes[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
