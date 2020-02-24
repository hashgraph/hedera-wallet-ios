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
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    private var splashWindow: UIWindow?
    static var authManager : AuthManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // setup UI
        setupWindows()
        HGCStyle.customizeAppearance();
        
        // load address book
        APIAddressBookService.defaultAddressBook.loadAddressBook()
        
        if WalletHelper.isOnboarded() {
            // Authenticate
            AppDelegate.authManager.authenticate(AppDelegate.authManager.currentAuthType(), animated: false)
        }
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        RedirectManager.shared.onUrlReceived(url)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        splashWindow?.isHidden = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        splashWindow?.isHidden = true
        AppConfigService.defaultService.updateExchangeRate()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        splashWindow?.isHidden = true
        if WalletHelper.isOnboarded() && AppDelegate.authManager.shouldAskForAuth() {
            AppDelegate.authManager.authenticate(AppDelegate.authManager.currentAuthType(), animated: false)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}

extension AppDelegate {
    static func getInstance() -> AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }
    
    func setupWindows() {
        IQKeyboardManager.shared.enable = true
        splashWindow = UIWindow.init(frame: UIScreen.main.bounds)
        splashWindow?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()
        splashWindow?.windowLevel = UIWindow.Level.init(rawValue: 3)
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window!.accessibilityIdentifier = "Main Window"
        AppDelegate.authManager = AuthManager.init(mainWindow: window!)
        
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.onOnboardDidSuccess), name:WalletHelper.onboardDidSuccess, object: nil)
        
        if WalletHelper.isOnboarded() {
            window?.rootViewController = WalletHelper.canDoBip32Migration() ? migrationViewController() : mainViewController()
            window?.makeKeyAndVisible()
        } else {
            window?.rootViewController = welcomeViewController()
            window?.makeKeyAndVisible()
        }
    }
    
    private func switchToMain() {
        let mainVC = self.mainViewController();
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window?.rootViewController = mainVC
        }, completion: nil)
    }
    
    func switchToWelcome() {
        let welcomeVC = self.welcomeViewController();
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window?.rootViewController = welcomeVC
        }, completion: nil)
    }
    
    func switchToUpdateKey() {
        let vc = migrationViewController();
        self.window?.rootViewController = vc
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window?.rootViewController = vc
        }, completion: nil)
    }
    
    func slideMenuController() -> LGSideMenuController? {
        if let vc = self.window?.rootViewController as? LGSideMenuController {
            return vc
        }
        return nil
    }
    
    func mainViewController() -> UIViewController {
        let centerViewController = ContainerViewController.getInstance();
        let navigationController = UINavigationController.init(rootViewController: centerViewController);
        Globals.hideBottomLine(navBar: navigationController.navigationBar)
        
        let sideMenu = LeftMenuViewController.getInstance();
        sideMenu.delegate = centerViewController
        sideMenu.view.backgroundColor = Color.sideMenuBackgroundColor()
        let sideMenuController = LGSideMenuController.init(rootViewController: navigationController, leftViewController: nil, rightViewController: sideMenu)
        sideMenuController.rightViewWidth = 260.0;
        sideMenuController.leftViewPresentationStyle = .slideBelow;
        sideMenuController.rightViewBackgroundColor = Color.sideMenuBackgroundColor()
        sideMenuController.leftViewBackgroundColor = Color.sideMenuBackgroundColor()

        return sideMenuController
    }
    
    func welcomeViewController() -> UIViewController {
        let vc  = OnboardingViewController.getInstance(root: WalletSetupOptionsViewController.getInstance())
        vc.title = NSLocalizedString("Get Started on Hedera", comment: "")
        let navVC = UINavigationController.init(rootViewController: vc)
        return navVC
    }
    
    func migrationViewController() -> UIViewController {
        let vc  = OnboardingViewController.getInstance(root: Bip32MigrationPromptVC.getInstance(delegate: self, forKeyUpdate: !WalletHelper.canDoBip32Migration()))
        vc.title = NSLocalizedString("Hedera Wallet", comment: "")
        let navVC = UINavigationController.init(rootViewController: vc)
        return navVC
    }
    
    @objc func onOnboardDidSuccess() {
        switchToMain()
    }
}

extension AppDelegate : Bip32MigrationDelegate {
    func bip32MigrationRetry(_ vc: UIViewController) {
        vc.navigationController?.popToRootViewController(animated: true)
    }
    
    var oldKey: HGCKeyPairProtocol {
        return WalletHelper.defaultPayerAccount()!.key()
    }
    
    var accountID: HGCAccountID {
        return WalletHelper.accountID()!
    }
    
    func bip32MigrationAborted() {
        switchToMain()
    }
    
    func bip32MigrationSuccessful(_ newSeed: HGCSeed, _ accountID: HGCAccountID) {
        let wallet = HGCWallet.masterWallet()
        wallet?.keyDerivationType = .bip32
        WalletHelper.defaultPayerAccount()?.publicKey = nil
        SecureAppSettings.default.setSeed(newSeed.entropy)
        CoreDataManager.shared.saveContext()
        AppSettings.setNeedsToShownBip39Mnemonic()
        switchToMain()
    }
}

