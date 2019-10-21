//
//  RequestListViewController.swift
//  HGCApp
//
//  Created by Surendra  on 06/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class RequestListViewController: ContentViewController {
    
    @IBOutlet weak var tableView : UITableView!
    private var requests  = [HGCRequest]()
    
    static func getInstance() -> RequestListViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "requestListViewController") as! RequestListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorColor = Color.tableLineSeperatorColor()
        self.title = NSLocalizedString("REQUESTS", comment: "")
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requests = HGCRequest.allRequests(CoreDataManager.shared.mainContext)
        self.tableView.reloadData()
    }
}

extension RequestListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestTableCell", for: indexPath) as! RequestTableCell
        cell.delegate = self
        cell.setRequest(self.requests[indexPath.row])
        return cell
    }
}

extension RequestListViewController : RequestTableCellDelegate {
    func requestTableCellDidTapOnPayButton(_ cell: RequestTableCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let model = TransferViewModel.init(fromAccount: HGCWallet.masterWallet()!.allAccounts().first!, thirdParty: false, request: requests[(indexPath?.row)!])
        let vc = PayViewController.getInstance(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
