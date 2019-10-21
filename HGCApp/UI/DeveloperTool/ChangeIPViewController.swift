//
//  ChangeIPViewController.swift
//  HGCApp
//
//  Created by Surendra on 16/06/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class ChangeIPViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textIPAddress : UITextField!
    @IBOutlet weak var textPort : UITextField!
    @IBOutlet weak var accountIdTextField : UITextField!
    @IBOutlet weak var btnChangeIP : UIButton!
    
    var node:HGCNode?
    var nodeVO:HGCNodeVO!

    @IBOutlet weak var btnSwitch: UISwitch!
    static func getInstance(node:HGCNode?) -> ChangeIPViewController {
        let vc = Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "changeIPViewController") as! ChangeIPViewController
        vc.node = node
        if let n = node {
            vc.nodeVO = n.nodeVO()
        } else {
            vc.nodeVO = HGCNodeVO.init(host: "", port: 0, accountID: HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0))
        }
       return vc
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        textIPAddress.keyboardType = UIKeyboardType.decimalPad
        accountIdTextField.keyboardType = UIKeyboardType.decimalPad
        btnChangeIP.setTitleColor(Color.defaultButtonTextColor(), for: .normal)
        btnChangeIP.titleLabel?.font = Font.regularFontMedium()
        btnChangeIP.backgroundColor = UIColor.white
        btnChangeIP.layer.borderWidth = 0.5
        btnChangeIP.layer.cornerRadius = 2
        btnChangeIP.clipsToBounds = true
        textIPAddress.keyboardType = .default
        accountIdTextField.keyboardType = .default
        
        textIPAddress.text = nodeVO.host
        let isNew = node == nil
        if !isNew {
            textIPAddress.text = nodeVO.host
            textPort.text = nodeVO.port.description
            accountIdTextField.text = nodeVO.accountID.stringRepresentation()
            btnSwitch.isOn = !node!.disabled
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUpdateAction(){
        if (textIPAddress.text == ""){
            Globals.showGenericErrorAlert(title: NSLocalizedString("Please enter an IP Address", comment: ""), message: "")
            
        } else if (!Globals.isValidIP(s: textIPAddress.text!)) {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Please enter valid IP Address", comment: ""), message: "")
            
        } else if (textPort.text == "") {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Please enter Port", comment: ""), message: "")
            
        } else if (HGCAccountID.init(from: accountIdTextField.text) == nil) {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Please enter valid node account ID", comment: ""), message: "")
            
        } else {
            nodeVO = HGCNodeVO.init(host: textIPAddress.text!.trim(), port: Int32((textPort.text!.trim()))!, accountID: HGCAccountID.init(from: accountIdTextField.text)!)
            if let n = node {
                n.host = nodeVO.host
                n.port = nodeVO.port
                let accId = nodeVO.accountID
                n.realmNum = accId.realmId
                n.shardNum = accId.shardId
                n.accountNum = accId.accountId
                n.disabled = !btnSwitch.isOn
                CoreDataManager.shared.saveContext()
            } else {
                let newNode = HGCNode.addNode(nodeVO: nodeVO, context: CoreDataManager.shared.mainContext)
                newNode.disabled = !btnSwitch.isOn
                CoreDataManager.shared.saveContext()
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func onSwitchValueChange() {
        if (!btnSwitch.isOn && HGCNode.getAllNodes(activeOnly: true, context: CoreDataManager.shared.mainContext).count <= 1) {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Minimum one node should be active", comment: ""), message: "")
            btnSwitch.setOn(true, animated: true)
        }
    }
}
