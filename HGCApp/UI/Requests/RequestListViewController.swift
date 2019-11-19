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
