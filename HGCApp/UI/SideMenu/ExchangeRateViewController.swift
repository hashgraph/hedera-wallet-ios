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

class ExchangeRateViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    var dataSource = [ExchangeRateInfo]()
    
    @IBOutlet weak var rateLabel : UILabel!

    static func getInstance() -> ExchangeRateViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "exchangeRateViewController") as! ExchangeRateViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        navigationItem.hidesBackButton = true
        title = "Exchange Rate"
        rateLabel.textColor = Color.primaryTextColor()
        rateLabel.font = Font.regularFont(17.0)
        reloadUI()
        AppConfigService.defaultService.updateExchangeRate { [weak self](e) in
            self?.reloadUI()
        }
    }
    
    func reloadUI() {
        rateLabel.text = "1\(kHGCCurrencySymbol) = " + kUSDCurrencySymbol +  AppConfigService.defaultService.conversionRate().formatExchangeRate()
        dataSource = AppConfigService.defaultService.getAllRates()
        tableView.reloadData()
    }
    
}

extension ExchangeRateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExchangeRateCell
        let info = dataSource[indexPath.row]
        cell.set(info: info)
        return cell
    }
    
}
