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
import MessageUI

class DeveloerToolViewController: UIViewController {
    @IBOutlet weak var tableView : UITableView!
    var menus : Array<String>!;

    private var embededNavCtrl : UINavigationController!
    
    static func getInstance() -> DeveloerToolViewController {
        return Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "develoerToolViewController") as! DeveloerToolViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Developer Tool"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-cross"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        self.menus = Array.init(arrayLiteral: "Manage Nodes","Logs");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushToChangeIp() {
        let vc = NodesTableViewController.getInstance()
        self.navigationController?.pushViewController(vc, animated: true)
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
    @IBAction func back() {
        navigationController?.dismiss(animated: true, completion:nil)
    }

}

extension DeveloerToolViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.menus[indexPath.row];
        cell.accessoryType = .disclosureIndicator
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0 :
        self.pushToChangeIp()
            break
        case 1:
            self.emailLogs()
        default: break
        }
    }
}

extension DeveloerToolViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true) {
            
        }
    }
}
