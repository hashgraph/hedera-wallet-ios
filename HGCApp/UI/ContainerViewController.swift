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

enum HGCTab {
    case home, accounts, requests, settings
}

class ContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
}

class ContainerViewController: UIViewController {

    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var warningContainer : UIView!
    @IBOutlet weak var warningLabel : UILabel!

    @IBOutlet var warningContainerHeight : NSLayoutConstraint!

    private var embededNavCtrl : UINavigationController!
    private var selectedTab = HGCTab.home
    
    private let statusBarBackgroundView = UIView.init()
    
    private var shouldRedirectToRequests = false

    static func getInstance() -> ContainerViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "containerViewController") as! ContainerViewController
    }
    
    func slideNavigationControllerShouldDisplayRightMenu() -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        let homeButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        homeButton.setImage(UIImage.init(named: "Hbar_grey-white-40"), for: .normal)
        homeButton.contentEdgeInsets.left = -12
        homeButton.addTarget(self, action:  #selector(onHomeBuutonTap), for: .touchUpInside)
        
        let refreshButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        refreshButton.accessibilityIdentifier = "Refresh"
        refreshButton.setImage(UIImage.init(named: "icon-sync"), for: .normal)
        refreshButton.contentEdgeInsets.right = -30
        refreshButton.addTarget(self, action:  #selector(onRefreshButtonTap), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage.init(named: "icon-menu"), style: .plain, target: self, action: #selector(onMenuButtonTap)), UIBarButtonItem.init(customView: refreshButton)]
        self.navigationItem.rightBarButtonItems?[0].accessibilityIdentifier = "Side Menu Button"
        
        self.embededNavCtrl.navigationBar.barTintColor = Color.titleBarBackgroundColor()
        self.embededNavCtrl.navigationBar.tintColor = Color.primaryTextColor()
        self.embededNavCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Color.primaryTextColor(), NSAttributedString.Key.font : Font.lightFontVeryLarge()]
        Globals.hideBottomLine(navBar: self.embededNavCtrl.navigationBar)
        statusBarBackgroundView.backgroundColor = Color.tabBackgroundColor()
        self.navigationController?.view.addSubview(statusBarBackgroundView)
        
        warningLabel.font = Font.lightFontSmall();
        warningContainer.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ContainerViewController.showBip39MigrationPrompt)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRedirectObjectReceived), name: .onRedirectObjectReceived, object: nil)
        if let accID = WalletHelper.defaultPayerAccount()?.accountID() {
            warningLabel.text = String(format: NSLocalizedString("BIP32_MIGRATION_WARNING_MESSAGE_PURPLE", comment: ""), accID.stringRepresentation())
        }
        showAppWarning(show: WalletHelper.canDoBip32Migration()) {}
    }
    
    override func viewWillLayoutSubviews() {
           super.viewWillLayoutSubviews()
       }
    
    func showAppWarning(show:Bool, competion:@escaping () -> Void) {
        warningContainerHeight.isActive = !show
        if !show {
            NSLayoutConstraint.activate([warningContainerHeight])
        } else {
            NSLayoutConstraint.deactivate([warningContainerHeight])
        }
    }
    
    @objc func onRedirectObjectReceived(notif:Notification) {
        if let intentParser = notif.object as? IntentParser {
            switch intentParser.intent {
            case .transferRequest:
                setTab(.requests)
            case .linkAccount:
                break
            case .linkAccountRequest:
                break
            }
            RedirectManager.shared.redirectionHandled()
        }
    }
    
    @objc func showBip39MigrationPrompt() {
        AppDelegate.getInstance().switchToUpdateKey()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarBackgroundView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: UIApplication.shared.statusBarFrame.size.height)
    }
    
    func setTab(_ tab: HGCTab) {
        if self.selectedTab == tab {
            self.embededNavCtrl.popToRootViewController(animated: true)
            
        } else {
            self.selectedTab = tab
            var vc : UIViewController!
            switch self.selectedTab {
            case .home:
                vc = OverviewViewController.getInstance()
            case .accounts:
                vc = AccountListViewController.getInstance()
            case .settings:
                vc = SettingsTableViewController.getInstance()
            case .requests:
                vc = RequestListViewController.getInstance()
            }
            self.embededNavCtrl.viewControllers = [vc]
        }
    }
    
    @objc func onMenuButtonTap() {
        AppDelegate.getInstance().slideMenuController()?.rightViewController?.viewWillAppear(false)
        AppDelegate.getInstance().slideMenuController()?.showRightView(animated: true, completionHandler: {
            
        })
    }
    
    @objc func onHomeBuutonTap() {
        if self.selectedTab == .home {
            if let overviewVC = self.embededNavCtrl.viewControllers[0] as? OverviewViewController {
                overviewVC.showDetailConatiner(false, animated: true)
            }
        }
        self.setTab(.home)
        
    }

    @IBAction func onRequestsButtonTap() {
        setTab(.requests)
    }
    
    @IBAction func onAccountsButtonTap() {
        setTab(.accounts)
    }
    
    @IBAction func onSettingsButtonTap() {
        setTab(.settings)
    }
    
    @IBAction func onRefreshButtonTap() {
        setTab(.home)
        WalletHelper.syncBalance()
        AppConfigService.defaultService.updateExchangeRate()
    }
}

extension ContainerViewController : LeftMenuViewControllerDelegate {
    
    func pushPage(_ page: UIViewController) {
        self.embededNavCtrl.pushViewController(page, animated: true)
    }
    
    func switchPage(_ page: UIViewController) {
        self.embededNavCtrl.viewControllers = [page]
    }
    
    @objc func openSync() {
        let onSync = {
            self.onHomeBuutonTap()
            WalletHelper.syncData()
        }
        
        if !AppSettings.askedForQueryCostWarning() {
            Globals.showConfirmationAlert(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("SYNC_WARNING", comment: ""), onConfirm: {
                AppSettings.setAskedForQueryCostWarning(true)
                onSync()
            }) {
                
            }
        } else {
            onSync()
        }
    }
    
    func openAbout() {
        let vc = AboutViewController.getInstance()
        self.embededNavCtrl.pushViewController(vc, animated: true)
    }
}
