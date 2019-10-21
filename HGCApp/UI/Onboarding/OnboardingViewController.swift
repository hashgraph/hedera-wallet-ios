//
//  OnboardingViewController.swift
//  HGCApp
//
//  Created by Surendra  on 17/12/17.
//  Copyright © 2017 HGC. All rights reserved.
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
