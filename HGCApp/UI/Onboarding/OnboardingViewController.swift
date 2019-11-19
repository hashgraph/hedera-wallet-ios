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

class OnboardingViewController: UIViewController {

    private var embededNavCtrl : UINavigationController!
    private var rootVC:UIViewController!
    static func getInstance(root:UIViewController) -> OnboardingViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "onboardingViewController") as! OnboardingViewController
        vc.rootVC = root
        return vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
            self.embededNavCtrl.viewControllers = [rootVC]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.embededNavCtrl.navigationBar.barTintColor = Color.titleBarBackgroundColor()
        self.embededNavCtrl.navigationBar.tintColor = Color.primaryTextColor()
        self.embededNavCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Color.primaryTextColor(), NSAttributedString.Key.font : Font.lightFontVeryLarge()]
        Globals.hideBottomLine(navBar: self.embededNavCtrl.navigationBar)
    }
}
