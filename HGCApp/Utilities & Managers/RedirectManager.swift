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

extension Notification.Name {
    static let onRedirectObjectReceived = Notification.Name("onRedirectObjectReceived")
}

class RedirectManager {
    static let shared = RedirectManager();
    private var coreDataManager : CoreDataManagerProtocol
    
    init(_ coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
        NotificationCenter.default.addObserver(self, selector:#selector(RedirectManager.onOnboardDidSuccess), name:WalletHelper.onboardDidSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(RedirectManager.onAuthSuccess), name:AuthManager.onAuthSuccess, object: nil)
    }
    
    func onUrlReceived(_ url: URL) {
        if !WalletHelper.isOnboarded() || AppDelegate.authManager.isAuthInProgress() {
            AppSettings.setRedirectURL(url.absoluteString)
            return
        }
        
        if let intentParser = IntentParser.init(url) {
            handleIntent(intentParser: intentParser)
        }
    }
    
    func onBranchParamsReceived(_ params:[String:Any]) {
        if !WalletHelper.isOnboarded() || AppDelegate.authManager.isAuthInProgress() {
            AppSettings.setBranchParams(params)
            return
        }
        
        if let intentParser = IntentParser.init(params) {
            handleIntent(intentParser: intentParser)
        }
    }
    
    private func handleIntent(intentParser:IntentParser) {
        switch intentParser.intent {
        case .transferRequest:
            self.saveHGCRequest(intentParser.intentParams as! TransferRequestParams)
            NotificationCenter.default.post(name: .onRedirectObjectReceived, object: intentParser, userInfo: nil)
            
        case .linkAccount:
            if self.linkAccount(intentParser.intentParams as! LinkAccountParams) {
                NotificationCenter.default.post(name: .onRedirectObjectReceived, object: intentParser, userInfo: nil)
            }
        case .linkAccountRequest:
            let params = intentParser.intentParams as! LinkAccountRequestParams
            self.handleLinkAccountRequest(params)
        }
        redirectionHandled()
    }
    
    func redirectionHandled() {
        AppSettings.setRedirectURL("")
        AppSettings.setBranchParams([:])
    }
    
    private func saveHGCRequest(_ params : TransferRequestParams) {
        var hgcRequest : HGCRequest!
        if let req = HGCRequest.requestFor(params, coreDataManager.mainContext) {
            req.importTime = Date()
            hgcRequest = req
            
        } else {
            hgcRequest = HGCRequest.createRequest(fromAddress: params.account.stringRepresentation(), coreDataManager.mainContext)
            hgcRequest.fromName = params.name
            if params.amount != nil {
                hgcRequest.amount = params.amount!
            }
            
            hgcRequest.note = params.note
            hgcRequest.notificationRequested = params.notify
            if HGCContact.getContact(params.account.stringRepresentation()) == nil {
                _ = HGCContact.addAlias(name: params.name, address: params.account.stringRepresentation())
            }
        }
        coreDataManager.saveContext()
    }
    
    private func linkAccount(_ params : LinkAccountParams) -> Bool {
        if let wallet = HGCWallet.masterWallet(), let account = wallet.accountWithPublicKey(params.address.stringRepresentation()) {
            account.updateAccountID(params.account)
            Globals.showGenericAlert(title: "Account linked", message: "Your account \(account.name!) is successfully linked with your accountID") { (action) in
                if let rUrl = params.redirect, let url = URL(string: rUrl) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    }
                }
            }
            
            return true
        }
        return false
    }
    
    private func handleLinkAccountRequest(_ params : LinkAccountRequestParams) {
        if let wallet = HGCWallet.masterWallet() {
            let allUnlinkedAccounts = wallet.allAccounts().filter { (acc) -> Bool in
                return acc.accountID() == nil
            }
            if !allUnlinkedAccounts.isEmpty {
                let sheet = UIAlertController.init(title: "Link Account", message: "Please select a public key", preferredStyle: .actionSheet)
                for acc in allUnlinkedAccounts {
                    let name = acc.name! + "..." + acc.publicKeyString().substringFromEnd(length: 6)
                    sheet.addAction(UIAlertAction.init(title: name, style: .default, handler: { (action) in
                        self.sendAccountLinkRequest(params, acc)
                    }))
                }
                sheet.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil))
                sheet.showAlert()
            }
        }
    }
    
    private func sendAccountLinkRequest(_ params : LinkAccountRequestParams, _ account:HGCAccount) {
        Logger.instance.log(message: "Sending link account request for " + account.publicKeyString(), event: .i)
        var request = URLRequest.init(url: params.callback)
        request.httpBody = account.publicKeyData()
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if error == nil, let res = urlResponse as? HTTPURLResponse, (res.statusCode >= 200 || res.statusCode < 300) {
                    
                    let alert = UIAlertController.init(title: "Account link request sent succesfully", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: { (a) in
                        if let rUrl = params.redirect, let url = URL(string: rUrl) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                            }
                        }
                    }))
                    alert.showAlert()
                    
                } else {
                    Globals.showGenericErrorAlert(title: "Something went wrong", message: "Unable to process link account request")
                    Logger.instance.log(message: error.debugDescription, event: .e)
                }
            }
            
        }
        task.resume()
    }
    
    @objc func onOnboardDidSuccess() {
        if let urlString = AppSettings.getRedirectURL(), let url = URL.init(string: urlString) {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.onUrlReceived(url)
            }
        }
        
        if let params = AppSettings.getBranchParams() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.onBranchParamsReceived(params)
            }
        }
    }
    
    @objc func onAuthSuccess() {
        onOnboardDidSuccess()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
