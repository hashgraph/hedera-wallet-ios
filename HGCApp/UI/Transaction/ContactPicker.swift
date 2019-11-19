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

protocol ContactPickerDelegate : class {
    func contactPickerDidPickContact(_ picker:ContactPicker, contact: HGCContact)
    func contactPickerDidPickAccount(_ picker:ContactPicker, account: HGCAccount)
}

class ContactPicker : UIViewController {
    
    private static let sectionIndexContacts = 0
    private static let sectionIndexMyAccounts = 1
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var addButton : UIButton!
    weak var delegate: ContactPickerDelegate?
    
    private var contacts  = [HGCContact]()
    
    var pickeMode  = true
    private var forExcangeOnly = false
    
    static func getInstance(_ forExcangeOnly:Bool = false) -> ContactPicker {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "contactPicker") as! ContactPicker
        vc.forExcangeOnly = forExcangeOnly
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func allAccounts() -> [HGCAccount] {
        return !forExcangeOnly ? (HGCWallet.masterWallet()?.allAccounts() ?? []) : []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if forExcangeOnly {
            self.contacts = HGCContact.getAllContacts().filter({ (contact) -> Bool in
                return (contact.host != nil)
            })
        } else {
            self.contacts = HGCContact.getAllContacts()
        }
        
        self.title = self.contacts.count == 0 ? NSLocalizedString("NO CONTACTS", comment: "") : NSLocalizedString("EXISTING CONTACTS", comment: "")
        self.tableView.reloadData()
    }
    
    @IBAction func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactPicker : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ContactPicker.sectionIndexContacts {
            return contacts.count
            
        } else if section == ContactPicker.sectionIndexMyAccounts {
            return self.allAccounts().count
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == ContactPicker.sectionIndexContacts {
            return nil
            
        } else if section == ContactPicker.sectionIndexMyAccounts && self.allAccounts().count > 0{
            return "     " + NSLocalizedString("My Accounts", comment: "")
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        if indexPath.section == ContactPicker.sectionIndexContacts {
            let contact = self.contacts[indexPath.row]
            
            cell.verifiedLabel.text = ""
            cell.nameLabel.text = (contact.name == nil || (contact.name?.trim().isEmpty)! ) ? NSLocalizedString("UNKNOWN", comment: "") : contact.name
            cell.addressLabel.text = contact.publicKeyID ?? ""
            
        } else if indexPath.section == ContactPicker.sectionIndexMyAccounts {
            let account = self.allAccounts()[indexPath.row]
            cell.verifiedLabel.text = ""
            cell.nameLabel.text = account.name
            cell.addressLabel.text = account.accountID()?.stringRepresentation() ?? account.publicKeyString()
        }
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.pickeMode {
            if indexPath.section == ContactPicker.sectionIndexContacts {
                let contact = self.contacts[indexPath.row]
                self.delegate?.contactPickerDidPickContact(self, contact: contact)
                
            } else if indexPath.section == ContactPicker.sectionIndexMyAccounts {
                let account = self.allAccounts()[indexPath.row]
                self.delegate?.contactPickerDidPickAccount(self, account: account)
            }
        }
    }
}
